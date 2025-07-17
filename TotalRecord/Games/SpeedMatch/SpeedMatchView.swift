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
    var onRestart: (() -> Void)? = nil
    let allEmojis = ["🍎", "🍌", "🥝", "🌶️", "🍇", "🍉", "🍓", "🍒"]
    
    @State private var currentCard: String = ""
    @State private var previousCard: String = ""
    @State private var round: Int = 1
    @State private var score: Int = 0
    @State private var showFeedback: Bool = false
    @State private var feedbackText: String = ""
    @State private var timer: Timer? = nil
    @State private var timeLeft: Double = 0
    @State private var gameFinished: Bool = false
    @State private var inputDisabled: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    func startRound() {
        if round > numberOfRounds {
            gameFinished = true
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
    
    func handleAnswer(_ isMatch: Bool) {
        inputDisabled = true
        timer?.invalidate()
        let correct = (currentCard == previousCard)
        if round == 1 { // No match possible on first round
            feedbackText = "First card!"
        } else if correct == isMatch {
            score += 1
            feedbackText = "✅ Correct!"
        } else {
            feedbackText = "❌ Wrong!"
        }
        showFeedback = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            round += 1
            startRound()
        }
    }
    
    func handleTimeout() {
        inputDisabled = true
        feedbackText = "⏰ Time's up!"
        showFeedback = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            round += 1
            startRound()
        }
    }
    
    func restartGame() {
        round = 1
        score = 0
        gameFinished = false
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
                }
                .padding(.horizontal)
                .padding(.top, 24)
                Spacer().frame(height: 10)
                Text("Round \(min(round, numberOfRounds))/\(numberOfRounds)")
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
                        // Use GameCards from Components
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
                        Text("Final Score: \(score) / \(numberOfRounds)")
                            .font(.title2)
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
