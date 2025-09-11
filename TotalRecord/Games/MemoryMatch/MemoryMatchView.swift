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
    let gameMode: GameMode

    @State private var cards: [Card]
    @State private var timer: Timer? = nil
    @Environment(\.dismiss) private var dismiss

    // Int Variables
    @State private var indexOfFaceUpCard: Int? = nil
    @State private var timeLeft: Int
    @State private var score: Int = 0
    @State private var pressedWrongCardCount: Int = 0
    @State private var lives: Int = 3
    @State private var correctMatches: Int = 0
    private var totalTime: Int

    // Bool Variables
    @State private var isProcessing: Bool = false
    @State private var timerRun: Bool = true
    @State private var gameFinished: Bool = false
    
    // Statistics tracking variables
    @State private var gameStartTime: Date = Date()
    @State private var correctStreaks: Int = 0
    @State private var currentStreak: Int = 0
    @State private var showFinishPage: Bool = false
    

    
    func startGame() {
        score = 0
        gameFinished = false
        isProcessing = false
        indexOfFaceUpCard = nil
        showFinishPage = false
        
        // Reset statistics
        gameStartTime = Date()
        correctStreaks = 0
        currentStreak = 0
        
        if gameMode == .infinite {
            lives = 3
            timeLeft = 0 
            timerRun = false
            stopTimer() 
            
            // Initialize cards for infinite mode
            let selectedEmojis = Array(allEmojis.shuffled().prefix(numberOfPairs))
            let pairedEmojis = (selectedEmojis + selectedEmojis).shuffled()
            cards = pairedEmojis.enumerated().map { Card(id: $0.offset, content: $0.element) }
            
        } else {
            lives = 0 // No lives for timed mode
            timeLeft = totalTime
            timerRun = true
            startTimer()
            
            let selectedEmojis = Array(allEmojis.shuffled().prefix(numberOfPairs))
            let pairedEmojis = (selectedEmojis + selectedEmojis).shuffled()
            cards = pairedEmojis.enumerated().map { Card(id: $0.offset, content: $0.element) }
        }
    }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeLeft > 0 && timerRun == true {
                timeLeft -= 1
            }
        }
    }

    func stopTimer() {
        timer?.invalidate() //.invalidate() face ca orice alt timer sa fie oprit
        timer = nil
    }

    func flipCard(at index: Int) {
        let canFlip = !cards[index].isFaceUp && !cards[index].isMatched && !isProcessing && !gameFinished
        
        if gameMode == .timed {
            guard canFlip && timeLeft > 0 else { return }
        } else {
            guard canFlip && lives > 0 else { return }
        }
        if let firstIndex = indexOfFaceUpCard {
            cards[index].isFaceUp = true
            isProcessing = true
            if cards[firstIndex].content == cards[index].content {
                cards[firstIndex].isMatched = true
                cards[index].isMatched = true
                indexOfFaceUpCard = nil
                isProcessing = false
                self.score += 10
                pressedWrongCardCount = 0
                currentStreak += 1
                correctMatches += 1
                if cards.allSatisfy({ $0.isMatched }) {
                    if isGameFinished() {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            gameFinished = true
                            showFinishGamePage()
                        }
                    }
                }
            } else {
                if currentStreak > 0 {
                    correctStreaks += currentStreak
                    currentStreak = 0
                }
                
                if gameMode == .infinite {
                    pressedWrongCardCount += 1
                    if pressedWrongCardCount >= 3 {
                        lives -= 1
                        pressedWrongCardCount = 0
                    }
                    
                    // Check if game should end due to no lives left
                    if lives <= 0 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            gameFinished = true
                            showFinishGamePage()
                        }
                    }
                }
                
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

    func startNewRound() {
        let selectedEmojis = Array(allEmojis.shuffled().prefix(numberOfPairs))
        let pairedEmojis = (selectedEmojis + selectedEmojis).shuffled()
        cards = pairedEmojis.enumerated().map { Card(id: $0.offset, content: $0.element) }
        indexOfFaceUpCard = nil
        isProcessing = false
    }
    
    func isGameFinished() -> Bool {
        if gameMode == .timed {
            self.timerRun = false
            stopTimer()
            return cards.allSatisfy { $0.isMatched }
        }
        if gameMode == .infinite {
            if cards.allSatisfy({ $0.isMatched }) {
                startNewRound() 
                return false 
            }
            return lives <= 0
        }
        return false
    }
    
    func createGameStats() -> GameStats {
        let totalTime = Date().timeIntervalSince(gameStartTime)
        let stats = GameStats(
            score: score,
            timeTaken: totalTime,
            extraStat: correctStreaks + currentStreak, // Include current streak if game ends
            gameMode: gameMode,
            gameType: .memoryMatch,
            date: Date()
        )
        
        // Save comprehensive game statistics
        ScoreStorage.shared.saveGameStats(stats)
        
        return stats
    }
    
    func showFinishGamePage() {
        // when the game is finished, track the achievements and show the finish page
        let accuracy = Double(correctMatches) / Double(numberOfPairs) * 100
        let extraStat = correctStreaks + currentStreak // Total streaks achieved
        let timeTaken = Date().timeIntervalSince(gameStartTime)
        
        // print("🎮 MEMORY MATCH GAME FINISHED:")
        // print("   Score: \(score)")
        // print("   Time: \(timeTaken) seconds")
        // print("   Accuracy: \(accuracy)%")
        // print("   Extra Stats (streaks): \(extraStat)")
        // print("   Correct Matches: \(correctMatches)")
        // print("   Number of Pairs: \(numberOfPairs)")
        
        // Use shared instance
        TrophyRoomStorage.shared.trackGameCompletion(
            gameType: .memoryMatch,
            score: score,
            time: timeTaken,
            accuracy: accuracy,
            extraStat: extraStat
        )
        
        showFinishPage = true
    }

    init(numberOfPairs: Int, gameMode: GameMode, onRestart: (() -> Void)? = nil) {
        self.numberOfPairs = numberOfPairs
        self.gameMode = gameMode
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
            // Background image fills the entire screen, edge-to-edge
            Image("memory-match-background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .blur(radius: 16)
            VStack(spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    Button(action: { dismiss() }) {
                        HStack(alignment: .center, spacing: 0) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                        }
                        .padding(0)
                        .frame(width: 34, height: 34, alignment: .center)
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(500)
                    }
                    if !gameFinished {
                        if gameMode == .timed {
                            // Show timer progress bar for timed mode
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white.opacity(0.25))
                                        .frame(height: 8)
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(LinearGradient(gradient: Gradient(colors: [Color.green, Color.teal]), startPoint: .leading, endPoint: .trailing))
                                        .frame(width: max(geometry.size.width * CGFloat(timeLeft) / CGFloat(totalTime), 0.0), height: 8)
                                        .animation(.easeInOut(duration: 1.0), value: timeLeft)
                                }
                            }
                            .frame(height: 8)
                            .padding(.leading, 12)
                            .padding(.trailing, 8)
                            .frame(maxWidth: .infinity)
                        } else {
                            // Show lives for infinite mode
                            HStack(spacing: 8) {
                                ForEach(0..<3, id: \.self) { index in
                                    Image(systemName: index < lives ? "heart.fill" : "heart")
                                        .foregroundColor(index < lives ? .red : .gray)
                                        .font(.system(size: 20))
                                }
                            }
                            .padding(.leading, 12)
                            .padding(.trailing, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    } else {
                        Spacer()
                    }
                }
                .padding(.leading, 8)
                .padding(.top, 60)
                .padding(.trailing, 16)
                .padding(.bottom, 24)
                Spacer().frame(height: 33)
                if !gameFinished {
                    HStack {
                        Spacer()
                        Text("\(score)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.18), radius: 4, x: 0, y: 2)
                        Spacer()
                    }
                    .padding(.bottom, 8)
                }
                ZStack {
                if !gameFinished {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(cards) { card in
                                MemoryGameCard(card: card)
                                    .onTapGesture {
                                        if let idx = cards.firstIndex(where: { $0.id == card.id }) {
                                            flipCard(at: idx)
                                        }
                                    }
                                    .disabled(card.isFaceUp || card.isMatched || isProcessing || gameFinished || 
                                             (gameMode == .timed && timeLeft == 0) || 
                                             (gameMode == .infinite && lives <= 0))
                            }
                        }
                        .padding(.horizontal, 4)
                    .frame(maxWidth: 420, maxHeight: 520)
                    .padding(.top, 12)
                    .padding(.bottom, 56) 
                    .padding(.horizontal, 0)
                        .transition(.opacity)
                }
                }
                .animation(.easeInOut(duration: 0.5), value: gameFinished)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            // Finish Game Page
            if showFinishPage {
                FinishGamePage(
                    stats: createGameStats(),
                    onPlayAgain: { 
                        showFinishPage = false
                        startGame()
                    },
                    onMainMenu: { 
                        dismiss()
                    }
                )
                .transition(.opacity.combined(with: .scale))
            }
        }
        .background(Color.clear) // Ensure no default background is rendered
        .onAppear {
            startGame()
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
                if gameMode == .timed {
                    // In timed mode, game ends when time runs out
                    gameFinished = true
                    showFinishGamePage()
                }
            }
        }
        .animation(.easeInOut(duration: 0.5), value: gameFinished || 
                   (gameMode == .timed && timeLeft == 0) || 
                   (gameMode == .infinite && lives <= 0))
    }
}

