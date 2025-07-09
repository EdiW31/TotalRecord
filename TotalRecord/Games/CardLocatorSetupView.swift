import SwiftUI

struct CardLocatorSetupView: View {
    @State private var startGame = false
    @State private var selectedDifficulty: Difficulty = .easy

    enum Difficulty: String, CaseIterable, Identifiable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
        var id: String { self.rawValue }
        var numberOfTargets: Int {
            switch self {
            case .easy: return 2
            case .medium: return 3
            case .hard: return 5
            }
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            if startGame {
                CardLocatorView(onRestart: { startGame = false }, numberOfTargets: selectedDifficulty.numberOfTargets)
            } else {
                VStack(spacing: 32) {
                    // Title and subtitle
                    VStack(spacing: 8) {
                        Image(systemName: "eye.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.blue)
                            .shadow(radius: 10)
                        Text("Card Locator")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Test your memory and spatial skills! Memorize the locations of special cards, then tap them from memory. How many can you get right?")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    // Difficulty Picker
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.8))
                            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                            .frame(height: 200)
                        VStack(spacing: 24) {
                            Text("Select Difficulty")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Picker("Difficulty", selection: $selectedDifficulty) {
                                ForEach(Difficulty.allCases) { difficulty in
                                    Text(difficulty.rawValue).tag(difficulty)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.horizontal)
                            Text("Targets to memorize: \(selectedDifficulty.numberOfTargets)")
                                .font(.headline)
                                .foregroundColor(.blue)
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
                                LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing)
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