import SwiftUI 
struct Card: Identifiable {
    let id: Int
    let content: String
    var isFaceUp: Bool = false
    var isMatched: Bool = false
}

struct MemoryMatchView: View {
    @State private var cards: [Card] = [
        Card(id: 0, content: "🍎"),
        Card(id: 1, content: "🍎"),
        Card(id: 2, content: "🍌"),
        Card(id: 3, content: "🍌"),
        Card(id: 2, content: "🥝"),
        Card(id: 3, content: "🥝")
    ].shuffled()
    @State private var indexOfFaceUpCard: Int? = nil

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack {
            Text("Memory Match")
                .font(.largeTitle)
                .padding(.top)
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(cards.indices, id: \.self) { index in
                    CardView(card: cards[index])
                        .onTapGesture {
                            flipCard(at: index)
                        }
                }
            }
            .padding()
        }
        
    }

    func flipCard(at index: Int) {
        // Only allow flipping if the card is not already matched or face up
        guard !cards[index].isFaceUp, !cards[index].isMatched else { return }
        cards[index].isFaceUp = true

        if let firstIndex = indexOfFaceUpCard {
            // Second card flipped: check for match
            if cards[firstIndex].content == cards[index].content {
                cards[firstIndex].isMatched = true
                cards[index].isMatched = true
            } else {
                // No match: flip both back after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    cards[firstIndex].isFaceUp = false
                    cards[index].isFaceUp = false
                }
            }
            indexOfFaceUpCard = nil
        } else {
            // First card flipped
            indexOfFaceUpCard = index
        }
    }
}

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
        .animation(.easeInOut, value: card.isFaceUp)
    }
}