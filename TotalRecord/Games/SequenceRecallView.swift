import SwiftUI

struct SequenceRecallView: View {
    let sequenceLength: Int
    var onRestart: (() -> Void)? = nil

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