struct MemoryGameCard: View {
    let card: Card
    var body: some View {
        ZStack {
            if card.isFaceUp || card.isMatched {
                // Show emoji on a yellow-themed background
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.yellow.opacity(0.92), Color.orange.opacity(0.85)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .shadow(radius: 8)
                // Dashed border
                RoundedRectangle(cornerRadius: 20)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [7]))
                    .foregroundColor(Color.black.opacity(0.3))
                    .padding(6)
                Text(card.content)
                    .font(.system(size: 54))
            } else {
                // Show the card background image when face down
                Image("cardsbackground")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 180, height: 140)
                    .cornerRadius(20)
                    .clipped()
                    .shadow(radius: 8)
                // Dashed border
                RoundedRectangle(cornerRadius: 20)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [7]))
                    .foregroundColor(Color.black.opacity(0.3))
                    .padding(6)
            }
        }
        .frame(width: 180, height: 140)
        .rotation3DEffect(
            .degrees(card.isFaceUp || card.isMatched ? 0 : 180),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.easeInOut, value: card.isFaceUp)
    }
}

// Confetti overlay done for Memory game (can be used as a component if needed, waiting for the other games design)
struct ConfettiOverlay: View {
    let score: Int
    var onRestart: (() -> Void)?
    @State private var animate = false
    let confettiColors: [Color] = [.red, .yellow, .blue, .green, .purple, .orange, .pink]
    var body: some View {
        ZStack {
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

struct GameLostView: View {
    let score: Int
    var onRestart: (() -> Void)?
    var body: some View {
        ZStack(alignment: .center) {
            // Fully fullscreen black transparent background
            Color.black.opacity(0.78).ignoresSafeArea()
            VStack(spacing: 32) {
                Spacer()
                Image(systemName: "hourglass")
                    .font(.system(size: 70, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
                Text("Time's up!")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                Text("Your Score")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.85))
                Text("\(score)")
                    .font(.system(size: 54, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Button(action: { onRestart?() }) {
                    Text("Try Again")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .padding(.horizontal, 48)
                        .padding(.vertical, 18)
                        .background(Color.white)
                        .cornerRadius(18)
                        .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
                }
                .padding(.top, 12)
                Spacer()
            }
            .multilineTextAlignment(.center)
        }
    }
}

// Add VisualEffectBlur for glassmorphism
import SwiftUI
import UIKit
struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}