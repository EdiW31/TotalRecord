import SwiftUI

struct SequenceRecallView: View {
    let sequenceLength: Int = 5;
    var onRestart: (() -> Void)? = nil
    
    @State private var sequence: [Int] = []
    @State private var userInput: [Int] = []

    @State private var score: Int = 0
    @State private var timeRemaining: Int = 10

    @State private var isGameOver: Bool = false
    @State private var isTimerRunning: Bool = false
    @State private var isGameStarted: Bool = false

    @State private var timer: Timer?

    

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
        }
    }
}