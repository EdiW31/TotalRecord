import SwiftUI
struct TrophyRoomTheme {
    let primaryColor: Color      
    let secondaryColor: Color    
    let accentColor: Color       
    let backgroundColor: Color    
    let textColor: Color         
    
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
        // initializere cu default
        self.currentTrophyRoomTheme = TrophyRoomTheme.defaultTheme
    }
    
    func generateThemeFromTrophyRoom(_ trophyRoom: TrophyRoom) -> TrophyRoomTheme {
        let primaryColor = Color(trophyRoom.color)
        
        let secondaryColor = primaryColor.opacity(0.7)
        let backgroundColor = primaryColor.opacity(0.1)
        
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
        
        let textColor: Color = trophyRoom.color == "yellow" || trophyRoom.color == "orange" ? .black : .white
        
        return TrophyRoomTheme(
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
            accentColor: accentColor,
            backgroundColor: backgroundColor,
            textColor: textColor
        )
    }
    
    func updateThemeFromTrophyRooms(_ trophyRooms: [TrophyRoom]) {
        if let firstTrophyRoom = trophyRooms.first {
            currentTrophyRoomTheme = generateThemeFromTrophyRoom(firstTrophyRoom)
        }
    }
    
    var primaryColor: Color { currentTrophyRoomTheme.primaryColor }
    var secondaryColor: Color { currentTrophyRoomTheme.secondaryColor }
    var accentColor: Color { currentTrophyRoomTheme.accentColor }
    var backgroundColor: Color { currentTrophyRoomTheme.backgroundColor }
    var textColor: Color { currentTrophyRoomTheme.textColor }
}