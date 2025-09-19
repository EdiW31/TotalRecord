import SwiftUI
struct AppButton: View {
    let label: String
    let color: Color
    var destination: AnyView? = nil
    var action: (() -> Void)? = nil

    init(label: String, color: Color, destination: AnyView) {
        self.label = label
        self.color = color
        self.destination = destination
        self.action = nil
    }

    init(label: String, color: Color, action: @escaping () -> Void) {
        self.label = label
        self.color = color
        self.destination = nil
        self.action = action
    }

    var body: some View {
        if let destination = destination {
            NavigationLink(destination: destination) {
                buttonStyle
            }
        } else {
            Button(action: { action?() }) {
                buttonStyle
            }
        }
    }

    private var buttonStyle: some View {
        Text(label)
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
} 