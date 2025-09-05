import SwiftUI

// Copied GameCards view from Components/AppGameCards.swift for local use
struct GameCardsSpeed: View {
    let emoji: String
    var color: Color
    var onTap: (() -> Void)? = nil
    
    @State private var appeared = false
    @State private var tapped = false

    var body: some View {
        Text(emoji)
            .font(.largeTitle)
            .frame(width: 100, height: 100)
            .background(color.opacity(0.1))
            .border(color.opacity(0.2))
            .cornerRadius(10)
            .shadow(radius: 4)
            .scaleEffect(tapped ? 1.2 : (appeared ? 1 : 0.5))
            .opacity(appeared ? 1 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    appeared = true
                }
            }
            .onTapGesture {
                withAnimation(.interpolatingSpring(stiffness: 200, damping: 5)) {
                    tapped = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation {
                        tapped = false
                    }
                }
                onTap?()
            }
    }
}

struct SpeedMatchView: View {
    let numberOfRounds: Int
    let timePerCard: Double
    let gameMode: GameMode
    var onRestart: (() -> Void)? = nil
    let allEmojis = ["🍎", "🍌", "🥝", "🌶️", "🍇", "🍉", "🍓", "🍒"]
    
    @State private var currentCard: String = ""
    @State private var previousCard: String = ""
    @State private var round: Int = 1
    @State private var score: Int = 0
    @State private var lives: Int = 3
    @State private var showFeedback: Bool = false
    @State private var feedbackText: String = ""
    @State private var timer: Timer? = nil
    @State private var timeLeft: Double = 0
    @State private var gameFinished: Bool = false
    @State private var inputDisabled: Bool = false
    @State private var gameTimer: Timer? = nil
    @State private var totalGameTime: Double = 0
    @State private var bestTime10: Double = UserDefaults.standard.double(forKey: "SpeedMatchBestTime10")
    @State private var bestTime15: Double = UserDefaults.standard.double(forKey: "SpeedMatchBestTime15")
    @State private var bestTime20: Double = UserDefaults.standard.double(forKey: "SpeedMatchBestTime20")
    @Environment(\.dismiss) private var dismiss
    
    func startRound() {
        if gameMode == .timed && round > numberOfRounds {
            gameTimer?.invalidate()
            gameFinished = true
            
            let currentBestTime = getBestTimeForRounds()
            if currentBestTime == 0 || totalGameTime < currentBestTime {
                saveBestTime(totalGameTime)
            }
            
            timer?.invalidate()
            return
        }
        previousCard = currentCard
        currentCard = allEmojis.randomElement()!
        showFeedback = false
        feedbackText = ""
        timeLeft = timePerCard
        inputDisabled = false
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { t in
            if timeLeft > 0.1 {
                timeLeft -= 0.1
            } else {
                t.invalidate()
                handleTimeout()
            }
        }
    }
    
    func getBestTimeForRounds() -> Double {
        switch numberOfRounds {
        case 10: return bestTime10
        case 15: return bestTime15
        case 20: return bestTime20
        default: return 0
        }
    }
    
    func saveBestTime(_ time: Double) {
        switch numberOfRounds {
        case 10:
            bestTime10 = time
            UserDefaults.standard.set(time, forKey: "SpeedMatchBestTime10")
        case 15:
            bestTime15 = time
            UserDefaults.standard.set(time, forKey: "SpeedMatchBestTime15")
        case 20:
            bestTime20 = time
            UserDefaults.standard.set(time, forKey: "SpeedMatchBestTime20")
        default: break
        }
    }
    
    func handleAnswer(_ isMatch: Bool) {
        inputDisabled = true
        timer?.invalidate()
        let correct = (currentCard == previousCard)
        
        if round == 1 { 
            feedbackText = "First card!"
        } else if correct == isMatch {
            score += 1
            feedbackText = "✅ Correct!"
        } else {
            // Wrong answer
            if gameMode == .infinite {
                lives -= 1
                if lives <= 0 {
                    feedbackText = "❌ Game Over! No lives left."
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        gameFinished = true
                    }
                    return
                } else {
                    feedbackText = "❌ Wrong! Lives: \(lives)"
                }
            } else {
                // Timed mode: add 2 seconds penalty
                totalGameTime += 2.0
                feedbackText = "❌ Wrong! +2s penalty"
            }
        }
        
