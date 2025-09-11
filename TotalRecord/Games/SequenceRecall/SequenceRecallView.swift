import SwiftUI
struct SequenceRecallView: View {
    @Binding var sequenceLength: Int
    var onRestart: (() -> Void)? = nil
    let gameMode: GameMode

    let allEmojis = ["🍎", "🍌", "🥝", "🌶️", "🍇", "🍉"]

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    // Int Variables
    @State private var sequence: [Int] = []
    @State private var userInput: [Int] = []

    @State private var score: Int = 0
    @State private var timeRemaining: Int = 10
    @State private var level: Int = 1
    @State private var lives: Int = 3
    @State private var pressedWrongCardCount: Int = 0
    @State private var timeForRounds: Int = 4
    @State private var nrOfRoundsToWin: Int = 3
    @State private var correctSequences: Int = 0

    // Bool Variables
    @State private var isGameOver: Bool = false
    @State private var isTimerRunning: Bool = false
    @State private var isGameStarted: Bool = false
    @State private var showSequence: Bool = true;

    // Other Variables
    @State private var timer: Timer?    
    @State private var message: String = ""

    //Statistics tracking variables
    @State private var gameStartTime: Date = Date()
    @State private var levelsCompleted: Int = 0
    @State private var showFinishPage: Bool = false
    @State private var timeTaken: TimeInterval = 0
    @State private var gameWon: Bool = false
    @Environment(\.dismiss) private var dismiss


    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.pink.opacity(0.13), Color.purple.opacity(0.10)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 28) {
                // Header
                VStack(spacing: 6) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.pink)
                        .shadow(radius: 8)
                    Text("Sequence Recall")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.pink)
                        .shadow(color: .pink.opacity(0.10), radius: 4, x: 0, y: 2)
                }
                // Info Bar
                HStack(spacing: 24) {
                    VStack(spacing: 2) {
                        Text("Level")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(level)")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    VStack(spacing: 2) {
                        Text("Score")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(score)")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    if gameMode == .timed {
                    VStack(spacing: 2) {
                        Text("Time")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(timeRemaining)s")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(timeRemaining <= 3 ? .red : .primary)
                    }
                    }
                    if gameMode == .infinite {
                        VStack(spacing: 2) {
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
                    }
                    Spacer()
                    Button(action: { onRestart?() }) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.pink, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityLabel("Restart Game")
                }
                .padding(.horizontal)
                if !message.isEmpty {
                    Text(message)
                        .font(.headline)
                        .foregroundColor(.pink)
                        .padding(.vertical, 4)
                        .transition(.opacity)
                }
                // Main Card Area
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.92))
                        .shadow(color: .pink.opacity(0.10), radius: 10, x: 0, y: 4)
                        .frame(height: 420)
                    VStack(spacing: 18) {
                        if showSequence {
                            Text("Memorize the sequence!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(sequence.indices, id: \.self) { i in
                                    GameCards(emoji: allEmojis[sequence[i]], color: .pink)
                                }
                            }
                        } else {
                            Text("Tap the emojis in order")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(allEmojis.indices, id: \.self) { i in
                                    GameCards(emoji: allEmojis[i], color: .pink, onTap: {
                                        handleUserInput(index: i)
                                    })
                                }
                            }
                            // User Input Display
                            VStack(spacing: 4) {
                                Text("Your Input")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(userInput.map { allEmojis[$0] }.joined(separator: " "))
                                    .font(.title)
                                    .fontWeight(.medium)
                                    .padding(.vertical, 4)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.gray.opacity(0.08))
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                }
                .padding(.horizontal)
                .frame(maxWidth: 420)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(.vertical, 10)
            
            if showFinishPage {
                FinishGamePage(
                    stats: createGameStats(),
                    gameWon: gameWon,
                    onPlayAgain: {
                        showFinishPage = false
                        StartGame()
                    },
                    onMainMenu: {
                        dismiss()
                    }
                )
                .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.easeInOut, value: showSequence)
        .onAppear{
            StartGame()
        }
    }

    func StartGame(){
        sequence = Array(0..<sequenceLength).map { _ in Int.random(in: 0..<allEmojis.count) }
        userInput = []
        showSequence = true

        //Reset statistics
        gameStartTime = Date()
        levelsCompleted = 0
        showFinishPage = false
        gameWon = false
        score = 0
        level = 1

        timeTaken = 0
        if gameMode == .timed {
            timeRemaining = timeForRounds 
            lives = 0
            startGameTimer()
        }
        if gameMode == .infinite {
            lives = 3
            timeRemaining = 0 
        }
        startSequenceTimer()
    }
    
    func createGameStats() -> GameStats {
        let totalTime = Date().timeIntervalSince(gameStartTime)
        let stats = GameStats(
            score: score,
            timeTaken: totalTime,
            extraStat: levelsCompleted,
            gameMode: gameMode,
            gameType: .sequenceRecall,
            date: Date()
        )
        
        // Save comprehensive game statistics
        ScoreStorage.shared.saveGameStats(stats)
        
        return stats
    }
    
    func showFinishGamePage() {
        // Track achievement progress
        let accuracy = Double(correctSequences) / Double(sequenceLength) * 100
        let extraStat = sequenceLength // Use sequence length for milestone achievements
        let timeTaken = Date().timeIntervalSince(gameStartTime)
        
        // Use shared instance
        TrophyRoomStorage.shared.trackGameCompletion(
            gameType: .sequenceRecall,
            score: score,
            time: timeTaken,
            accuracy: accuracy,
            extraStat: extraStat
        )
        
        showFinishPage = true
    }
    
    func startGameTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                gameWon = false
                showFinishGamePage()
            }
        }
    }

    func startSequenceTimer() {
        showSequence = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 1 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                showSequence = false // Hide the sequence
            }
        }
    }

    func handleUserInput(index: Int) {
        if userInput.count < sequence.count {
            userInput.append(index)
            
            let currentInputIndex = userInput.count - 1
            if userInput[currentInputIndex] != sequence[currentInputIndex] {
                // wrong tap 
                userInput = []
                
                if gameMode == .infinite {
                    pressedWrongCardCount += 1
                    if pressedWrongCardCount >= 3 {
                        pressedWrongCardCount = 0
                        lives -= 1
                    }
                    
                    // check game over
                    if lives <= 0 {
                        message = "Game Over! No lives left."
                        gameWon = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            message = ""
                            showFinishGamePage()
                        }
                    } 
                } else if gameMode == .timed {
                    // timed mode wrong input is game over
                    message = "Wrong! Game Over."
                    gameWon = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        message = ""
                        showFinishGamePage()
                    }
                }
                return
            } else if userInput.count == sequence.count {
                correctSequences += 1
            }
            
            if userInput.count == sequence.count {
                message = "Congrats lvl \(level) is Done!"
                pressedWrongCardCount = 0
                sequenceLength += 1
                level += 1
                score += 15
                levelsCompleted += 1
                
                if gameMode == .timed && level > nrOfRoundsToWin {
                    gameWon = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        message = ""
                        showFinishGamePage()
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        message = ""
                        StartGame()
                    }
                }
            }
        }
    }
}