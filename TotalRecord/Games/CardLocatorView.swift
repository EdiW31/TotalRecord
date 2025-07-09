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
    var numberOfTargets: Int
    let gridRows = 4
    let gridColumns = 3
    let allEmojis = ["🍎", "🍌", "🌶️", "🍇", "🍉", "🍓", "🍒", "🍍", "🍍", "🍉", "🍓", "🍒"] // 12 emojis for 4x3

    @State private var targetCards: [Int] = [] // store indices of target cards
    @State private var memorizationPhase = true
    @State private var revealed: [Bool] = Array(repeating: false, count: 12)
    @State private var feedback: [Color?] = Array(repeating: nil, count: 12)
    @State private var message: String = ""
    @State private var seeCardsTimer: Timer? = nil
    @State private var waitingTimer: Timer? = nil
    @State private var waitingPhase: Bool = false
    @State private var waitingTimeRemaining: Int = 10
    @State private var score: Int = 0
    @State private var GameFinished = false;

    var body: some View {
        ZStack {
            // Modern gradient background
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.18), Color.purple.opacity(0.18)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 4) {
                    Text("Card Locator")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                        .shadow(color: .blue.opacity(0.12), radius: 4, x: 0, y: 2)
                    if !waitingPhase {
                        HStack(spacing: 12) {
                            Label("Score", systemImage: "star.fill")
                                .font(.title3)
                                .foregroundColor(.purple)
                            Text("\(score)")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        .padding(.top, 2)
                    }
                }
                // Feedback message
                if !message.isEmpty {
                    Text(message)
                        .font(.headline)
                        .foregroundColor(message.contains("Wrong") ? .red : .green)
                        .padding(8)
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(10)
                        .shadow(radius: 2)
                        .transition(.opacity)
                }
                // Timer or Game Grid
                if waitingPhase {
                    Spacer()
                    ZStack {
                        Circle()
                            .stroke(Color.blue.opacity(0.18), lineWidth: 18)
                            .frame(width: 140, height: 140)
                        Circle()
                            .trim(from: 0, to: CGFloat(waitingTimeRemaining) / 10.0)
                            .stroke(AngularGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), center: .center), style: StrokeStyle(lineWidth: 14, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .frame(width: 140, height: 140)
                            .animation(.linear(duration: 1), value: waitingTimeRemaining)
                        Text("\(waitingTimeRemaining)")
                            .font(.system(size: 54, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                            .shadow(radius: 2)
                    }
                    .padding(.bottom, 12)
                    Text("Get ready! The game will start soon.")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 32)
                    Spacer()
                } else {
                    // Card grid in a card-like container
                    ZStack {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.white.opacity(0.85))
                            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                        VStack(spacing: 0) {
                            GeometryReader { geometry in
                                let cardWidth = geometry.size.width / CGFloat(gridColumns)
                                let cardHeight = geometry.size.height / CGFloat(gridRows)
                                VStack(spacing: 0) {
                                    ForEach(0..<gridRows, id: \.self) { row in
                                        HStack(spacing: 0) {
                                            ForEach(0..<gridColumns, id: \.self) { col in
                                                let index = row * gridColumns + col
                                                if index < allEmojis.count {
                                                    let isTarget = targetCards.contains(index)
                                                    let showEmoji = memorizationPhase || revealed[index]
                                                    let cardColor: Color = {
                                                        if memorizationPhase && isTarget {
                                                            return Color.pink // Highlight targets to memorize
                                                        } else if let fb = feedback[index] {
                                                            return fb == .green ? Color.green : Color.red // Green for correct, red for incorrect
                                                        } else if memorizationPhase {
                                                            return Color.purple // Non-targets during memorization
                                                        } else {
                                                            return Color.blue // Default after memorization
                                                        }
                                                    }()
                                                    GameCards(
                                                        emoji: showEmoji ? allEmojis[index] : "?",
                                                        color: cardColor,
                                                        onTap: {
                                                            handleTap(index: index)
                                                        }
                                                    )
                                                    .frame(width: cardWidth, height: cardHeight)
                                                    .disabled(memorizationPhase || revealed[index])
                                                    .padding(6)
                                                }
                                            }
                                        }
                                    }
                                }
                                .frame(width: geometry.size.width, height: geometry.size.height)
                            }
                        }
                        .padding(36) // Increased padding for a more spacious look
                    }
                    .frame(maxWidth: 420, maxHeight: 520)
                    .padding(.horizontal)
                }
                // Play Again / Restart Button
                if GameFinished {
                    Button(action: { onRestart?() }) {
                        Text("Start a new Game!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 16)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(radius: 5)
                    }
                    .padding(.top, 12)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(.vertical, 16)
        }
        .background(Color.white.opacity(0.7))
        .onAppear {
            startGame()
        }
    }

    func startGame() {
        // Pick random target card indices
        targetCards = Array(0..<allEmojis.count).shuffled().prefix(numberOfTargets).sorted()
        revealed = Array(repeating: false, count: allEmojis.count)
        feedback = Array(repeating: nil, count: allEmojis.count)
        message = ""
        memorizationPhase = true
        GameFinished = false
        waitingPhase = false
        // Show targets for 2 seconds, then hide
        seeCardsTimer?.invalidate()
        seeCardsTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            memorizationPhase = false
            waitingPhase = true
            waitingTimeRemaining = 10
            startWaitingTimer()
        }
    }

    func startWaitingTimer() {
        waitingTimer?.invalidate()
        waitingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if waitingTimeRemaining > 1 {
                waitingTimeRemaining -= 1
            } else {
                waitingTimer?.invalidate()
                waitingPhase = false
            }
        }
    }

    func handleTap(index: Int) {
        guard !memorizationPhase, !revealed[index], !GameFinished, !waitingPhase else { return }
        revealed[index] = true
        if targetCards.contains(index) {
            feedback[index] = .green
            // Check if all targets found
            if targetCards.allSatisfy({ revealed[$0] }) {
                GameFinished = true;
                message = "You found all targets!"
                if(numberOfTargets==2){
                    score += 50
                }
                if(numberOfTargets==3){
                    score += 60
                }
                if(numberOfTargets==5){
                    score += 100
                }
            }
        } else {
            feedback[index] = .red
            message = "Wrong card! Try again or restart."
            if(numberOfTargets==2){
                    score -= 10
                }
                if(numberOfTargets==3){
                    score += 30
                }
                if(numberOfTargets==5){
                    score += 50
                }
        }
    }
}
