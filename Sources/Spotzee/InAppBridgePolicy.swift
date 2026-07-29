import Foundation

public enum InAppAction: String, CaseIterable {
    case dismiss, custom
}

struct InAppBridgeMessage {
    let action: InAppAction
    let context: [String: Any]
}

enum InAppBridgePolicy {
    static func allowsNavigationAction(isMainFrame: Bool) -> Bool {
        isMainFrame
    }

    static func message(
        actionName: String,
        body: Any,
        isMainFrame: Bool
    ) -> InAppBridgeMessage? {
        guard isMainFrame, let action = InAppAction(rawValue: actionName) else {
            return nil
        }

        switch action {
        case .dismiss:
            return InAppBridgeMessage(action: action, context: [:])
        case .custom:
            return InAppBridgeMessage(
                action: action,
                context: body as? [String: Any] ?? [:]
            )
        }
    }
}
