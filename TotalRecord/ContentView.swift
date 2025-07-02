//
//  ContentView.swift
//  TotalRecord
//
//  Created by Eduard Weiss on 19.06.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        // TabView creates a bottom tab bar for main app sections
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
    }
}

// Home tab: Welcome screen with navigation title
struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome to TotalRecard!")
                    .font(.title)
                    .padding()
                Text("Start training your memory with games or build your memory palace.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Home")
        }
    }
}

// Games tab: Placeholder for game selection
struct GamesMenuView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Game options box
                    Spacer().frame(height: 2)
                    // Game 1
                    VStack(spacing: 16) {
                         Image("memory-game") // Make sure you have an image named "games" in your assets
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 220)
                        .cornerRadius(16)
                        .shadow(radius: 4)
                        .padding(.top, 10)

                        // Text("Memory Match 🧩")
                        // .font(.title)
                        NavigationLink(
                            destination: MemoryMatchSetupView()
                                .navigationBarBackButtonHidden(true)
                        ) {
                            Text("Play Memory Match! 🧩")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green.opacity(0.5))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        // Add more game mode buttons here as needed
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.green.opacity(0.18))
                            .shadow(radius: 4)
                    )
                    .padding(.horizontal)

                    // Game 2
                    VStack(spacing: 16) {
                        Image("sequence-recall-game") // Make sure you have an image named "games" in your assets
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 220)
                        .cornerRadius(16)
                        .shadow(radius: 8)
                        .padding(.top, 10)
                        AppButton(label: "Play Sequence Recall!", color: Color.pink.opacity(0.5), destination: SequenceRecallView().navigationBarBackButtonHidden(true))
                        // NavigationLink(
                        //     destination: SequenceRecallView()
                        //         .navigationBarBackButtonHidden(true)
                        // ) {
                        //     Text("Play Sequence Recall!")
                        //         .font(.headline)
                        //         .frame(maxWidth: .infinity)
                        //         .padding()
                        //         .background(Color.pink.opacity(0.5))
                        //         .foregroundColor(.white)
                        //         .cornerRadius(10)
                        // }
                        // Add more game mode buttons here as needed
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.pink.opacity(0.18))
                            .shadow(radius: 4)
                    )
                    .padding(.horizontal)
                    
                    // Game 3
                    VStack(spacing: 16) {
                        Image("card-locator-game") // Make sure you have an image named "games" in your assets
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 220)
                        .cornerRadius(16)
                        .shadow(radius: 8)
                        .padding(.top, 10)
                        NavigationLink(
                            destination: MemoryMatchSetupView()
                                .navigationBarBackButtonHidden(true)
                        ) {
                            Text("Play Card Locator! 🃏")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.5))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        // Add more game mode buttons here as needed
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.blue.opacity(0.18))
                            .shadow(radius: 4)
                    )
                    .padding(.horizontal)

                    // Game 4
                    VStack(spacing: 16) {
                        Image("speed-match-game") // Make sure you have an image named "games" in your assets
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 220)
                        .cornerRadius(16)
                        .shadow(radius: 8)
                        .padding(.top, 10)
                        NavigationLink(
                            destination: MemoryMatchSetupView()
                                .navigationBarBackButtonHidden(true)
                        ) {
                            Text("Play Speed Match!")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple.opacity(0.5))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        // Add more game mode buttons here as needed
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.purple.opacity(0.18))
                            .shadow(radius: 4)
                    )
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Choose a game!")
            .background(Color.green.opacity(0.10))
        }
    }
}

// Memory Palace tab: Placeholder for palace management
struct MemoryPalaceListView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Your Memory Palaces")
                    .font(.title2)
                    .padding(.bottom)
                // Placeholder for future palace list
                Text("(Create and manage your palaces here)")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Memory Palace")
        }
    }
}

#Preview {
    ContentView()
}
