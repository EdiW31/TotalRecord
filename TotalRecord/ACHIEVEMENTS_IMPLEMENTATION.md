# Achievements System Implementation

## 🎯 **Goal**
Create a working achievements system that tracks game progress and unlocks new rooms when completed.

## 📋 **What You Have**
- ✅ **TrophyRoomModels.swift** - Complete data models with Achievement, TrophyRoom, GameType, AchievementType
- ✅ **TrophyRoomListView.swift** - UI for viewing rooms and achievements
- ✅ **TrophyRoomStorage** - Room management with achievement tracking methods
- ✅ **4 Games**: Memory Match, Speed Match, Sequence Recall, Card Locator
- ✅ **ScoreStorage** - Game performance tracking
- ✅ **Achievement Types**: Speed, Accuracy, Completion, Milestone, Record
- ✅ **Game Types**: Memory Match, Sequence Recall, Card Locator, Speed Match, General

## 🏗️ **What You Need to Build**

### **1. Enhance Existing TrophyRoomStorage**
- Use existing `trackGamePerformance()` method
- Improve `updateAchievementProgress()` logic
- Add room completion checking
- Add data reset when room is completed

### **2. Game Integration**
- Add achievement tracking to each game's finish method
- Use existing `TrophyRoomStorage.trackGamePerformance()`
- Pass game stats (score, time, accuracy, extra stats)

### **3. Pre-defined Achievements for 5 Rooms**
- Use existing Achievement model structure
- Set up achievements with proper GameType and AchievementType
- Add to existing room creation system

#### **Room 1: "Memory Foundations" (Easy)**
```swift
// Memory Match Achievements
Achievement(name: "Memory Master 1", description: "Complete 3 Memory Match games", type: .completion, targetValue: 3, gameType: .memoryMatch),
Achievement(name: "Perfect Memory 1", description: "Get 70% accuracy in Memory Match", type: .accuracy, targetValue: 70, gameType: .memoryMatch),
Achievement(name: "Speed Memory 1", description: "Complete Memory Match in under 3 minutes", type: .speed, targetValue: 180, gameType: .memoryMatch),
Achievement(name: "Memory Streak 1", description: "Match 2 pairs in a row", type: .milestone, targetValue: 2, gameType: .memoryMatch),

// Speed Match Achievements
Achievement(name: "Speed Demon 1", description: "Complete 3 Speed Match games", type: .completion, targetValue: 3, gameType: .speedMatch),
Achievement(name: "Lightning Fast 1", description: "Get 80% accuracy in Speed Match", type: .accuracy, targetValue: 80, gameType: .speedMatch),
Achievement(name: "Quick Reflexes 1", description: "Answer in under 3 seconds average", type: .speed, targetValue: 3, gameType: .speedMatch),
Achievement(name: "Speed Streak 1", description: "Answer 3 correctly in a row", type: .milestone, targetValue: 3, gameType: .speedMatch),

// Sequence Recall Achievements
Achievement(name: "Sequence Master 1", description: "Complete 3 Sequence Recall games", type: .completion, targetValue: 3, gameType: .sequenceRecall),
Achievement(name: "Pattern Genius 1", description: "Get 80% accuracy in Sequence Recall", type: .accuracy, targetValue: 80, gameType: .sequenceRecall),
Achievement(name: "Memory Length 1", description: "Remember sequences of 3+ length", type: .milestone, targetValue: 3, gameType: .sequenceRecall),
Achievement(name: "Perfect Recall 1", description: "Complete 2 games without mistakes", type: .milestone, targetValue: 2, gameType: .sequenceRecall),

// Card Locator Achievements
Achievement(name: "Card Detective 1", description: "Complete 3 Card Locator games", type: .completion, targetValue: 3, gameType: .cardLocator),
Achievement(name: "Eagle Eye 1", description: "Get 80% accuracy in Card Locator", type: .accuracy, targetValue: 80, gameType: .cardLocator),
Achievement(name: "Quick Finder 1", description: "Find all targets in under 30 seconds", type: .speed, targetValue: 30, gameType: .cardLocator),
Achievement(name: "Target Master 1", description: "Find 2 targets", type: .milestone, targetValue: 2, gameType: .cardLocator)
```

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

