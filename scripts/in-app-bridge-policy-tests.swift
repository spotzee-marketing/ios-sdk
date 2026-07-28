import Foundation

@main
struct InAppBridgePolicyTests {
    static func main() {
        precondition(!InAppBridgePolicy.allowsNavigationAction(isMainFrame: false))
        precondition(InAppBridgePolicy.allowsNavigationAction(isMainFrame: true))

        precondition(
            InAppBridgePolicy.message(
                actionName: "custom",
                body: ["screen": "billing"],
                isMainFrame: false
            ) == nil,
            "subframes must not reach native custom actions"
        )

        let custom = InAppBridgePolicy.message(
            actionName: "custom",
            body: ["screen": "billing"],
            isMainFrame: true
        )
        precondition(custom?.action == .custom)
        precondition(custom?.context["screen"] as? String == "billing")

        let dismiss = InAppBridgePolicy.message(
            actionName: "dismiss",
            body: "",
            isMainFrame: true
        )
        precondition(dismiss?.action == .dismiss)
        precondition(dismiss?.context.isEmpty == true)

        precondition(
            InAppBridgePolicy.message(
                actionName: "custom",
                body: "billing",
                isMainFrame: true
            ) == nil,
            "custom actions require an object payload"
        )
        precondition(
            InAppBridgePolicy.message(
                actionName: "unknown",
                body: [:],
                isMainFrame: true
            ) == nil,
            "unknown actions must be rejected"
        )
    }
}
