import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct GameCard: View {
    let title: String
    let bestScore: Int
    let imageName: String
    let buttonTitle: String
    let onButtonTap: () -> Void

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .frame(height: 299)
                .frame(maxWidth: .infinity)
                .background(
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 299)
                        .frame(maxWidth: .infinity)
                        .clipped()
                )
                .cornerRadius(24)
                .shadow(color: Color.black.opacity(0.10), radius: 12, x: 0, y: 6)
                .overlay(
                    // Top wide, soft, horizontal gradient shadow overlay
                    VStack(spacing: 0) {
                        ZStack(alignment: .top) {
                            TopWideShadow()
                            HStack(alignment: .top) {
                                Text(title)
                                    .font(.system(size: 26, weight: .bold, design: .rounded))
                                    .foregroundColor(.black)
                                    .padding(.top, 2)
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("Best score:")
                                        .font(.system(size: 15, weight: .medium, design: .rounded))
                                        .foregroundColor(.black)
                                    Text("\(bestScore)")
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundColor(.black)
                                }
                            }
                            .padding(.horizontal, 22)
                            .padding(.top, 18)
                            .padding(.bottom, 12)
                        }
                        .frame(height: 80)
                        .frame(maxWidth: .infinity)
                        Spacer()
                    }
                    .frame(height: 80)
                    .frame(maxWidth: .infinity)
                    , alignment: .top
                )
                .overlay(
                    VStack {
                        Spacer()
                        Button(action: onButtonTap) {
                            Text(buttonTitle)
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(18)
                        }
                        .padding(.horizontal, 18)
                        .padding(.bottom, 18)
                    }
                    .frame(height: 299)
                    .frame(maxWidth: .infinity)
                )
        }
        .frame(height: 299)
        .frame(maxWidth: .infinity)
    }
}

// Wide, soft, horizontal top shadow overlay
struct TopWideShadow: View {
    var body: some View {
        #if canImport(UIKit)
        LinearGradient(
            gradient: Gradient(colors: [Color.black.opacity(0.18), Color.clear]),
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 70)
        .frame(maxWidth: .infinity)
        .blur(radius: 16)
        .clipShape(TopCornersRounded(radius: 24))
        #else
        LinearGradient(
            gradient: Gradient(colors: [Color.black.opacity(0.18), Color.clear]),
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 70)
        .frame(maxWidth: .infinity)
        .blur(radius: 16)
        .cornerRadius(24)
        #endif
    }
}

#if canImport(UIKit)
struct TopCornersRounded: Shape {
    var radius: CGFloat
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
#endif 