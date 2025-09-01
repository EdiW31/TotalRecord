import SwiftUI

// MARK: - Trophy Room Theme
struct TrophyRoomTheme {
    let primaryColor: Color      // Main trophy room color
    let secondaryColor: Color    // Complementary color
    let accentColor: Color       // High-contrast accent
    let backgroundColor: Color    // Background variant
    let textColor: Color         // Text color for readability
    
    // Default theme for when no trophy room is unlocked
    static let defaultTheme = TrophyRoomTheme(
        primaryColor: .purple,
        secondaryColor: .purple.opacity(0.7),
        accentColor: .orange,
        backgroundColor: .purple.opacity(0.1),
        textColor: .black
    )
}

class ThemeManager: ObservableObject {
    @Published var currentTrophyRoomTheme: TrophyRoomTheme
    
    init() {
        // Initialize with a default theme
        self.currentTrophyRoomTheme = TrophyRoomTheme.defaultTheme
    }
    
    // Convert trophy room color string to complete theme
    func generateThemeFromTrophyRoom(_ trophyRoom: TrophyRoom) -> TrophyRoomTheme {
        let primaryColor = Color(trophyRoom.color)
        
        // Generate complementary colors based on primary
        let secondaryColor = primaryColor.opacity(0.7)
        let backgroundColor = primaryColor.opacity(0.1)
        
        // Choose accent color based on primary color for good contrast
        let accentColor: Color
        switch trophyRoom.color {
        case "purple", "blue", "indigo":
            accentColor = .orange
        case "green", "teal":
            accentColor = .red
        case "pink", "red":
            accentColor = .green
        case "orange", "yellow":
            accentColor = .blue
        default:
            accentColor = .orange
        }
        
        // Choose text color based on background brightness
        // For light backgrounds, use dark text; for dark backgrounds, use light text
        let textColor: Color = trophyRoom.color == "yellow" || trophyRoom.color == "orange" ? .black : .white
        
        return TrophyRoomTheme(
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
            accentColor: accentColor,
            backgroundColor: backgroundColor,
            textColor: textColor
        )
    }
    
    // Update theme based on available trophy rooms
    func updateThemeFromTrophyRooms(_ trophyRooms: [TrophyRoom]) {
        if let firstTrophyRoom = trophyRooms.first {
            currentTrophyRoomTheme = generateThemeFromTrophyRoom(firstTrophyRoom)
        }
    }
    
    // Get current theme colors as computed properties
    var primaryColor: Color { currentTrophyRoomTheme.primaryColor }
    var secondaryColor: Color { currentTrophyRoomTheme.secondaryColor }
    var accentColor: Color { currentTrophyRoomTheme.accentColor }
    var backgroundColor: Color { currentTrophyRoomTheme.backgroundColor }
    var textColor: Color { currentTrophyRoomTheme.textColor }
}