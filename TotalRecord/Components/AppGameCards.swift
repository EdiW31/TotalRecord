import SwiftUI

struct GameCards: View {
    let emoji: String
    var color: Color // am declarat ca si color ca sa pot folosii ".pink" sau asa
    var onTap: (() -> Void)? = nil
    
    @State private var appeared = false
    @State private var tapped = false

    var body: some View {
        Text(emoji)
            .font(.largeTitle)
            .frame(width: 100, height: 100)
            .background(color.opacity(0.1))
            .border(color.opacity(0.2))
            .cornerRadius(10)
            .shadow(radius: 4)
            .scaleEffect(tapped ? 1.2 : (appeared ? 1 : 0.5))
            .opacity(appeared ? 1 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    appeared = true
                }
            }
            .onTapGesture {
                withAnimation(.interpolatingSpring(stiffness: 200, damping: 5)) {
                    tapped = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation {
                        tapped = false
                    }
                }
                onTap?()
            }
    }
}