        showFeedback = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            round += 1
            startRound()
        }
    }
    
    func handleTimeout() {
        inputDisabled = true
        
        if gameMode == .infinite {
            lives -= 1
            if lives <= 0 {
                feedbackText = "⏰ Time's up! Game Over!"
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    gameFinished = true
                }
                return
            } else {
                feedbackText = "⏰ Time's up! Lives: \(lives)"
            }
        } else {
            feedbackText = "⏰ Time's up!"
        }
        
        showFeedback = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            round += 1
            startRound()
        }
    }
    
    func restartGame() {
        round = 1
        score = 0
        lives = 3
        gameFinished = false
        totalGameTime = 0
        
        if gameMode == .timed {
            // Start game timer for timed mode
            gameTimer?.invalidate()
            gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                totalGameTime += 0.1
            }
        }
        
        startRound()
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.13), Color.purple.opacity(0.10)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            VStack(spacing: 24) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(500)
                    }
                    Spacer()
                    Text("Score: \(score)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                    if gameMode == .infinite {
                        HStack(spacing: 4) {
                            ForEach(0..<3, id: \.self) { index in
                                Image(systemName: index < lives ? "heart.fill" : "heart")
                                    .foregroundColor(index < lives ? .red : .gray)
                                    .font(.system(size: 16))
                            }
                        }
                        .padding(.leading, 8)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 24)
                Spacer().frame(height: 10)
                Text(gameMode == .infinite ? "Round \(round)" : "Round \(min(round, numberOfRounds))/\(numberOfRounds)")
                    .font(.headline)
                    .foregroundColor(.blue)
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.92))
                        .shadow(color: Color.blue.opacity(0.10), radius: 10, x: 0, y: 4)
                        .frame(height: 220)
                    VStack(spacing: 18) {
                        Text("Does this card match the previous one?")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        GameCardsSpeed(emoji: currentCard, color: Color.blue)
                            .frame(width: 100, height: 100)
                        if round > 1 {
                            Text("Previous: \(previousCard)")
                                .font(.title2)
                                .foregroundColor(.gray)
                        }
                        HStack(spacing: 32) {
                            Button(action: { handleAnswer(true) }) {
                                Text("Match")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 32)
                                    .padding(.vertical, 12)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            .disabled(inputDisabled)
                            Button(action: { handleAnswer(false) }) {
                                Text("No Match")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 32)
                                    .padding(.vertical, 12)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            .disabled(inputDisabled)
                        }
                        .padding(.top, 8)
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.18))
                                .frame(height: 10)
                            RoundedRectangle(cornerRadius: 8)
                                .fill(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .leading, endPoint: .trailing))
                                .frame(width: CGFloat(max(0, timeLeft / timePerCard)) * 220, height: 10)
                                .animation(.linear(duration: 0.1), value: timeLeft)
                        }
                        .frame(width: 220, height: 10)
                        if showFeedback {
                            Text(feedbackText)
                                .font(.headline)
                                .foregroundColor(feedbackText.contains("Correct") ? .green : (feedbackText.contains("Wrong") ? .red : .orange))
                                .padding(8)
                                .background(Color.white.opacity(0.7))
                                .cornerRadius(10)
                                .shadow(radius: 2)
                                .transition(.opacity)
                        }
                    }
                    .padding()
                }
                .padding(.horizontal)
                .frame(maxWidth: 420)
                Spacer()
                if gameFinished {
                    VStack(spacing: 16) {
                        Text("Game Over!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                        Text(gameMode == .infinite ? "Final Score: \(score)" : "Final Score: \(score) / \(numberOfRounds)")
                            .font(.title2)
                        if gameMode == .timed {
                            Text(String(format: "Time: %.1fs", totalGameTime))
                                .font(.title3)
                                .foregroundColor(.blue)
                            let bestTime = getBestTimeForRounds()
                            if bestTime > 0 {
                                Text(String(format: "Best Time: %.1fs", bestTime))
                                    .font(.title3)
                                    .foregroundColor(.green)
                            }
                        }
                        Button(action: { onRestart?(); restartGame() }) {
                            Text("Play Again")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 16)
                                .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                                .foregroundColor(.white)
                                .cornerRadius(16)
                                .shadow(radius: 5)
                        }
                    }
                }
            }
        }
        .onAppear {
            restartGame()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
}
