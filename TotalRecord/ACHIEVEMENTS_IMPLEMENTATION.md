# Achievements System Implementation

## 🎯 **Goal**
Create a working achievements system that tracks game progress and unlocks new rooms when completed.

## 📋 **What You Have**
- ✅ 5 Trophy Rooms (pre-created)
- ✅ Achievement models with progress tracking
- ✅ 4 Games: Memory Match, Speed Match, Sequence Recall, Card Locator
- ✅ ScoreStorage for game performance
- ✅ TrophyRoomStorage for room management

## 🏗️ **What You Need to Build**

### **1. Achievement Manager**
- Track game completion and update achievements
- Check when room is completed
- Reset data when room is completed
- Unlock next room

### **2. Game Integration**
- Add achievement tracking to each game's finish method
- Pass game stats (score, time, accuracy, extra stats)

### **3. Pre-defined Achievements for 5 Rooms**

#### **Room 1: "Memory Foundations" (Easy)**
**Memory Match:**
- Complete 3 games
- Get 70% accuracy
- Complete in under 3 minutes
- Match 2 pairs in a row

**Speed Match:**
- Complete 3 games
- Get 80% accuracy
- Answer in under 3 seconds average
- Answer 3 correctly in a row

**Sequence Recall:**
- Complete 3 games
- Get 80% accuracy
- Remember sequences of 3+ length
- Complete 2 games without mistakes

**Card Locator:**
- Complete 3 games
- Get 80% accuracy
- Find all targets in under 30 seconds
- Find 2 targets

#### **Room 2: "Rising Star" (Easy-Medium)**
**Memory Match:**
- Complete 5 games
- Get 80% accuracy
- Complete in under 2.5 minutes
- Match 3 pairs in a row

**Speed Match:**
- Complete 5 games
- Get 85% accuracy
- Answer in under 2.5 seconds average
- Answer 5 correctly in a row

**Sequence Recall:**
- Complete 5 games
- Get 85% accuracy
- Remember sequences of 4+ length
- Complete 3 games without mistakes

**Card Locator:**
- Complete 5 games
- Get 85% accuracy
- Find all targets in under 25 seconds
- Find 3 targets

#### **Room 3: "Memory Master" (Medium)**
**Memory Match:**
- Complete 8 games
- Get 90% accuracy
- Complete in under 2 minutes
- Match 5 pairs in a row

**Speed Match:**
- Complete 8 games
- Get 90% accuracy
- Answer in under 2 seconds average
- Answer 8 correctly in a row

**Sequence Recall:**
- Complete 8 games
- Get 90% accuracy
- Remember sequences of 5+ length
- Complete 5 games without mistakes

**Card Locator:**
- Complete 8 games
- Get 90% accuracy
- Find all targets in under 20 seconds
- Find 4 targets

#### **Room 4: "Brain Champion" (Medium-Hard)**
**Memory Match:**
- Complete 10 games
- Get 95% accuracy
- Complete in under 1.5 minutes
- Match 7 pairs in a row

**Speed Match:**
- Complete 10 games
- Get 95% accuracy
- Answer in under 1.5 seconds average
- Answer 10 correctly in a row

**Sequence Recall:**
- Complete 10 games
- Get 95% accuracy
- Remember sequences of 6+ length
- Complete 7 games without mistakes

**Card Locator:**
- Complete 10 games
- Get 95% accuracy
- Find all targets in under 15 seconds
- Find 5 targets

#### **Room 5: "Total Master" (Hard)**
**Memory Match:**
- Complete 12 games
- Get 98% accuracy
- Complete in under 1 minute
- Match 10 pairs in a row

**Speed Match:**
- Complete 12 games
- Get 98% accuracy
- Answer in under 1 second average
- Answer 12 correctly in a row

**Sequence Recall:**
- Complete 12 games
- Get 98% accuracy
- Remember sequences of 7+ length
- Complete 10 games without mistakes

**Card Locator:**
- Complete 12 games
- Get 98% accuracy
- Find all targets in under 10 seconds
- Find 6 targets

## 🔧 **Implementation Steps**

### **Step 1: Create AchievementManager.swift**
```swift
class AchievementManager: ObservableObject {
    static let shared = AchievementManager()
    
    @Published var currentRoom: TrophyRoom?
    @Published var achievements: [Achievement] = []
    
    // Track game completion and update achievements
    func trackGameCompletion(gameType: GameType, score: Int, time: TimeInterval, accuracy: Double, extraStat: Int)
    
    // Check if room is completed
    private func checkRoomCompletion()
    
    // Complete current room and unlock next
    private func completeCurrentRoom()
}
```

### **Step 2: Add Achievement Tracking to Games**

