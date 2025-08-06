//
//  ContentView.swift
//  TotalRecord
//
//  Created by Eduard Weiss on 19.06.2025.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Task 8.1.1: Add @AppStorage for setup tracking
    @AppStorage("hasCompletedFirstTimeSetup") private var hasCompletedFirstTimeSetup = false
    
    // MARK: - Task 8.1.3: Add state variables for welcome flow and palace creation
    @State private var showSplash = true
    @State private var showWelcomeFlow = false
    @State private var showPalaceCreation = false

    var body: some View {
        ZStack {
            if showSplash {
                SplashScreen()
            } else if !hasCompletedFirstTimeSetup {
                // MARK: - Task 8.1.2: Modify splash screen logic to check setup status
                // Show welcome carousel for first-time users
                WelcomeCarouselView(hasCompletedFirstTimeSetup: $hasCompletedFirstTimeSetup)
            } else {
                // Show normal app for returning users
                TabView {
                    HomeView()
                        .tabItem {
                            Image(systemName: "house")
                            Text("Home")
                        }
                    GamesMenuView()
                        .tabItem {
                            Image(systemName: "gamecontroller")
                            Text("Games")
                        }
                    MemoryPalaceListView()
                        .tabItem {
                            Image(systemName: "building.columns")
                            Text("Memory Palace")
                        }
                }
                .tint(.white) // Ensures all tab bar icons and labels are white
                .background(.clear) // Optional: makes TabView background transparent
            }
        }
        .onAppear {
            hasCompletedFirstTimeSetup = false
            // MARK: - Task 8.1.4: Test splash → welcome flow transition
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeOut(duration: 0.6)) {
                    showSplash = false
                    // If first-time user, show welcome flow
                    if !hasCompletedFirstTimeSetup {
                        showWelcomeFlow = true
                    }
                }
            }
        }
    }
}



struct SplashScreen: View {
    @State private var scale: CGFloat = 0.7
    @State private var opacity: Double = 0.0

    var body: some View {
        LinearGradient(gradient: Gradient(colors: [Color.pink.opacity(0.18), Color.purple.opacity(0.13), Color.blue.opacity(0.10)]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            .overlay(
                VStack(spacing: 18) {
                    Image(systemName: "brain.head.profile")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.pink)
                        .shadow(radius: 12)
                        .scaleEffect(scale)
                        .opacity(opacity)
                        .onAppear {
                            withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) {
                                scale = 1.0
                                opacity = 1.0
                            }
                        }
                    Text("TotalRecard")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.pink)
                        .shadow(color: .pink.opacity(0.13), radius: 6, x: 0, y: 2)
                        .opacity(opacity)
                        .onAppear {
                            withAnimation(.easeIn(duration: 1.0).delay(0.2)) {
                                opacity = 1.0
                            }
                        }
                }
            )
    }
}

// Home tab: Welcome screen with navigation title
struct HomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.pink.opacity(0.13), Color.purple.opacity(0.10), Color.blue.opacity(0.10)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                VStack(spacing: 32) {
                    // App Icon and Title
                    VStack(spacing: 10) {
                        Image(systemName: "brain.head.profile")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 90)
                            .foregroundColor(.pink)
                            .shadow(radius: 8)
                        Text("TotalRecard")
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundColor(.pink)
                            .shadow(color: .pink.opacity(0.10), radius: 4, x: 0, y: 2)
                    }
                    // Welcome Message
                    VStack(spacing: 8) {
                        Text("Welcome to TotalRecard!")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Start training your memory with fun games or build your own memory palace. Challenge yourself and track your progress!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    // Game Modes Summary
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Available Games:")
                            .font(.headline)
                            .foregroundColor(.purple)
                        HStack(alignment: .top, spacing: 16) {
                            VStack(alignment: .leading, spacing: 6) {
                                Label("Memory Match", systemImage: "rectangle.grid.2x2")
                                    .foregroundColor(.green)
                                Text("Find all the pairs before time runs out.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Label("Sequence Recall", systemImage: "arrow.triangle.2.circlepath")
                                    .foregroundColor(.pink)
                                Text("Memorize and repeat the sequence of emojis.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Label("Card Locator", systemImage: "eye.circle")
                                    .foregroundColor(.blue)
                                Text("Remember and tap the locations of hidden cards.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    // Call to Action
                    Text("Ready to boost your memory? Choose a game from the tab bar below!")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.top, 12)
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

// Helper view for a game card
// struct GameCard<Content: View>: View {
//     let imageName: String
//     let backgroundColor: Color
//     let content: Content
//     init(imageName: String, backgroundColor: Color, @ViewBuilder content: () -> Content) {
//         self.imageName = imageName
//         self.backgroundColor = backgroundColor
//         self.content = content()
//     }
//     var body: some View {
//         VStack(spacing: 16) {
//             Image(imageName)
//                 .resizable()
//                 .aspectRatio(contentMode: .fit)
//                 .frame(height: 220)
//                 .cornerRadius(16)
//                 .shadow(radius: 8)
//                 .padding(.top, 10)
//             content
//         }
//         .padding()
//         .background(
//             RoundedRectangle(cornerRadius: 16)
//                 .fill(backgroundColor)
//                 .shadow(radius: 4)
//         )
//         .padding(.horizontal)
//     }
// }

#Preview {
    ContentView()
}
