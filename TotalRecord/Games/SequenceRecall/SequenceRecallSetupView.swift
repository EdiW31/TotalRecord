import SwiftUI

struct SequenceRecallSetupView: View {
    @State private var sequenceLength = 2
    @State private var startGame = false
    @State private var selectedGameMode: GameMode = .timed

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.pink.opacity(0.18), Color.purple.opacity(0.10)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            if startGame {
                SequenceRecallView(sequenceLength: $sequenceLength, onRestart: { startGame = false })
            } else {
                VStack(spacing: 32) {
                    // Title and subtitle
                    VStack(spacing: 8) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 110, height: 110)
                            .foregroundColor(.pink)
                            .shadow(radius: 10)
                        Text("Sequence Recall")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Memorize and repeat the sequence! How long can you go?")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    // Card-like setup area
                    HStack{
                        Picker("Game Mode", selection: $selectedGameMode) {
                            Text("Timed").tag(GameMode.timed)
                            Text("Infinite").tag(GameMode.infinite)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        Text("Game Mode: \(selectedGameMode.rawValue)")
                            .font(.headline)
                            .foregroundColor(.pink)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(10)
                    }
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.8))
                            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                            .frame(height: 200)
                        VStack(spacing: 24) {
                            Text("Select Sequence Length")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Stepper(value: $sequenceLength, in: 2...8) {
                                Text("Length: \(sequenceLength)")
                                    .font(.headline)
                                    .foregroundColor(.pink)
                            }
                            .padding(.horizontal)
                        }
                        .padding(32)
                    }
                    .frame(maxWidth: 400)
                    Button(action: { startGame = true }) {
                        Text("Start Game")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(gradient: Gradient(colors: [Color.pink, Color.purple]), startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(10)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(.horizontal)
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
} 