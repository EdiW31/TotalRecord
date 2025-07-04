// MARK: - Card Locator Game Color Palette
// Primary:    Color.blue
// Accent:     Color.purple
// Highlight:  Color.green
// Error:      Color.red
// Background: Color.white.opacity(0.7) or LinearGradient([Color.blue.opacity(0.2), Color.purple.opacity(0.1)])
// Card Face:  Color.blue.opacity(0.1)
// Card Border: Color.blue.opacity(0.2)
// Use these colors for a consistent, modern look throughout the Card Locator game.

import SwiftUI

struct CardLocatorView: View {
    var onRestart: (() -> Void)? = nil
    let gridSize = 3

    let allEmojis = ["🍎", "🍌", "🌶️", "🍇", "🍉", "🍓", "🍒", "🍍","🍍"] // 9 emojis for 3x3

    
    var body: some View {
        VStack(spacing: 32) {
            Text("Card Locator Game")
                .font(.largeTitle)
                .fontWeight(.bold)
            GeometryReader { geometry in
                let cardSize = min(geometry.size.width, geometry.size.height) / CGFloat(gridSize)
                VStack(spacing: 0) {
                    ForEach(0..<gridSize, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<gridSize, id: \.self) { col in
                                let index = row * gridSize + col
                                if index < allEmojis.count {
                                    GameCards(
                                        emoji: allEmojis[index],
                                        color: .blue,
                                        onTap: {
                                            print("Tapped card at \(index)")
                                        }
                                    )
                                    .frame(width: cardSize, height: cardSize)
                                }
                            }
                        }
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        .padding()
            Button(action: { onRestart?() }) {
                Text("Restart Setup")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color.white.opacity(0.7))
    }
}