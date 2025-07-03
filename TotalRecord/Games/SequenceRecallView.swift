import SwiftUI

struct SequenceRecallView: View {
    @Binding var sequenceLength: Int
    var onRestart: (() -> Void)? = nil

    let allEmojis = ["🍎", "🍌", "🥝", "🌶️", "🍇", "🍉"]

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    @State private var sequence: [Int] = []
    @State private var userInput: [Int] = []

    @State private var score: Int = 0
    @State private var timeRemaining: Int = 10
    @State private var level: Int = 1

    @State private var isGameOver: Bool = false
    @State private var isTimerRunning: Bool = false
    @State private var isGameStarted: Bool = false
    @State private var showSequence: Bool = true;

    @State private var timer: Timer?    
    @State private var message: String = ""

    var body: some View {
        ZStack {
            Color.pink.opacity(0.03).ignoresSafeArea()
            VStack(spacing: 24) {
                // Title
                Text("🧠 Sequence Recall")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 16)

                // Info Bar
                HStack(spacing: 24) {
                    VStack {
                        Text("Level)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(level)")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    VStack {
                        Text("Score")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(score)")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    VStack {
                        Text("Time")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(timeRemaining)s")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(timeRemaining <= 3 ? .red : .primary)
                    }
                    Spacer()
                    Button(action: { onRestart?() }) {
                        Image(systemName: "clear")
                            .font(.title2)
                            .padding(8)
                            .background(Color.blue.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityLabel("Restart Game")
                }
                .padding(.horizontal)

                // Feedback Message
                if !message.isEmpty {
                    Text(message)
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding(.vertical, 4)
                        .transition(.opacity)
                }

                // Main Card Area
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.7))
                        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                        .frame(height: 450)
                    VStack(spacing: 16) {
                        if showSequence {
                            Text("Memorize the sequence!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(sequence.indices, id: \.self) { i in
                                    SequeceRecallCard(emoji: allEmojis[sequence[i]])
                                }
                            }
                        } else {
                            Text("Tap the emojis in order")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(allEmojis.indices, id: \.self) { i in
                                    SequeceRecallCard(emoji: allEmojis[i]) {
                                        handleUserInput(index: i)
                                    }
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
        timeRemaining = 10
        startSequenceTimer()
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
            for (user, correct) in zip(userInput, sequence) {
                if user != correct {
                    message = "Wrong! You lost."
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        message = ""
                        StartGame()
                    }
                    return
                }
            }

            if userInput.count == sequence.count {
                message = "Congrats lvl \(level) is Done!"
                sequenceLength += 1
                level += 1
                score += 15
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    message = ""
                    StartGame()
                }
            }
        }
    }


}

struct SequeceRecallCard: View {
    let emoji: String
    var onTap: (() -> Void)? = nil
    @State private var appeared = false
    @State private var tapped = false

    var body: some View {
        Text(emoji)
            .font(.largeTitle)
            .frame(width: 100, height: 100)
            .background(Color.pink.opacity(0.1))
            .border(Color.pink.opacity(0.2))
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