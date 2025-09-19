import SwiftUI

@main
struct TotalRecordApp: App {
    // Use the shared instance instead of creating a new one
    private var trophyRoomStorage = TrophyRoomStorage.shared
    private var notificationManager = NotificationManager.shared

    init() {
        // macOS app initialization
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(trophyRoomStorage)
                .environmentObject(notificationManager)
                .onAppear {
                    trophyRoomStorage.loadTrophyRooms()
                    trophyRoomStorage.loadCurrentTrophyRoom()
                    
                    notificationManager.printNotificationStatus()
                    
                    print("App loaded - Current trophy room: \(trophyRoomStorage.currentTrophyRoom?.name ?? "None") with color: \(trophyRoomStorage.currentTrophyRoom?.color ?? "None")")
                    print("Total trophy rooms: \(trophyRoomStorage.trophyRooms.count)")
                    for (index, trophyRoom) in trophyRoomStorage.trophyRooms.enumerated() {
                        print("Trophy Room \(index): \(trophyRoom.name) - Color: \(trophyRoom.color)")
                    }
                }
        }
    }
}
