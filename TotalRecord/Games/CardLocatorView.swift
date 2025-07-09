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
        VStack(spacing: 32) {
            Text("Card Locator Game")
                .font(.largeTitle)
                .fontWeight(.bold)
            if(!waitingPhase){
                Text("Score 💯: \(score)")
            }
            if !message.isEmpty {
                Text(message)
                    .font(.headline)
                    .foregroundColor(.red)
            }
            if waitingPhase {
                Spacer()
                    ZStack {
                        Circle()
                            .stroke(Color.blue.opacity(0.3), lineWidth: 16)
                            .frame(width: 120, height: 120)
                        Circle()
                            .trim(from: 0, to: CGFloat(waitingTimeRemaining) / 10.0)
                            .stroke(Color.blue, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .frame(width: 120, height: 120)
                            .animation(.linear(duration: 1), value: waitingTimeRemaining)
                        Text("\(waitingTimeRemaining)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                    }
                    VStack{
                        Text("Now we need to wait for this timer to get down to 0.").font(.title2)
                    }
                Spacer()
            } else {
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
                                                return .yellow // Highlight targets during memorization
                                            } else if let fb = feedback[index] {
                                                return fb
                                            } else if memorizationPhase {
                                                return .green // Non-targets during memorization
                                            } else {
                                                return .blue
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
                                    }
                                }
                            }
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
                .padding()
            }
            if(GameFinished){
                Button(action: { onRestart?() }) {
                    Text("Start a new Game!")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
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