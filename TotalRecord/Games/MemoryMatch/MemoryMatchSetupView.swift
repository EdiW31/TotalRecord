import SwiftUI

struct MemoryMatchSetupView: View {
    @State private var selectedPairs = 2
    @State private var startGame = false
    @State private var selectedGameMode: GameMode = .timed

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.18), Color.teal.opacity(0.12)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            if startGame {
                MemoryMatchView(numberOfPairs: selectedPairs, onRestart: { startGame = false })
            } else {
                VStack(spacing: 32) {
                    // Title and subtitle
                    VStack(spacing: 8) {
                        Image(systemName: "brain.head.profile")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.green)
                            .shadow(radius: 10)
                        Text("Memory Match")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Test your memory! Match all the pairs before time runs out.")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    // Pairs Picker
                    HStack{
                        Picker("Game Mode", selection: $selectedGameMode) {
                            Text("Timed").tag(GameMode.timed)
                            Text("Infinite").tag(GameMode.infinite)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        Text("Game Mode: \(selectedGameMode.rawValue)")
                            .font(.headline)
                            .foregroundColor(.green)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(10)
                    }
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.8))
                            .shadow(color: .green.opacity(0.08), radius: 8, x: 0, y: 4)
                            .frame(height: 200)
                        VStack(spacing: 24) {
                            Text("Select how many pairs:")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Picker("Pairs", selection: $selectedPairs) {
                                ForEach(2...4, id: \ .self) { num in
                                    Text("\(num) pairs")
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
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
                                LinearGradient(gradient: Gradient(colors: [Color.green, Color.teal]), startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(10)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(.horizontal)
                .navigationTitle("Setup")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
