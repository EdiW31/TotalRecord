import SwiftUI

struct SpeedMatchSetupView: View {
    @State private var startGame = false
    @State private var selectedDifficulty: Difficulty = .easy
    @State private var rounds: Int = 15
    @State private var timePerCard: Double = 2.0

    enum Difficulty: String, CaseIterable, Identifiable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
        var id: String { self.rawValue }
        var defaultRounds: Int {
            switch self {
            case .easy: return 10
            case .medium: return 20
            case .hard: return 30
            }
        }
        var defaultTime: Double {
            switch self {
            case .easy: return 2.5
            case .medium: return 1.8
            case .hard: return 1.2
            }
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            if startGame {
                SpeedMatchView(
                    numberOfRounds: rounds,
                    timePerCard: timePerCard,
                    onRestart: { startGame = false }
                )
            } else {
                VStack(spacing: 32) {
                    Text("Speed Match Setup")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                        .shadow(color: .blue.opacity(0.10), radius: 4, x: 0, y: 2)
                        .padding(.top, 40)
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Difficulty")
                            .font(.headline)
                        Picker("Difficulty", selection: $selectedDifficulty) {
                            ForEach(Difficulty.allCases) { diff in
                                Text(diff.rawValue).tag(diff)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: selectedDifficulty) { newDiff in
                            rounds = newDiff.defaultRounds
                            timePerCard = newDiff.defaultTime
                        }
                        HStack {
                            Text("Rounds: ")
                            Stepper(value: $rounds, in: 5...50, step: 1) {
                                Text("\(rounds)")
                            }
                        }
                        HStack {
                            Text("Time per card: ")
                            Slider(value: $timePerCard, in: 0.7...4.0, step: 0.1) {
                                Text("Time per card")
                            }
                            Text(String(format: "%.1fs", timePerCard))
                                .frame(width: 48, alignment: .trailing)
                        }
                    }
                    .padding(.horizontal, 24)
                    Button(action: { startGame = true }) {
                        Text("Start Game")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 16)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(radius: 5)
                    }
                    Spacer()
                }
                .padding(.top, 60)
            }
        }
    }
}
