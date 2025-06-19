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
            VStack {
                Text("Choose a game mode")
                    .font(.title2)
                    .padding(.bottom)
                // Placeholder for future game mode navigation
                Text("(Game modes will appear here)")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Games")
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