### **Step 1: Enhance TrophyRoomStorage**
```swift
// Add to TrophyRoomStorage class
func trackGameCompletion(gameType: GameType, score: Int, time: TimeInterval, accuracy: Double, extraStat: Int) {
    // Use existing trackGamePerformance method
    trackGamePerformance(gameType: gameType, score: Double(score), time: time, accuracy: accuracy)
    
    // Update extra stats for milestone achievements
    updateExtraStats(gameType: gameType, extraStat: extraStat)
    
    // Check room completion
    checkRoomCompletions()
}

private func updateExtraStats(gameType: GameType, extraStat: Int) {
    // Update milestone achievements for current room
    if let currentRoom = currentTrophyRoom {
        for (index, achievement) in currentRoom.achievements.enumerated() {
            if achievement.gameType == gameType && achievement.type == .milestone {
                var updatedAchievement = achievement
                updatedAchievement.currentValue = Double(extraStat)
                
                if updatedAchievement.currentValue >= updatedAchievement.targetValue && !updatedAchievement.isCompleted {
                    updatedAchievement.isCompleted = true
                    updatedAchievement.completedDate = Date()
                }
                
                // Update in storage
                if let roomIndex = trophyRooms.firstIndex(where: { $0.id == currentRoom.id }) {
                    trophyRooms[roomIndex].achievements[index] = updatedAchievement
                    saveAchievements(for: trophyRooms[roomIndex])
                }
            }
        }
    }
}
```

### **Step 2: Add Achievement Tracking to Games**

**MemoryMatchView.swift:**
```swift
// In finishGame() method
let accuracy = Double(correctMatches) / Double(numberOfPairs) * 100
let extraStat = longestStreak

// Use existing TrophyRoomStorage
let trophyRoomStorage = TrophyRoomStorage()
trophyRoomStorage.trackGameCompletion(
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

let trophyRoomStorage = TrophyRoomStorage()
trophyRoomStorage.trackGameCompletion(
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

let trophyRoomStorage = TrophyRoomStorage()
trophyRoomStorage.trackGameCompletion(
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

let trophyRoomStorage = TrophyRoomStorage()
trophyRoomStorage.trackGameCompletion(
    gameType: .cardLocator,
    score: score,
    time: timeTaken,
    accuracy: accuracy,
    extraStat: extraStat
)
```

### **Step 3: Enhance Existing UI**

**Update TrophyRoomAchievementsView.swift:**
```swift
// Add to existing TrophyRoomAchievementsView
// Group achievements by game type
private var memoryMatchAchievements: [Achievement] {
    trophyRoom.achievements.filter { $0.gameType == .memoryMatch }
}

private var speedMatchAchievements: [Achievement] {
    trophyRoom.achievements.filter { $0.gameType == .speedMatch }
}

private var sequenceRecallAchievements: [Achievement] {
    trophyRoom.achievements.filter { $0.gameType == .sequenceRecall }
}

private var cardLocatorAchievements: [Achievement] {
    trophyRoom.achievements.filter { $0.gameType == .cardLocator }
}

// Add achievement sections to the view
VStack(spacing: 20) {
    // Memory Match Section
    if !memoryMatchAchievements.isEmpty {
        AchievementSection(title: "Memory Match", achievements: memoryMatchAchievements)
    }
    
    // Speed Match Section
    if !speedMatchAchievements.isEmpty {
        AchievementSection(title: "Speed Match", achievements: speedMatchAchievements)
    }
    
    // Sequence Recall Section
    if !sequenceRecallAchievements.isEmpty {
        AchievementSection(title: "Sequence Recall", achievements: sequenceRecallAchievements)
    }
    
    // Card Locator Section
    if !cardLocatorAchievements.isEmpty {
        AchievementSection(title: "Card Locator", achievements: cardLocatorAchievements)
    }
}
```

**Create AchievementSection.swift:**
```swift
struct AchievementSection: View {
    let title: String
    let achievements: [Achievement]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            ForEach(achievements) { achievement in
                AchievementCard(achievement: achievement)
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(16)
    }
}
```

