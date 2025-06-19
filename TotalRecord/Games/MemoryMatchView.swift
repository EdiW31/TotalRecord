import SwiftUI

// Model for a single card
struct Card: Identifiable {
    let id: Int
    let content: String
    var isFaceUp: Bool = false
    var isMatched: Bool = false
}

struct MemoryMatchView: View {
    // State: the cards and the index of the first face-up card
    @State private var cards: [Card] = [
        Card(id: 0, content: "🍎"),
        Card(id: 1, content: "🍎"),
        Card(id: 2, content: "🍌"),
        Card(id: 3, content: "🍌")
    ].shuffled()
    @State private var indexOfFaceUpCard: Int? = nil
    @State private var isProcessing: Bool = false // Prevent taps during animation

    // 2 columns for a 2x2 grid
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack {
            Text("Memory Match")
                .font(.largeTitle)
                .padding(.top)
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(cards.indices, id: \ .self) { index in
                    CardView(card: cards[index])
                        .onTapGesture {
                            flipCard(at: index)
                        }
                        .disabled(cards[index].isFaceUp || cards[index].isMatched || isProcessing)
                }
            }
            .padding()
            Spacer()
        }
        .background(Color.gray.opacity(0.1))
    }

    // Game logic for flipping and matching cards
    func flipCard(at index: Int) {
        guard !cards[index].isFaceUp, !cards[index].isMatched, !isProcessing else { return }
        if let firstIndex = indexOfFaceUpCard {
            // Second card flipped
            cards[index].isFaceUp = true
            isProcessing = true
            if cards[firstIndex].content == cards[index].content {
                // Match found
                cards[firstIndex].isMatched = true
                cards[index].isMatched = true
                indexOfFaceUpCard = nil
                isProcessing = false
            } else {
                // No match: flip both back after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    cards[firstIndex].isFaceUp = false
                    cards[index].isFaceUp = false
                    indexOfFaceUpCard = nil
                    isProcessing = false
                }
            }
        } else {
            // First card flipped
            for i in cards.indices { cards[i].isFaceUp = false }
            cards[index].isFaceUp = true
            indexOfFaceUpCard = index
        }
    }
}

// Card view with flip animation
struct CardView: View {
    let card: Card
    var body: some View {
        ZStack {
            if card.isFaceUp || card.isMatched {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(radius: 4)
                Text(card.content)
                    .font(.largeTitle)
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue)
                    .shadow(radius: 4)
            }
        }
        .frame(height: 100)
        .rotation3DEffect(
            .degrees(card.isFaceUp || card.isMatched ? 0 : 180),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.easeInOut, value: card.isFaceUp)
    }
}