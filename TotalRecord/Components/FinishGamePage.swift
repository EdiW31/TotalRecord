import SwiftUI

struct FinishGamePage: View {
    let stats: GameStats
    let onPlayAgain: () -> Void
    let onMainMenu: () -> Void
    let gameTitle: String
    let extraStatTitle: String
    let extraStatValue: Int
    let bestScore: Int
    let bestTime: TimeInterval
    let gameWon: Bool
    
    @State private var animate = false
    let confettiColors: [Color] = [.red, .yellow, .blue, .green, .purple, .orange, .pink]
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .blur(radius: 20)
            
            if gameWon {
                GeometryReader { geo in
                    ForEach(0..<30, id: \.self) { i in
                        Circle()
                            .fill(confettiColors.randomElement() ?? .blue)
                            .frame(width: CGFloat.random(in: 8...18), height: CGFloat.random(in: 8...18))
                            .position(x: CGFloat.random(in: 0...geo.size.width), y: animate ? geo.size.height + 40 : CGFloat.random(in: 0...geo.size.height/2))
                            .opacity(0.7)
                            .animation(
                                .easeIn(duration: Double.random(in: 1.2...2.2)).repeatForever(autoreverses: false),
                                value: animate
                            )
                    }
                }
                .allowsHitTesting(false)
            }
            
            VStack(spacing: 24) {
                Spacer()
                
                VStack(spacing: 12) {
                    Image(systemName: gameWon ? "face.smiling" : "face.dashed")
                        .font(.system(size: 60))
                        .foregroundColor(gameWon ? .yellow : .red)
                        .shadow(radius: 10)
                    
                    Text(gameTitle)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                    
                    Text(gameWon ? "Complete!" : "Game Over")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(gameWon ? .green : .red)
                        .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 1)
                }
                
                VStack(spacing: 15) {
                    StatRow(title: "Final Score", value: "\(stats.score)")
                    StatRow(title: "Time Taken", value: formatTime(stats.timeTaken))
                    StatRow(title: extraStatTitle, value: "\(extraStatValue)")
                    StatRow(title: "Best Score", value: "\(bestScore)")
                    StatRow(title: "Best Time", value: formatTime(bestTime))
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: onPlayAgain) {
                        Text("Play Again")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.white, Color.white.opacity(0.9)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                    }
                    
                    Button(action: onMainMenu) {
                        Text("Main Menu")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                                    )
                            )
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .ignoresSafeArea()
        .onAppear { 
            animate = true 
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
            Spacer()
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
        }
    }
}
extension FinishGamePage {
    init(stats: GameStats, gameWon: Bool = true, onPlayAgain: @escaping () -> Void, onMainMenu: @escaping () -> Void) {
        self.stats = stats
        self.gameWon = gameWon
        self.onPlayAgain = onPlayAgain
        self.onMainMenu = onMainMenu
        
        switch stats.gameType {
        case .memoryMatch:
            self.gameTitle = "Memory Match"
            self.extraStatTitle = "Correct Streaks"
            self.extraStatValue = stats.extraStat
        case .sequenceRecall:
            self.gameTitle = "Sequence Recall"
            self.extraStatTitle = "Levels Completed"
            self.extraStatValue = stats.extraStat
        case .cardLocator:
            self.gameTitle = "Card Locator"
            self.extraStatTitle = "Targets Found"
            self.extraStatValue = stats.extraStat
        case .speedMatch:
            self.gameTitle = "Speed Match"
            self.extraStatTitle = "Rounds Completed"
            self.extraStatValue = stats.extraStat
        case .general:
            self.gameTitle = "General"
            self.extraStatTitle = "General"
            self.extraStatValue = stats.extraStat
        }
        
        // get best score from storage
        self.bestScore = ScoreStorage.shared.getBestScore(for: stats.gameType, mode: stats.gameMode)
        self.bestTime = ScoreStorage.shared.getBestTime(for: stats.gameType, mode: stats.gameMode)
    }
}
