import SwiftUI

struct SequenceRecallSetupView: View {
    @State private var sequenceLength = 2
    @State private var startGame = false

    var body: some View {
        ZStack {
            Color.pink.opacity(0.10).ignoresSafeArea()
            if startGame {
                SequenceRecallView(sequenceLength: $sequenceLength, onRestart: { startGame = false })
            } else {
                VStack(spacing: 32) {
                    // Title and subtitle
                    VStack(spacing: 8) {
                        Text("🧠 Sequence Recall")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Memorize and repeat the sequence!")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    // Card-like setup area
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.8))
                            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                             .frame(height: 370)
                        VStack(spacing: 24) {
                            Text("Select sequence length:")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Stepper(value: $sequenceLength, in: 2...8) {
                                Text("Length: \(sequenceLength)")
                            }
                            .padding(.horizontal)
                            Button(action: { startGame = true }) {
                                Text("Start Game")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(32)
                    }
                    .frame(maxWidth: 400)
                    // Themed image
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 100)
                        .foregroundColor(.blue)
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(.horizontal)
                .navigationTitle("Setup")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
} 