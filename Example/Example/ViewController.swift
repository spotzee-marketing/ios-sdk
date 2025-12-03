import UIKit
import Spotzee

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let id = UUID().uuidString
        Spotzee.shared.identify(id: id, traits: [
            "first_name": "John",
            "last_name": "Doe"
        ])

        Spotzee.shared.track(event: "Application Opened", properties: ["property": true])
    }

    @IBAction func registerPushNotifications() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            print("SZ | Notification Status: \(granted)")
            DispatchQueue.main.async {
                if granted { UIApplication.shared.registerForRemoteNotifications() }
            }
        }
    }

    @IBAction func getNotifications() {
        Task { @MainActor in
            await Spotzee.shared.showLatestNotification()
        }
    }
}
