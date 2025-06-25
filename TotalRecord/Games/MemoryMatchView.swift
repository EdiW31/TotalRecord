import SwiftUI

// Model for a single card, aici initalizam si starile, isfaceup si ismatched
struct Card: Identifiable {
    let id: Int
    let content: String
    var isFaceUp: Bool = false
    var isMatched: Bool = false
}
struct MemoryMatchView: View {
    let numberOfPairs: Int;

    let allEmojis = ["🍎", "🍌", "🥝", "🌶️", "🍇", "🍉", "🍓", "🍒"]

    // Task #2
    @State private var cards: [Card]
    @State private var indexOfFaceUpCard: Int? = nil // starea cardului care este ales
    @State private var isProcessing: Bool = false // Prevent taps during animation
    @State private var timeLeft: Int

    // Task #3
    @State private var timer: Timer? = nil
    @State private var timerRun: Bool = true
    @State private var score: Int = 0
    @State private var gameFinished: Bool = false

    // 2 columns for a 2x2 grid
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    init(numberOfPairs: Int){
        self.numberOfPairs = numberOfPairs
        // Select the correct number of unique emojis
        let selectedEmojis = Array(allEmojis.shuffled().prefix(numberOfPairs))
        // Duplicate and shuffle for pairs
        let pairedEmojis = (selectedEmojis + selectedEmojis).shuffled()
        // Create Card array
        self._cards = State(initialValue: pairedEmojis.enumerated().map { Card(id: $0.offset, content: $0.element) })
        // Set timer duration based on number of pairs
        switch numberOfPairs {
        case 2: self._timeLeft = State(initialValue: 10)
        case 3: self._timeLeft = State(initialValue: 15)
        case 4: self._timeLeft = State(initialValue: 15)
        default: self._timeLeft = State(initialValue: 10)
        }
    }

    var body: some View {
        VStack {
            Text("Memory Match")
                .font(.largeTitle)
                .padding(.top)
            HStack{
                Text("Time Left ⌛: \(timeLeft)")
                .font(.title2)
                .padding()
                Text("Score 💯: \(score)")
                .font(.title2)
                .padding()
            }
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(cards.indices, id: \ .self) { index in
                    CardView(card: cards[index])
                        .onTapGesture {
                            flipCard(at: index)
                        }
                        .disabled(cards[index].isFaceUp || cards[index].isMatched || isProcessing || gameFinished || timeLeft == 0)
                }
            }
            .padding()
            Spacer()
            if gameFinished {
                Text("🎉 Congrats! You matched all the pairs! 🎉")
                    .font(.title2)
                    .foregroundColor(.green)
                    .padding()
                NavigationLink(
                    destination: MemoryMatchSetupView()
                ) {
                    Text("Restart Game!")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }.padding()
            }
            if timeLeft == 0 && !gameFinished {
                Text("⏰ Time's up! Try again!")
                    .font(.title2)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .background(Color.gray.opacity(0.1))
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }

        .onChange(of: gameFinished) {
            if gameFinished {
                stopTimer()
            }
        }
        .onChange(of: timeLeft) {
            if timeLeft == 0 {
                stopTimer()
            }
        }
    }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeLeft > 0 && timerRun == true{
                timeLeft -= 1
            }
        }
    }

    // functie pentru stop timer
    func stopTimer(){
        timer?.invalidate()
        timer = nil
    }

    

    // Game logic for flipping and matching cards
    func flipCard(at index: Int) {
        guard !cards[index].isFaceUp, !cards[index].isMatched, !isProcessing, !gameFinished, timeLeft > 0 else { return }
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
                self.score += 10;
                if cards.allSatisfy({ $0.isMatched }) {
                    gameFinished = true
                }
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

    // Function to check if all cards are matched
    func isGameFinished() -> Bool {
        self.timerRun = false;
        stopTimer()
        return cards.allSatisfy { $0.isMatched }
        
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