**MemoryMatchView.swift:**
```swift
// In finishGame() method
let accuracy = Double(correctMatches) / Double(numberOfPairs) * 100
let extraStat = longestStreak

AchievementManager.shared.trackGameCompletion(
    gameType: .memoryMatch,
    score: score,
    time: timeTaken,
    accuracy: accuracy,
    extraStat: extraStat
)
```

**SpeedMatchView.swift:**
```swift
// In finishGame() method
let accuracy = Double(correctAnswers) / Double(rounds) * 100
let extraStat = longestStreak

AchievementManager.shared.trackGameCompletion(
    gameType: .speedMatch,
    score: score,
    time: timeTaken,
    accuracy: accuracy,
    extraStat: extraStat
)
```

**SequenceRecallView.swift:**
```swift
// In finishGame() method
let accuracy = Double(correctSequences) / Double(sequenceLength) * 100
let extraStat = sequenceLength

AchievementManager.shared.trackGameCompletion(
    gameType: .sequenceRecall,
    score: score,
    time: timeTaken,
    accuracy: accuracy,
    extraStat: extraStat
)
```

**CardLocatorView.swift:**
```swift
// In finishGame() method
let accuracy = Double(targetsFound) / Double(numberOfTargets) * 100
let extraStat = targetsFound

AchievementManager.shared.trackGameCompletion(
    gameType: .cardLocator,
    score: score,
    time: timeTaken,
    accuracy: accuracy,
    extraStat: extraStat
)
```

### **Step 3: Create Achievement Progress UI**

**CurrentRoomView.swift:**
```swift
struct CurrentRoomView: View {
    @StateObject private var achievementManager = AchievementManager.shared
    
    var body: some View {
        VStack {
            // Memory Match Achievements
            AchievementSection(title: "Memory Match", achievements: memoryMatchAchievements)
            
            // Speed Match Achievements
            AchievementSection(title: "Speed Match", achievements: speedMatchAchievements)
            
            // Sequence Recall Achievements
            AchievementSection(title: "Sequence Recall", achievements: sequenceRecallAchievements)
            
            // Card Locator Achievements
            AchievementSection(title: "Card Locator", achievements: cardLocatorAchievements)
        }
    }
}
```

**AchievementCard.swift:**
```swift
struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(achievement.name)
                    .font(.headline)
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Progress bar
                ProgressView(value: achievement.currentValue, total: achievement.targetValue)
                    .progressViewStyle(LinearProgressViewStyle())
            }
            
            Spacer()
            
            // Completion status
            if achievement.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            } else {
                Text("\(Int(achievement.currentValue))/\(Int(achievement.targetValue))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(12)
    }
}
```

## 🎯 **Achievement Tracking Logic**

### **Achievement Types:**
- **Completion**: Track number of games completed
- **Accuracy**: Track accuracy percentage
- **Speed**: Track completion time
- **Milestone**: Track streaks, targets, sequence length

### **Progress Updates:**
```swift
// In AchievementManager
func trackGameCompletion(gameType: GameType, score: Int, time: TimeInterval, accuracy: Double, extraStat: Int) {
    // Update achievements for this game type
    for (index, achievement) in achievements.enumerated() {
        if achievement.gameType == gameType {
            var updatedAchievement = achievement
            
            switch achievement.type {
            case .completion:
                updatedAchievement.currentValue += 1
            case .accuracy:
                if accuracy >= achievement.targetValue {
                    updatedAchievement.currentValue = accuracy
                }
            case .speed:
                if time <= achievement.targetValue {
                    updatedAchievement.currentValue = achievement.targetValue - time
                }
            case .milestone:
                updatedAchievement.currentValue = Double(extraStat)
            }
            
            // Check if completed
            if updatedAchievement.currentValue >= updatedAchievement.targetValue && !updatedAchievement.isCompleted {
                updatedAchievement.isCompleted = true
                updatedAchievement.completedDate = Date()
            }
            
            achievements[index] = updatedAchievement
        }
    }
    
    // Check if room is completed
    checkRoomCompletion()
}
```

## 🚀 **Room Progression**

### **Room Completion:**
- When all achievements in a room are completed
- Reset ALL game data (scores, times, stats)
- Unlock next room
- Show completion celebration

### **Data Reset:**
- Clear all game scores and stats
- Keep room progress and achievements
- User starts fresh with new targets

## 📱 **UI Features**

### **Achievement Display:**
- Progress bars for each achievement
- Completion status indicators
- Grouped by game type
- Real-time progress updates

### **Room Status:**
- Current room progress
- Next room preview
- Completion celebrations
- Unlock animations

## 🎉 **End Result**

A working achievements system where:
- ✅ Games track progress and update achievements
- ✅ Rooms unlock when all achievements are completed
- ✅ Data resets when room is completed
- ✅ Users can see their progress and achievements
- ✅ Progressive difficulty keeps users engaged

This gives you everything you need to implement working achievements with your existing 5 rooms! 🎯
