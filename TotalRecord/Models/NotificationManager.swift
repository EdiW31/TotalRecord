
import UserNotifications
import Foundation

public class NotificationManager: ObservableObject {
    public static let shared = NotificationManager()
    
    @Published public var notificationPermissionGranted: Bool = false
    @Published public var lastLoginTime: Date?
    
    private let userDefaults = UserDefaults.standard
    private let lastLoginKey = "lastLoginTime"
    private let reminderIntervalHours: Double = 1.0/60.0  // 1 minute for testing (was 8.0 hours)
    
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
            
        } catch {
            print("Notification permission request failed: \(error)")
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
        
        // Cancel any existing reminders and schedule new ones
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
    
    private func scheduleStreakReminder() async {
        cancelAllReminders()
        
        guard notificationPermissionGranted else {
            print("📱 Notification permission not granted, skipping reminder scheduling")
            return
        }
        
        // creez un content pentru notificare
        let content = UNMutableNotificationContent()
        content.title = "Keep Your Streak Alive! 🔥"
        content.body = "You haven't played in a while. Come back and continue your TotalRecord journey!"
        content.sound = .default
        content.badge = 1
        
        // Calculate trigger time (1 minute from last login for testing)
        guard let loginTime = lastLoginTime else {
            print("⚠️ No last login time available")
            return
        }
        
        let reminderTime = loginTime.addingTimeInterval(reminderIntervalHours * 3600)
        
        // Don't schedule if the reminder time has already passed
        guard reminderTime > Date() else {
            print("⏰ Reminder time has already passed, not scheduling")
            return
        }
        
        // trigger
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderTime),
            repeats: false
        )
        
        // request
        let request = UNNotificationRequest(
            identifier: "streakReminder",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Failed to schedule streak reminder: \(error)")
        }
    }
    
    public func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🗑️ All pending reminders cancelled")
    }
    
    public func isDoNotDisturbEnabled() -> Bool {
        // Check if Do Not Disturb is enabled
        // Note: iOS doesn't provide direct access to DND status for privacy reasons
        // The system will automatically suppress notifications when DND is enabled
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