import SwiftUI

struct SequenceRecallSetupView: View {
    @State private var sequenceLength = 6
    @State private var startGame = false

    var body: some View {
        ScrollView {
            if startGame {
                SequenceRecallView(sequenceLength: $sequenceLength, onRestart: { startGame = false })
            } else {
                VStack(spacing: 22) {
                    Text("Sequence Recall Game").font(.largeTitle)
                    Text("Memorize and repeat the sequence!").font(.title3)
                    VStack(spacing: 24) {
                        Text("Select sequence length:")
                            .font(.title2)
                        Text("Here you will start with a sequence of numbers and you will have to recall them in order. The sequence will increase every lvl")
                        .pickerStyle(.segmented)
                        AppButton(label: "Start Game", color: .blue, action: { startGame = true })
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.08))
                            .shadow(radius: 4)
                    )
                    .padding()
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 120)
                        .foregroundColor(.blue)
                }
                .navigationTitle("Setup")
                .navigationBarTitleDisplayMode(.inline)
            }
        }.background(Color.pink.opacity(0.10))
    }
} 