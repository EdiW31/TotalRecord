import SwiftUI

struct MemoryMatchSetupView: View{
    @State private var selectedPairs = 2;
    @State private var startGame = false

    var body: some View {
        ScrollView  {
            if startGame {
                MemoryMatchView(numberOfPairs: selectedPairs, onRestart: { startGame = false })
            } else {
                VStack(spacing: 22){
                    Text("Memory Game").font(.largeTitle)
                    Text("Check the instructions below!📌").font(.title3)
                    VStack(spacing: 24) {
                        Text("Select how many pairs:")
                            .font(.title2)
                        Picker("Pairs", selection: $selectedPairs) {
                            ForEach(2...4, id: \ .self) { num in
                                Text("\(num) pairs")
                            }
                        }
                        .pickerStyle(.segmented)
                        Button("Start Game") {
                            startGame = true
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.08))
                            .shadow(radius: 4)
                    )
                    .padding()
                    Image("memory")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .navigationTitle("Setup")
                .navigationBarTitleDisplayMode(.inline)
            }
        }.background(Color.green.opacity(0.10))
    }
}
