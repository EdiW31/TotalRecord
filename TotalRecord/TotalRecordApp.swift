//
//  TotalRecordApp.swift
//  TotalRecord
//
//  Created by Eduard Weiss on 19.06.2025.
//

import SwiftUI

@main
struct TotalRecordApp: App {
    @StateObject private var palaceStorage = PalaceStorage()

    init() {
        // macOS app initialization
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(palaceStorage)
                .onAppear {
                    // Load palaces and set current palace
                    palaceStorage.loadPalaces()
                    palaceStorage.loadCurrentPalace()
                    
                    // Debug: Print current palace info
                    print("App loaded - Current palace: \(palaceStorage.currentPalace?.name ?? "None") with color: \(palaceStorage.currentPalace?.color ?? "None")")
                    print("Total palaces: \(palaceStorage.palaces.count)")
                    for (index, palace) in palaceStorage.palaces.enumerated() {
                        print("Palace \(index): \(palace.name) - Color: \(palace.color)")
                    }
                }
        }
    }
}
