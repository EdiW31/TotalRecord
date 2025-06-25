import SwiftUI


struct MemoryMatchSetupView: View{
    @State private var selectedPairs = 2;

     var body: some View {
        VStack(spacing: 22){
            Text("Memory Game").font(.largeTitle)
            Text("Check the instructions below!📌").font(.title3)
        }
        VStack(spacing: 24) {
            Text("Select how many pairs:")
                .font(.title2)
            Picker("Pairs", selection: $selectedPairs) {
                ForEach(2...4, id: \.self) { num in
                    Text("\(num) pairs")
                }
            }
            .pickerStyle(.segmented)
            NavigationLink(
                destination: MemoryMatchView(numberOfPairs: selectedPairs)
            ) {
                Text("Start Game")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.08))
                .shadow(radius: 4)
        )
        .padding()
        .navigationTitle("Setup")
            .navigationBarTitleDisplayMode(.inline)

        Image("memory")
                .resizable()
                .aspectRatio(contentMode: .fit)
    }
}