**Update AchievementDisplayCard.swift:**
```swift
// Enhance existing AchievementDisplayCard
struct AchievementDisplayCard: View {
    let achievement: Achievement
    var onDelete: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: achievement.badgeIcon)
                    .foregroundColor(achievement.isCompleted ? .green : .yellow)
                    .font(.title2)
                
                Spacer()
                
                if let onDelete = onDelete {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            Text(achievement.name)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            if !achievement.description.isEmpty {
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            // Progress indicator for all types
            ProgressView(value: achievement.currentValue, total: achievement.targetValue)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
            
            // Progress text
            Text("\(Int(achievement.currentValue))/\(Int(achievement.targetValue))")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            // Completion status
            if achievement.isCompleted {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Completed")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(achievement.isCompleted ? Color.green.opacity(0.1) : Color.white.opacity(0.9))
                .shadow(color: .blue.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}
```

## 🎯 **Achievement Tracking Logic**

### **Achievement Types (from your existing model):**
- **Completion**: Track number of games completed
- **Accuracy**: Track accuracy percentage
- **Speed**: Track completion time
- **Milestone**: Track streaks, targets, sequence length
- **Record**: Track personal records

### **Progress Updates (using your existing TrophyRoomStorage):**
```swift
// Your existing updateAchievementProgress method already handles:
switch achievement.type {
case .completion:
    updatedAchievement.currentValue += 1
case .speed:
    if time < achievement.targetValue {
        updatedAchievement.currentValue = achievement.targetValue - time
    }
case .accuracy:
    if accuracy >= achievement.targetValue {
        updatedAchievement.currentValue = accuracy
    }
case .milestone:
    updatedAchievement.currentValue += 1
case .record:
    // Handle in separate personal record method
    break
}
```

### **Room Completion (using your existing system):**
```swift
// Your existing checkRoomCompletions method already:
private func checkRoomCompletions() {
    for room in trophyRooms {
        if room.isUnlocked && !room.isCompleted {
            let allAchievementsCompleted = room.achievements.allSatisfy { $0.isCompleted }
            if allAchievementsCompleted {
                markTrophyRoomCompleted(room)
                // Post notification for UI updates
                NotificationCenter.default.post(
                    name: NSNotification.Name("TrophyRoomCompleted"),
                    object: room
                )
            }
        }
    }
}
```

## 🚀 **Room Progression (using your existing system)**

### **Room Completion:**
- Your existing `checkRoomCompletions()` method handles this
- When all achievements in a room are completed
- `markTrophyRoomCompleted()` is called
- Notification is posted for UI updates

### **Data Reset:**
- Use your existing `clearAllDataKeepSetup()` method
- Clear all game scores and stats
- Keep room progress and achievements
- User starts fresh with new targets

## 📱 **UI Features (enhance your existing UI)**

### **Achievement Display:**
- Your existing `AchievementDisplayCard` already shows progress
- Add progress bars for all achievement types
- Group achievements by game type
- Real-time progress updates

### **Room Status:**
- Your existing `TrophyRoomCard` shows room status
- Add completion percentage display
- Use existing unlock animations
- Show achievement progress

## 🎯 **Key Implementation Points**

### **1. Use Your Existing Structure:**
- ✅ `TrophyRoomStorage` for room management
- ✅ `Achievement` model with progress tracking
- ✅ `TrophyRoomListView` for UI
- ✅ Existing achievement tracking methods

### **2. Add Game Integration:**
- Call `trophyRoomStorage.trackGameCompletion()` in each game's finish method
- Pass correct game stats (score, time, accuracy, extra stats)

### **3. Create Pre-defined Achievements:**
- Use your existing `Achievement` model
- Set up 16 achievements per room (4 per game)
- Use proper `GameType` and `AchievementType` enums

### **4. Enhance UI:**
- Group achievements by game type in `TrophyRoomAchievementsView`
- Add progress bars to `AchievementDisplayCard`
- Show completion status and progress

## 🎉 **End Result**

A working achievements system that builds on your existing foundation:
- ✅ Uses your existing TrophyRoom system
- ✅ Games track progress and update achievements
- ✅ Rooms unlock when all achievements are completed
- ✅ Data resets when room is completed
- ✅ Users can see their progress and achievements
- ✅ Progressive difficulty keeps users engaged

This gives you everything you need to implement working achievements with your existing 5 rooms! 🎯
