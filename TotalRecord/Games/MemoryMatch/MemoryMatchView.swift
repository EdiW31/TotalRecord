import SwiftUI
import UIKit

// Model for a single card, aici initalizam si starile, isfaceup si ismatched
struct Card: Identifiable {
    let id: Int
    let content: String
    var isFaceUp: Bool = false
    var isMatched: Bool = false
}

struct MemoryMatchView: View {
    let numberOfPairs: Int
    var onRestart: (() -> Void)? = nil
    let allEmojis = ["🍎", "🍌", "🥝", "🌶️", "🍇", "🍉", "🍓", "🍒"]
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    @State private var cards: [Card]
    @State private var indexOfFaceUpCard: Int? = nil
    @State private var isProcessing: Bool = false
    @State private var timeLeft: Int
    @State private var timer: Timer? = nil
    @State private var timerRun: Bool = true
    @State private var score: Int = 0
    @State private var gameFinished: Bool = false
    private var totalTime: Int

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeLeft > 0 && timerRun == true {
                timeLeft -= 1
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func flipCard(at index: Int) {
        guard !cards[index].isFaceUp, !cards[index].isMatched, !isProcessing, !gameFinished, timeLeft > 0 else { return }
        if let firstIndex = indexOfFaceUpCard {
            cards[index].isFaceUp = true
            isProcessing = true
            if cards[firstIndex].content == cards[index].content {
                cards[firstIndex].isMatched = true
                cards[index].isMatched = true
                indexOfFaceUpCard = nil
                isProcessing = false
                self.score += 10
                if cards.allSatisfy({ $0.isMatched }) {
                    gameFinished = true
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    cards[firstIndex].isFaceUp = false
                    cards[index].isFaceUp = false
                    indexOfFaceUpCard = nil
                    isProcessing = false
                }
            }
        } else {
            for i in cards.indices { cards[i].isFaceUp = false }
            cards[index].isFaceUp = true
            indexOfFaceUpCard = index
        }
    }

    func isGameFinished() -> Bool {
        self.timerRun = false
        stopTimer()
        return cards.allSatisfy { $0.isMatched }
    }

    init(numberOfPairs: Int, onRestart: (() -> Void)? = nil) {
        self.numberOfPairs = numberOfPairs
        self.onRestart = onRestart
        let selectedEmojis = Array(allEmojis.shuffled().prefix(numberOfPairs))
        let pairedEmojis = (selectedEmojis + selectedEmojis).shuffled()
        self._cards = State(initialValue: pairedEmojis.enumerated().map { Card(id: $0.offset, content: $0.element) })
        switch numberOfPairs {
        case 2: self._timeLeft = State(initialValue: 10)
        case 3: self._timeLeft = State(initialValue: 15)
        case 4: self._timeLeft = State(initialValue: 15)
        default: self._timeLeft = State(initialValue: 10)
        }
        switch numberOfPairs {
        case 2: self.totalTime = 10
        case 3: self.totalTime = 15
        case 4: self.totalTime = 15
        default: self.totalTime = 10
        }
    }

    var body: some View {
        ZStack {
            // Background image with blur
            Image("memory-match-background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .blur(radius: 16)
            VStack(spacing: 0) {
                // Header: Back arrow and progress bar (progress bar hidden on gameFinished)
                HStack(alignment: .center, spacing: 0) {
                    Button(action: { /* Add navigation logic here */ }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.18))
                            .clipShape(Circle())
                    }
                    if !gameFinished {
                        // Progress bar fills the rest of the space and reflects time left
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.25))
                                    .frame(height: 8)
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(LinearGradient(gradient: Gradient(colors: [Color.green, Color.teal]), startPoint: .leading, endPoint: .trailing))
                                    .frame(width: geometry.size.width * CGFloat(timeLeft) / CGFloat(totalTime), height: 8)
                                    .animation(.easeInOut(duration: 0.5), value: timeLeft)
                            }
                        }
                        .frame(height: 8)
                        .padding(.leading, 12)
                        .padding(.trailing, 8)
                        .frame(maxWidth: .infinity)
                    } else {
                        Spacer()
                    }
                }
                .padding(.leading, 8)
                .padding(.top, 60)
                .padding(.trailing, 16)
                .padding(.bottom, 24)
                // Use a fixed-height spacer to keep the bar at the same height regardless of game state
                Spacer().frame(height: 33)
                // Hide score and cards when game is finished
                if !gameFinished {
                    Text("\(score)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.18), radius: 4, x: 0, y: 2)
                        .padding(.bottom, 8)
                    ZStack {
                        LazyVGrid(columns: columns, spacing: 18) {
                            ForEach(cards.indices, id: \ .self) { index in
                                CardViewTest(card: cards[index])
                                    .onTapGesture {
                                        flipCard(at: index)
                                    }
                                    .disabled(cards[index].isFaceUp || cards[index].isMatched || isProcessing || gameFinished || timeLeft == 0)
                            }
                        }
                        .padding(24)
                    }
                    .frame(maxWidth: 420, maxHeight: 520)
                    .padding(.horizontal)
                }
                // Show confetti overlay and bottom message/button when game is finished
                if gameFinished {
                    ConfettiOverlay(score: score, onRestart: onRestart)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(.vertical, 16)
            // Hide confetti overlay when game is finished (remove ConfettiOverlay)
        }
        .background(Color.white.opacity(0.7))
        .onAppear {
            startTimer()
            UITabBar.appearance().unselectedItemTintColor = UIColor.white
        }
        .onDisappear {
            stopTimer()
            UITabBar.appearance().unselectedItemTintColor = nil
        }
        .onChange(of: gameFinished) {
            if gameFinished {
                stopTimer()
            }
        }
        .onChange(of: timeLeft) {
            if timeLeft == 0 {
                stopTimer()
            }
        }
    }
}

struct CardViewTest: View {
    let card: Card
    var body: some View {
        ZStack {
            if card.isFaceUp || card.isMatched {
                // Show emoji on a color-themed background
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.85), Color.teal.opacity(0.85)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .shadow(radius: 6)
                Text(card.content)
                    .font(.system(size: 44))
            } else {
                // Show the card background image when face down
                Image("cardsbackground")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 100)
                    .cornerRadius(16)
                    .clipped()
                    .shadow(radius: 6)
            }
        }
        .frame(height: 100)
        .rotation3DEffect(
            .degrees(card.isFaceUp || card.isMatched ? 0 : 180),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.easeInOut, value: card.isFaceUp)
    }
}

// Confetti overlay view
struct ConfettiOverlay: View {
    let score: Int
    var onRestart: (() -> Void)?
    @State private var animate = false
    let confettiColors: [Color] = [.red, .yellow, .blue, .green, .purple, .orange, .pink]
    var body: some View {
        ZStack {
            // Simple confetti animation
            GeometryReader { geo in
                ForEach(0..<30, id: \ .self) { i in
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
            VStack(spacing: 24) {
                Spacer()
                // Smiley face icon
                Image(systemName: "face.smiling")
                    .font(.system(size: 48))
                    .foregroundColor(.white)
                // Congratulatory message
                Text("Good job matching\nall the pairs!")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                // Score label and value
                VStack(spacing: 2) {
                    Text("Your Score")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("\(score)")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                // Large white button with black text
                Spacer()
                Button(action: { onRestart?() }) {
                    Text("Try again")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.white)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 140) // Raise the button even higher above the tab bar
            }
            .frame(maxWidth: .infinity)
        }
        .ignoresSafeArea()
        .onAppear { animate = true }
    }
}

