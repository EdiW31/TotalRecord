import SwiftUI

struct GamesMenuView: View {
    @State private var navigateTo: String? = nil
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 2)
                    GameCard(
                        title: "Memory Match",
                        bestScore: 140, // TODO: Replace with actual best score
                        imageName: "memory-match",
                        buttonTitle: "Play Memory Match",
                        onButtonTap: { navigateTo = "MemoryMatch" }
                    )
                    .padding(.horizontal, 16)
                    GameCard(
                        title: "Sequence Recall",
                        bestScore: 140, // TODO: Replace with actual best score
                        imageName: "sequence-recall-game",
                        buttonTitle: "Play Sequence Recall",
                        onButtonTap: { navigateTo = "SequenceRecall" }
                    )
                    .padding(.horizontal, 16)
                    GameCard(
                        title: "Card Locator",
                        bestScore: 140, // TODO: Replace with actual best score
                        imageName: "card-locator-game",
                        buttonTitle: "Play Card Locator",
                        onButtonTap: { navigateTo = "CardLocator" }
                    )
                    .padding(.horizontal, 16)
                    GameCard(
                        title: "Speed Match",
                        bestScore: 140, // TODO: Replace with actual best score
                        imageName: "speed-match-game",
                        buttonTitle: "Play Speed Match",
                        onButtonTap: { navigateTo = "SpeedMatch" }
                    )
                    .padding(.horizontal, 16)
                }
            }
            .navigationTitle("Choose a game!")
            .navigationDestination(isPresented: Binding(
                get: { navigateTo != nil },
                set: { if !$0 { navigateTo = nil } }
            )) {
                switch navigateTo {
                case "MemoryMatch":
                    MemoryMatchSetupView().navigationBarBackButtonHidden(true)
                case "SequenceRecall":
                    SequenceRecallSetupView().navigationBarBackButtonHidden(true)
                case "CardLocator":
                    CardLocatorSetupView().navigationBarBackButtonHidden(true)
                case "SpeedMatch":
                    MemoryMatchSetupView().navigationBarBackButtonHidden(true) // TODO: Replace with SpeedMatchSetupView if exists
                default:
                    EmptyView()
                }
            }
        }
    }
}