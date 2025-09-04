import SwiftUI

struct SpeedMatchSetupView: View {
    @State private var startGame = false
    @State private var selectedDifficulty: Difficulty = .easy
    @State private var rounds: Int = 15
    @State private var timePerCard: Double = 2.0
    @State private var selectedGameMode: GameMode = .timed

    enum Difficulty: String, CaseIterable, Identifiable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
        var id: String { self.rawValue }
        var defaultRounds: Int {
            switch self {
            case .easy: return 10
            case .medium: return 15
            case .hard: return 20
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
                    gameMode: selectedGameMode,
                    onRestart: { startGame = false }
                )
            } else {
                VStack(spacing: 32) {
                    Text("Speed Match Setup")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                        .shadow(color: .blue.opacity(0.10), radius: 4, x: 0, y: 2)
                        .padding(.top, 40)
                    HStack{
                        Picker("Game Mode", selection: $selectedGameMode) {
                            Text("Timed").tag(GameMode.timed)
                            Text("Infinite").tag(GameMode.infinite)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        .onChange(of: selectedGameMode) { newMode in
                            if newMode == .timed {
                                rounds = min(rounds, 20) // Cap at 20 rounds for timed mode
                            }
                        }
                        Text("Game Mode: \(selectedGameMode.rawValue)")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(10)
                    }
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
                            if selectedGameMode == .timed {
                                rounds = min(newDiff.defaultRounds, 20) // Max 20 rounds for timed mode
                            }
                            timePerCard = newDiff.defaultTime
                        }
                        HStack {
                            Text("Rounds: ")
                            if selectedGameMode == .timed {
                                Picker("Rounds", selection: $rounds) {
                                    Text("10").tag(10)
                                    Text("15").tag(15)
                                    Text("20").tag(20)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            } else {
                                Text("∞ (Infinite)")
                                    .foregroundColor(.blue)
                                    .fontWeight(.bold)
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
