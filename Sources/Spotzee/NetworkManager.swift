import Foundation

class NetworkManager {
    static let apiURL = "https://apix.spotzee.com/api"

    /// Pinned Spotzee API version this SDK release targets.
    static let apiVersion = "2026-04-28"

    /// x-spotzee-client-type value sent on every request from this SDK.
    static let clientType = "sdk-ios"

    var urlSession = URLSession.shared

    private let config: Config
    init(config: Config) {
        self.config = config
    }

    func get<T: Decodable> (path: String, user: Alias) async throws -> T {
        let headers = [
            "x-anonymous-id": user.anonymousId,
            "x-external-id": user.externalId
        ]
        let request = self.request(path: path, method: "GET", headers: headers)
        return try await self.process(request: request)
    }

    func post(path: String, object: Encodable, handler: ((Error?) -> Void)? = nil) {
        let request = self.request(path: path, method: "POST", object: object)
        self.process(request: request) { (result: Result<Data?, Error>) in
            switch result {
            case .failure(let error): handler?(error)
            case .success: handler?(nil)
            }
        }
    }

    func post<T: Decodable>(path: String, object: Encodable) async throws -> T {
        let request = self.request(path: path, method: "POST", object: object)
        return try await self.process(request: request)
    }

    @discardableResult func put(path: String, object: Encodable) async throws -> Data? {
        let request = self.request(path: path, method: "PUT", object: object)
        return try await self.process(request: request)
    }

    @available(*, renamed: "process()")
    func process(request: URLRequest, handler: ((Result<Data?, Error>) -> Void)? = nil) {
        Task {
            do {
                let result = try await process(request: request)
                handler?(.success(result))
            } catch {
                handler?(.failure(error))
            }
        }
    }

    func process(request: URLRequest) async throws -> Data? {
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let summary = Self.summariseError(statusCode: httpResponse.statusCode, response: httpResponse, data: data)
            print("SZ | \(summary)")
            throw URLError(.badServerResponse)
        }

        return data
    }

    /// Best-effort parse of the new RFC 7807 error envelope (Spotzee API
    /// 2026-04-28+) with fall-back to the legacy shape. Returns a single
    /// human-readable line for the print statement; the SDK still throws
    /// `URLError(.badServerResponse)` so existing callers' catch blocks keep
    /// working.
    static func summariseError(statusCode: Int, response: HTTPURLResponse, data: Data) -> String {
        var parts: [String] = ["HTTP \(statusCode)"]
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let code = json["code"] as? String { parts.append("code=\(code)") }
            if let message = (json["message"] as? String) ?? (json["error"] as? String) {
                parts.append(message)
            }
            if let bodyRequestId = json["request_id"] as? String {
                parts.append("request_id=\(bodyRequestId)")
            }
        }
        if let headerRequestId = response.value(forHTTPHeaderField: "X-Request-Id"),
           !parts.contains(where: { $0.hasPrefix("request_id=") }) {
            parts.append("request_id=\(headerRequestId)")
        }
        return parts.joined(separator: " | ")
    }

    func process<T: Decodable>(request: URLRequest) async throws -> T {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let data = try await self.process(request: request)
        if let data {
            return try decoder.decode(T.self, from: data)
        } else {
            throw URLError(.badServerResponse)
        }
    }

    func request(
        path: String,
        method: String,
        headers: [String: String?] = [:],
        object: Encodable? = nil
    ) -> URLRequest {
        let url = URL(string: "\(Self.apiURL)/client/\(path)")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue(Self.apiVersion, forHTTPHeaderField: "Spotzee-Version")
        request.setValue(Self.clientType, forHTTPHeaderField: "x-spotzee-client-type")
        for (header, value) in headers {
            request.setValue(value, forHTTPHeaderField: header)
        }
        request.httpMethod = method
        if let object = object {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .formatted(DateFormatter.jsonDateFormat)
            encoder.keyEncodingStrategy = .convertToSnakeCase
            request.httpBody = try? encoder.encode(object)
        }
        return request
    }
}
