import SwiftUI

struct GamesMenuView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 2)
                    GameCard(imageName: "memory-game", backgroundColor: Color.green.opacity(0.18)) {
                        NavigationLink(
                            destination: MemoryMatchSetupView()
                                .navigationBarBackButtonHidden(true)
                        ) {
                            Text("Play Memory Match! 🧩")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green.opacity(0.5))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    GameCard(imageName: "sequence-recall-game", backgroundColor: Color.pink.opacity(0.18)) {
                        NavigationLink(
                            destination: SequenceRecallSetupView()
                                .navigationBarBackButtonHidden(true)
                        ) {
                            Text("Play Sequence Recall!")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.pink.opacity(0.5))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    GameCard(imageName: "card-locator-game", backgroundColor: Color.blue.opacity(0.18)) {
                        NavigationLink(
                            destination: CardLocatorSetupView()
                                .navigationBarBackButtonHidden(true)
                        ) {
                            Text("Play Card Locator! 🃏")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.5))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    GameCard(imageName: "speed-match-game", backgroundColor: Color.purple.opacity(0.18)) {
                        NavigationLink(
                            destination: MemoryMatchSetupView()
                                .navigationBarBackButtonHidden(true)
                        ) {
                            Text("Play Speed Match!")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple.opacity(0.5))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
            }
            .navigationTitle("Choose a game!")
            .background(Color.green.opacity(0.10))
        }
    }
}