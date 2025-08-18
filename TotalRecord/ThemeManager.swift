import SwiftUI

class ThemeManager: ObservableObject {
    @Published var currentPalaceTheme: PalaceTheme
    
    init() {
        // Initialize with a default theme
        self.currentPalaceTheme = PalaceTheme.defaultTheme
    }
    
    // Convert palace color string to complete theme
    func generateThemeFromPalace(_ palace: Palace) -> PalaceTheme {
        let primaryColor = Color(palace.color)
        
        // Generate complementary colors based on primary
        let secondaryColor = primaryColor.opacity(0.7)
        let backgroundColor = primaryColor.opacity(0.1)
        
        // Choose accent color based on primary color for good contrast
        let accentColor: Color
        switch palace.color {
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
        let textColor: Color = palace.color == "yellow" || palace.color == "orange" ? .black : .white
        
        return PalaceTheme(
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
            accentColor: accentColor,
            backgroundColor: backgroundColor,
            textColor: textColor
        )
    }
    
    // Update theme based on available palaces
    func updateThemeFromPalaces(_ palaces: [Palace]) {
        if let firstPalace = palaces.first {
            currentPalaceTheme = generateThemeFromPalace(firstPalace)
        }
    }
    
    // Get current theme colors as computed properties
    var primaryColor: Color { currentPalaceTheme.primaryColor }
    var secondaryColor: Color { currentPalaceTheme.secondaryColor }
    var accentColor: Color { currentPalaceTheme.accentColor }
    var backgroundColor: Color { currentPalaceTheme.backgroundColor }
    var textColor: Color { currentPalaceTheme.textColor }
}