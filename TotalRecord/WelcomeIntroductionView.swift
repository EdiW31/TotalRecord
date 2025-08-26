import SwiftUI

// MARK: - Welcome Page Model
struct WelcomePage {
    let id = UUID()
    let title: String
    let subtitle: String
    let description: String
    let imageName: String
    let backgroundColor: Color
}

// MARK: - Individual Welcome Page View
struct WelcomePageView: View {
    let page: WelcomePage
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Image
            Image(systemName: page.imageName)
                .font(.system(size: 100, weight: .thin))
                .foregroundColor(.white)
            
            // Content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [page.backgroundColor, page.backgroundColor.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - Main Welcome Carousel View
struct WelcomeCarouselView: View {
    @State private var currentPage = 0
    @State private var showPalaceCreation = false
    @Binding var hasCompletedFirstTimeSetup: Bool
    
    let pages: [WelcomePage] = [
        WelcomePage(
            title: "Welcome to TotalRecard",
            subtitle: "Memory Training Made Fun",
            description: "Discover powerful memory techniques through engaging games and personalized memory palaces.",
            imageName: "brain.head.profile",
            backgroundColor: .pink
        ),
        WelcomePage(
            title: "Memory Games",
            subtitle: "Train Your Brain",
            description: "Challenge yourself with Memory Match, Sequence Recall, and Card Locator games.",
            imageName: "gamecontroller",
            backgroundColor: .purple
        ),
        WelcomePage(
            title: "Trophy Rooms",
            subtitle: "Earn Your Achievements",
            description: "Unlock trophy rooms and earn achievements as you master memory training games.",
            imageName: "trophy.fill",
            backgroundColor: .blue
        ),
        WelcomePage(
            title: "Ready to Start",
            subtitle: "Let's Begin!",
            description: "You're all set to begin your memory training journey. Let's create your first trophy rooms!",
            imageName: "checkmark.circle",
            backgroundColor: .green
        )
    ]
    
    var body: some View {
        if showPalaceCreation {
            TrophyRoomSetupView(hasCompletedFirstTimeSetup: $hasCompletedFirstTimeSetup)
        } else {
            VStack {
                // Page indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundColor(currentPage == index ? .white : .white.opacity(0.4))
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                .padding(.top, 50)
                
                // Carousel
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        WelcomePageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onChange(of: currentPage) { _, newValue in
                    // Handle page change if needed
                }
                
                // Action buttons
                VStack(spacing: 16) {
                    if currentPage == pages.count - 1 {
                        // Get Started button on last page
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showPalaceCreation = true
                            }
                        }) {
                            Text("Create Memory Palaces")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(25)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.white, lineWidth: 1)
                                )
                        }
                        .padding(.horizontal, 40)
                    } else {
                        // Skip and Next buttons
                        HStack {
                            Button("Skip") {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    showPalaceCreation = true
                                }
                            }
                            .foregroundColor(.white.opacity(0.7))
                            
                            Spacer()
                            
                            Button("Next") {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentPage = min(currentPage + 1, pages.count - 1)
                                }
                            }
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                        }
                        .padding(.horizontal, 40)
                    }
                }
                .padding(.bottom, 50)
            }
            .background(
                // Dynamic background that changes with current page
                pages[currentPage].backgroundColor
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.5), value: currentPage)
            )
        }
    }
}

// MARK: - Placeholder Main App View
struct MainAppView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Main App")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Welcome! You've completed the onboarding.")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .navigationTitle("My App")
        }
    }
}

// MARK: - Preview
#Preview {
    WelcomeCarouselView(hasCompletedFirstTimeSetup: .constant(false))
}