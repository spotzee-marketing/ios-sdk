import Foundation

public enum InAppDisplayState {
    case show, skip, consume
}

public protocol InAppDelegate: AnyObject {
    var autoShow: Bool { get }
    var useDarkMode: Bool { get }
    func onNew(notification: SpotzeeNotification) -> InAppDisplayState
    func didDisplay(notification: SpotzeeNotification)
    func handle(action: InAppAction, context: [String: Any], notification: SpotzeeNotification)
    func onError(error: Error)
}

extension InAppDelegate {
    public var autoShow: Bool { true }
    public var useDarkMode: Bool { false }
    public func onNew(notification: SpotzeeNotification) -> InAppDisplayState { .show }
    public func didDisplay(notification: SpotzeeNotification) {}
    public func onError(error: Error) {}
}
