//
//  TotalRecordApp.swift
//  TotalRecord
//
//  Created by Eduard Weiss on 19.06.2025.
//

import SwiftUI
import UIKit

@main
struct TotalRecordApp: App {
    init() {
        UITabBar.appearance().unselectedItemTintColor = UIColor.white
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
