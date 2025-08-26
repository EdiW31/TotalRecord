import SwiftUI

struct PalaceTheme {
    let primaryColor: Color      // Main palace color
    let secondaryColor: Color    // Complementary color
    let accentColor: Color       // High-contrast accent
    let backgroundColor: Color    // Background variant
    let textColor: Color         // Text color for readability
    
    // Default theme for when no palace is unlocked
    static let defaultTheme = PalaceTheme(
        primaryColor: .purple,
        secondaryColor: .purple.opacity(0.7),
        accentColor: .orange,
        backgroundColor: .purple.opacity(0.1),
        textColor: .black
    )
}