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
    var onRestart: (() -> Void)? = nil
    let allEmojis = ["🍎", "🍌", "🥝", "🌶️", "🍇", "🍉", "🍓", "🍒"]
    // 2 columns for a 2x2 grid
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

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

    // Functie pentru Start Timer
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeLeft > 0 && timerRun == true{
                timeLeft -= 1
            }
        }
    }

    // Functie pentru Stop Timer
    func stopTimer(){
        timer?.invalidate()
        timer = nil
    }

    // Functie pentru Logica Jocului care se foloseste de structura CardView
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

    // Init este ce se initializeaza atunci cand se creeaza pagina
    init(numberOfPairs: Int, onRestart: (() -> Void)? = nil) {
        self.numberOfPairs = numberOfPairs
        self.onRestart = onRestart
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
        ZStack {
            // Lighter green gradient background, fullscreen
            LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.12), Color.teal.opacity(0.10), Color.green.opacity(0.08)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 4) {
                    Text("Memory Match")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                        .shadow(color: .green.opacity(0.12), radius: 4, x: 0, y: 2)
                    HStack(spacing: 12) {
                        Label("Time Left", systemImage: "clock.fill")
                            .font(.title3)
                            .foregroundColor(.teal)
                        Text("\(timeLeft)")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        Label("Score", systemImage: "star.fill")
                            .font(.title3)
                            .foregroundColor(.teal)
                        Text("\(score)")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 2)
                }
                // Card grid in a card-like container
                ZStack {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.white.opacity(0.85))
                        .shadow(color: .green.opacity(0.08), radius: 12, x: 0, y: 6)
                    VStack(spacing: 0) {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(cards.indices, id: \ .self) { index in
                                CardView(card: cards[index])
                                    .onTapGesture {
                                        flipCard(at: index)
                                    }
                                    .disabled(cards[index].isFaceUp || cards[index].isMatched || isProcessing || gameFinished || timeLeft == 0)
                                    .padding(12)
                            }
                        }
                        .padding(24)
                    }
                }
                .frame(maxWidth: 420, maxHeight: 520)
                .padding(.horizontal)
                Spacer(minLength: 24)
                if gameFinished {
                    Button(action: { onRestart?() }) {
                        Text("Restart Game!")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 14)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.teal]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(14)
                            .shadow(radius: 4)
                    }
                    .padding()
                }
                if timeLeft == 0 && !gameFinished {
                    Text("⏰ Time's up! Try again!")
                        .font(.title2)
                        .foregroundColor(.red)
                        .padding()
                    Button(action: { onRestart?() }) {
                        Text("Restart Game! YOU LOST :( (")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 14)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.teal]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(14)
                            .shadow(radius: 4)
                    }
                    .padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(.vertical, 16)
        }
        .background(Color.white.opacity(0.7))
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
}

// Card view with flip animation
struct CardView: View {
    let card: Card
    var body: some View {
        ZStack {
            if card.isFaceUp || card.isMatched {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(radius: 6)
                Text(card.content)
                    .font(.system(size: 44))
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.green, Color.teal]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .shadow(radius: 6)
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

