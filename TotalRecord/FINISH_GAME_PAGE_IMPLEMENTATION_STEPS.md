# 🎯 Finish Game Page Implementation Steps

## 📋 **Task Overview**
Create a simple "FinishGamePage" that shows:
- Final Score
- Time Taken  
- Game-specific extra stat
- Best Score (personal record)
- Best Time (personal record)

## 🏗️ **Implementation Steps**

### **Step 1: Create Game Statistics Model**
**File**: `Models/GameStats.swift`
```swift
import Foundation

 struct GameStats: Codable {
    let score: Int
    let timeTaken: TimeInterval
    let extraStat: Int
    let gameMode: GameMode
    let gameType: GameType
    let date: Date
}

enum GameType: String, Codable, CaseIterable {
    case memoryMatch = "Memory Match"
    case sequenceRecall = "Sequence Recall" 
    case cardLocator = "Card Locator"
    case speedMatch = "Speed Match"
}
```

### **Step 2: Create Score Storage**
**File**: `Models/ScoreStorage.swift`
```swift
import Foundation

class ScoreStorage: ObservableObject {
    static let shared = ScoreStorage()
    
    private let userDefaults = UserDefaults.standard
    
    func saveScore(_ stats: GameStats) {
        // Save to UserDefaults
    }
    
    func getBestScore(for gameType: GameType, mode: GameMode) -> Int? {
        // Get best score from UserDefaults
    }
    
    func getBestTime(for gameType: GameType, mode: GameMode) -> TimeInterval? {
        // Get best time from UserDefaults
    }
}
```

### **Step 3: Create Finish Game Page**
**File**: `Components/FinishGamePage.swift`
```swift
import SwiftUI

struct FinishGamePage: View {
    let stats: GameStats
    let onPlayAgain: () -> Void
    let onMainMenu: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text("Game Finished!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Stats Display
            VStack(spacing: 15) {
                StatRow(title: "Final Score", value: "\(stats.score)")
                StatRow(title: "Time Taken", value: formatTime(stats.timeTaken))
                StatRow(title: getExtraStatTitle(), value: "\(stats.extraStat)")
                StatRow(title: "Best Score", value: "\(getBestScore())")
                StatRow(title: "Best Time", value: formatTime(getBestTime()))
            }
            
            // Action Buttons
            VStack(spacing: 10) {
                Button("Play Again") { onPlayAgain() }
                Button("Main Menu") { onMainMenu() }
            }
        }
    }
    
    private func getExtraStatTitle() -> String {
        switch stats.gameType {
        case .memoryMatch: return "Correct Streaks"
        case .sequenceRecall: return "Levels Completed"
        case .cardLocator: return "Targets Found"
        case .speedMatch: return "Rounds Completed"
        }
    }
    
    private func getBestScore() -> Int {
        ScoreStorage.shared.getBestScore(for: stats.gameType, mode: stats.gameMode) ?? 0
    }
    
    private func getBestTime() -> TimeInterval {
        ScoreStorage.shared.getBestTime(for: stats.gameType, mode: stats.gameMode) ?? 0
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .fontWeight(.bold)
        }
        .padding(.horizontal)
    }
}
```

### **Step 4: Add Statistics Tracking to Memory Match**
**File**: `Games/MemoryMatch/MemoryMatchView.swift`

Add these state variables:
```swift
@State private var gameStartTime: Date = Date()
@State private var correctStreaks: Int = 0
@State private var currentStreak: Int = 0
```

Update flipCard function:
```swift
// In correct match section:
currentStreak += 1

// In wrong match section:
if currentStreak > 0 {
    correctStreaks += currentStreak
    currentStreak = 0
}
```

Add game end function:
```swift
private func endGame() {
    let stats = GameStats(
        score: score,
        timeTaken: Date().timeIntervalSince(gameStartTime),
        extraStat: correctStreaks,
        gameMode: gameMode,
        gameType: .memoryMatch,
        date: Date()
    )
    ScoreStorage.shared.saveScore(stats)
    // Show FinishGamePage
}
```

### **Step 5: Add Statistics Tracking to Other Games**
**Files**: `Games/SequenceRecall/SequenceRecallView.swift`, `Games/CardLocator/CardLocatorView.swift`, `Games/SpeedMatch/SpeedMatchView.swift`

For each game, add:
- Game start time tracking
- Extra stat tracking (levels completed, targets found, rounds completed)
- Game end function that creates GameStats and saves to ScoreStorage

### **Step 6: Integrate Finish Game Page**
**Files**: All game view files

Replace existing game over screens with:
```swift
if gameFinished {
    FinishGamePage(
        stats: createGameStats(),
        onPlayAgain: { /* restart game */ },
        onMainMenu: { /* go to main menu */ }
    )
}
```

## 🎯 **Key Points**
- Keep it simple - just the 5 required stats
- One common FinishGamePage for all games
- Use UserDefaults for simple storage
- Each game tracks its own extra stat
- Support both Timed and Infinite modes

## 📁 **Files to Create/Modify**
- `Models/GameStats.swift` (new)
- `Models/ScoreStorage.swift` (new) 
- `Components/FinishGamePage.swift` (new)
- All game view files (modify to add stats tracking)
- All game view files (modify to show FinishGamePage)

## ✅ **Success Criteria**
- [ ] FinishGamePage shows all 5 required stats
- [ ] Each game tracks its unique extra stat
- [ ] Best scores/times are saved and displayed
- [ ] Works for both Timed and Infinite modes
- [ ] Simple, clean implementation
