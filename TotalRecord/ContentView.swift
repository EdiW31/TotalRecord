//
//  ContentView.swift
//  TotalRecord
//
//  Created by Eduard Weiss on 19.06.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()  // punem elementul de tip view inainte de .tabItem pentru a afisa elementul in tabview
                .tabItem {
                    Image(systemName: "house") // aici doar punem iconul
                    Text("Home")
                }
            GamesMenuView()
                .tabItem {
                    Image(systemName: "gamecontroller")  //iconul
                    Text("Games")
                }
            MemoryPalaceListView()
                .tabItem {
                    Image(systemName: "building.columns") //iconul
                    Text("Memory Palace")
                }
        }
    }
}

struct HomeView: View {  //aste e un element de tip view care se afiseaza in tabview
    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome to TotalRecard!")
            }
            .navigationTitle("Home")
        }
    }
}

struct GamesMenuView: View {
    var body: some View {
        NavigationStack {
            Text("Choose a game mode here")
                .navigationTitle("Games")
        }
    }
}

struct MemoryPalaceListView: View {
    var body: some View {
        NavigationStack {
            Text("Your Memory Palaces")
                .navigationTitle("Memory Palace")
        }
    }
}

#Preview {
    ContentView()
}
