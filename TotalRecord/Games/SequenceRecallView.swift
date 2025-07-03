import SwiftUI

struct SequenceRecallView: View {
    @Binding var sequenceLength: Int
    var onRestart: (() -> Void)? = nil

    let allEmojis = ["🍎", "🍌", "🥝", "🌶️", "🍇", "🍉", "🍓", "🍒"]

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    @State private var sequence: [Int] = []
    @State private var userInput: [Int] = []

    @State private var score: Int = 0
    @State private var timeRemaining: Int = 10

    @State private var isGameOver: Bool = false
    @State private var isTimerRunning: Bool = false
    @State private var isGameStarted: Bool = false

    @State private var timer: Timer?    

    // Task #2
    var body: some View {
        VStack {
            Text("Sequence Recall")
                .font(.largeTitle)
            Text("Sequence length: \(sequenceLength)")
                .font(.title2)
            // Placeholder for game logic
            Button("Restart") {
                onRestart?()
            }
            .padding()

            Text("Score: \(score)")
                .font(.title2)
            Text("Time remaining: \(timeRemaining)")
                .font(.title2)
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(sequence.indices, id: \.self) { i in
                    SequeceRecallCard(emoji: allEmojis[sequence[i]])
                }
            }
            Text("User input: \(userInput.map { allEmojis[$0] }.joined(separator: " "))")
                .font(.title2)
        }.onAppear{
            sequence = Array(0..<sequenceLength).map { _ in Int.random(in: 0..<allEmojis.count) }
        }
    }
}

struct SequeceRecallCard: View {
    let emoji: String
    @State private var appeared = false
    @State private var tapped = false

    var body: some View {
        Text(emoji)
            .font(.largeTitle)
            .frame(width: 100, height: 100)
            .background(Color.white)
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
                // Reset the tap animation after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation {
                        tapped = false
                    }
                }
                print("Tapped \(emoji)")
            }
    }
}