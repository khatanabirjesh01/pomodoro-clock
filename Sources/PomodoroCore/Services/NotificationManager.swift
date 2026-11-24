import Foundation
import UserNotifications

public final class NotificationManager: NSObject, UNUserNotificationCenterDelegate, @unchecked Sendable {
    public static let shared = NotificationManager()
    
    public var onActionSelected: ((String) -> Void)?
    
    public var isAvailable: Bool {
        Bundle.main.bundleIdentifier != nil
    }
    
    private override init() {
        super.init()
        guard Bundle.main.bundleIdentifier != nil else { return }
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        setupCategories()
    }
    
    public func requestAuthorization() {
        guard Bundle.main.bundleIdentifier != nil else { return }
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            }
        }
    }
    
    private func setupCategories() {
        guard Bundle.main.bundleIdentifier != nil else { return }
        let startNextAction = UNNotificationAction(
            identifier: "START_NEXT",
            title: "Start Next Phase",
            options: [.foreground]
        )
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS",
            title: "Dismiss",
            options: []
        )
        
        let category = UNNotificationCategory(
            identifier: "POMODORO_COMPLETION",
            actions: [startNextAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    public func sendNotification(title: String, subtitle: String? = nil, body: String) {
        guard Bundle.main.bundleIdentifier != nil else {
            print("🔔 [Notification] \(title) - \(body)")
            return
        }
        let content = UNMutableNotificationContent()
        content.title = title
        if let subtitle = subtitle {
            content.subtitle = subtitle
        }
        content.body = body
        content.sound = .default
        content.categoryIdentifier = "POMODORO_COMPLETION"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
    
    // Allow notifications to display as banners even when app is foregrounded
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
    
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let actionIdentifier = response.actionIdentifier
        DispatchQueue.main.async { [weak self] in
            self?.onActionSelected?(actionIdentifier)
        }
        completionHandler()
    }
}
