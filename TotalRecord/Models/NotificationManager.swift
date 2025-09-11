
mport UserNotifications
import Foundation

public class NotificationManager: ObservableObject {
    public static let shared = NotificationManager()
    
    @Published public var notificationPermissionGranted: Bool = false
    @Published public var lastLoginTime: Date?
    
    private let userDefaults = UserDefaults.standard
    private let lastLoginKey = "lastLoginTime"
    private let reminderIntervalHours: Double = 1.0/60.0 
    
    private init() {
        loadLastLoginTime()
        checkNotificationPermission()
    }
    
    public func requestNotificationPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound]
            )
            
            DispatchQueue.main.async {
                self.notificationPermissionGranted = granted
            }
            
            if granted {
                await scheduleStreakReminder()
            }
            
        } 
    }
    
    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationPermissionGranted = settings.authorizationStatus == .authorized
            }
        }
    }
    
    public func recordLogin() {
        lastLoginTime = Date()
        saveLastLoginTime()
        
        cancelAllReminders()
        if notificationPermissionGranted {
            Task {
                await scheduleStreakReminder()
            }
        }
    }
    
    private func loadLastLoginTime() {
        if let savedTime = userDefaults.object(forKey: lastLoginKey) as? Date {
            lastLoginTime = savedTime
        }
    }
    
    private func saveLastLoginTime() {
        if let loginTime = lastLoginTime {
            userDefaults.set(loginTime, forKey: lastLoginKey)
        }
    }
    
    private func scheduleStreakReminder() async 
        cancelAllReminders()
        
        // Only schedule if we have permission
        guard notificationPermissionGranted else {
            print("📱 Notification permission not granted, skipping reminder scheduling")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Keep Your Streak Alive! 🔥"
        content.body = "You haven't played in a while. Come back and continue your TotalRecord journey!"
        content.sound = .default
        content.badge = 1
        
        guard let loginTime = lastLoginTime else {
            print("⚠️ No last login time available")
            return
        }
        
        let reminderTime = loginTime.addingTimeInterval(reminderIntervalHours * 3600)
        
        guard reminderTime > Date() else {
            print("⏰ Reminder time has already passed, not scheduling")
            return
        }
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderTime),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "streakReminder",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } 
    }
    
    public func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    
    public func isDoNotDisturbEnabled() -> Bool {
        return false
    }
   
    
    public func hoursSinceLastLogin() -> Double? {
        guard let loginTime = lastLoginTime else { return nil }
        return Date().timeIntervalSince(loginTime) / 3600.0
    }
    
    public func shouldShowReminder() -> Bool {
        guard let hoursSinceLogin = hoursSinceLastLogin() else { return false }
        return hoursSinceLogin >= reminderIntervalHours
    }

    public func setupNotificationsForNewUser() async {
        await requestNotificationPermission()
    }

    
    public func printNotificationStatus() {
        print("📱 Notification Status:")
        print("   Permission granted: \(notificationPermissionGranted)")
        print("   Last login: \(lastLoginTime?.description ?? "Never")")
        print("   Hours since login: \(hoursSinceLastLogin() ?? 0)")
        print("   Should show reminder: \(shouldShowReminder())")
    }
}
