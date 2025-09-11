import SwiftUI
import Foundation

public struct TrophyRoom: Identifiable, Codable, Equatable {
    public let id: UUID
    public var name: String
    public var description: String
    public var color: String  // Store color as String for AppStorage compatibility
    public var achievements: [Achievement]  // Changed from rooms
    public var isUnlocked: Bool = false
    public var creationOrder: Int // Track creation order for consistent positioning
    public var isCompleted: Bool = false  // NEW: track room completion
    public var trophyIcon: String = "trophy.fill"  // NEW: trophy icon
    public var gameType: GameType?  // NEW: which game this achievement is for

    public init(id: UUID = UUID(), name: String, description: String = "", color: String = "purple", achievements: [Achievement] = [], isUnlocked: Bool = false, creationOrder: Int = 0, isCompleted: Bool = false, trophyIcon: String = "trophy.fill", gameType: GameType? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.color = color
        self.achievements = achievements
        self.isUnlocked = isUnlocked
        self.creationOrder = creationOrder
        self.isCompleted = isCompleted
        self.trophyIcon = trophyIcon
        self.gameType = gameType
    }
    
    // Implement Equatable
    public static func == (lhs: TrophyRoom, rhs: TrophyRoom) -> Bool {
        return lhs.id == rhs.id
    }
}

public struct Achievement: Identifiable, Codable, Equatable {
    public let id: UUID
    public var name: String
    public var description: String
    public var type: AchievementType  // NEW: categorize achievements
    public var isCompleted: Bool = false
    public var completedDate: Date?  // NEW: track when completed
    public var badgeIcon: String  // NEW: achievement badge icon
    public var targetValue: Double  // NEW: target to complete (score, time, etc.)
    public var currentValue: Double = 0  // NEW: current progress
    public var gameType: GameType?  // NEW: which game this achievement is for

   
    public init(id: UUID = UUID(), name: String, description: String = "", type: AchievementType, isCompleted: Bool = false, completedDate: Date? = nil, badgeIcon: String = "trophy.fill", targetValue: Double = 0, currentValue: Double = 0, gameType: GameType? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.type = type
        self.isCompleted = isCompleted
        self.completedDate = completedDate
        self.badgeIcon = badgeIcon
        self.targetValue = targetValue
        self.currentValue = currentValue
        self.gameType = gameType
    }
    
    // Implement Equatable
    public static func == (lhs: Achievement, rhs: Achievement) -> Bool {
        return lhs.id == rhs.id
    }
}

public enum AchievementType: String, Codable, CaseIterable {
    case speed = "Speed"
    case accuracy = "Accuracy"
    case completion = "Completion"
    case milestone = "Milestone"
    case record = "Record"
}

public enum GameType: String, Codable, CaseIterable {
    case memoryMatch = "Memory Match"
    case sequenceRecall = "Sequence Recall"
    case cardLocator = "Card Locator"
    case speedMatch = "Speed Match"
    case general = "General"
}

public struct TrophyScore: Codable {
    public var totalScore: Int = 0
    public var unlockedRooms: Int = 0
    public var completedAchievements: Int = 0
    public var personalRecords: Int = 0
    public var overallProgress: Double = 0.0
    public var gameType: GameType?  // which game this score is for
    
    // Calculate total score
    public mutating func calculateTotalScore() {
        totalScore = (unlockedRooms * 100) + 
                    (completedAchievements * 25) + 
                    (personalRecords * 50)
        
        // Calculate overall progress (0.0 to 1.0)
        let totalPossibleRooms = 5
        let totalPossibleAchievements = 25 // 5 rooms × 5 achievements each
        overallProgress = Double(unlockedRooms + completedAchievements) / Double(totalPossibleRooms + totalPossibleAchievements)
    }
}

public class TrophyRoomStorage: ObservableObject {
    public static let shared = TrophyRoomStorage()
    @Published public var trophyRooms: [TrophyRoom] = []
    @Published public var currentTrophyRoom: TrophyRoom?
    @Published public var trophyScore: TrophyScore = TrophyScore()
    
    private init() {
    }
    
    func trackGameCompletion(gameType: GameType, score: Int, time: TimeInterval, accuracy: Double, extraStat: Int) {
        trackGamePerformance(gameType: gameType, score: Double(score), time: time, accuracy: accuracy)
        updateExtraStats(gameType: gameType, extraStat: extraStat)
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

    
    // AppStorage keys for each trophy room
    private func trophyRoomKey(for id: UUID, property: String) -> String {
        return "trophyRoom_\(id.uuidString)_\(property)"
    }
    
    // Load trophy rooms from AppStorage
    public func loadTrophyRooms() {
        if trophyRooms.isEmpty {
            loadSavedTrophyRooms()
            
            if trophyRooms.isEmpty {
                trophyRooms = []
            }
            
            if let firstTrophyRoom = trophyRooms.first {
                if !firstTrophyRoom.isUnlocked {
                    trophyRooms[0].isUnlocked = true
                    saveTrophyRoomUnlockStatus(trophyRooms[0])
                }
            }
            
            loadCurrentTrophyRoom()
        }
        
        // Debug: Print loaded trophy rooms and achievements
        print("🏆 LOADED TROPHY ROOMS:")
        for (index, room) in trophyRooms.enumerated() {
            print("   Room \(index + 1): \(room.name)")
            print("     Unlocked: \(room.isUnlocked)")
            print("     Completed: \(room.isCompleted)")
            print("     Achievements: \(room.achievements.count)")
            for (achievementIndex, achievement) in room.achievements.enumerated() {
                print("       \(achievementIndex + 1). \(achievement.name) (\(achievement.type.rawValue))")
                print("         Game: \(achievement.gameType?.rawValue ?? "General")")
                print("         Progress: \(achievement.currentValue)/\(achievement.targetValue)")
                print("         Completed: \(achievement.isCompleted)")
            }
        }
    }
    
    public func addTrophyRoom(_ trophyRoom: TrophyRoom) {
        var newTrophyRoom = trophyRoom
        newTrophyRoom.creationOrder = trophyRooms.count
        
        trophyRooms.append(newTrophyRoom)
        saveTrophyRoom(newTrophyRoom)
        
        // unlock for the first trophy room
        if trophyRooms.count == 1 {
            newTrophyRoom.isUnlocked = true
            saveTrophyRoomUnlockStatus(newTrophyRoom)
        }
    }
    
    // Save trophy room unlock status
    public func saveTrophyRoomUnlockStatus(_ trophyRoom: TrophyRoom) {
        let unlockKey = trophyRoomKey(for: trophyRoom.id, property: "isUnlocked")
        UserDefaults.standard.set(trophyRoom.isUnlocked, forKey: unlockKey)
    }
    
    // Load trophy room unlock status
    private func loadTrophyRoomUnlockStatus(for trophyRoom: TrophyRoom) {
        let unlockKey = trophyRoomKey(for: trophyRoom.id, property: "isUnlocked")
        if let index = trophyRooms.firstIndex(where: { $0.id == trophyRoom.id }) {
            trophyRooms[index].isUnlocked = UserDefaults.standard.bool(forKey: unlockKey)
        }
    }

    public func canUnlockTrophyRoom(_ trophyRoom: TrophyRoom) -> Bool {
        guard let currentIndex = trophyRooms.firstIndex(where: { $0.id == trophyRoom.id }) else { 
            return false
        }
        
        if currentIndex == 0 { 
            return true 
        }
        
        // check for the previous room if it is completed
        let previousTrophyRoom = trophyRooms[currentIndex - 1]
        let isCompleted = isTrophyRoomCompleted(previousTrophyRoom)
        return isCompleted
    }

    public func unlockTrophyRoom(_ trophyRoom: TrophyRoom) {
        guard canUnlockTrophyRoom(trophyRoom) else { return }
        
        if let index = trophyRooms.firstIndex(where: { $0.id == trophyRoom.id }) {
            trophyRooms[index].isUnlocked = true
            saveTrophyRoomUnlockStatus(trophyRooms[index])
            setCurrentTrophyRoom(trophyRooms[index]) // Change theme to unlocked trophy room
            
            // Post notification that trophy room was unlocked
            NotificationCenter.default.post(
                name: NSNotification.Name("TrophyRoomUnlocked"),
                object: trophyRoom
            )
        }
    }

    // Function to get the unlock condition for a trophy room
    public func getUnlockCondition(for trophyRoom: TrophyRoom) -> String {
        guard let currentIndex = trophyRooms.firstIndex(where: { $0.id == trophyRoom.id }) else { return "" }
        
        if currentIndex == 0 { return "Available from start" }
        
        let previousTrophyRoom = trophyRooms[currentIndex - 1]
        if isTrophyRoomCompleted(previousTrophyRoom) {
            return "Ready to unlock!"
        } else {
            return "Complete \(previousTrophyRoom.name) to unlock"
        }
    }
    
    // Mark a trophy room as completed (call this when user finishes using it)
    public func markTrophyRoomCompleted(_ trophyRoom: TrophyRoom) {
        let completionKey = "completed_\(trophyRoom.id.uuidString)"
        UserDefaults.standard.set(true, forKey: completionKey)        
    }
    
    // Check if a trophy room has been completed
    public func isTrophyRoomCompleted(_ trophyRoom: TrophyRoom) -> Bool {
        let completionKey = "completed_\(trophyRoom.id.uuidString)"
        let isCompleted = UserDefaults.standard.bool(forKey: completionKey)
        return isCompleted
    }
    
    // Clear all data and reset to initial state
    public func clearAllData() {
        let allKeys = UserDefaults.standard.dictionaryRepresentation().keys
        let trophyRoomKeys = allKeys.filter { $0.hasPrefix("trophyRoom_") }
        let completionKeys = allKeys.filter { $0.hasPrefix("completed_") }
        
        // Remove all trophy room data
        for key in trophyRoomKeys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        
        // Remove all completion data
        for key in completionKeys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        
        UserDefaults.standard.removeObject(forKey: "currentTrophyRoomId")
        
        UserDefaults.standard.set(false, forKey: "hasCompletedFirstTimeSetup")
        
        trophyRooms = []
        currentTrophyRoom = nil 
    }
    
    public func clearAllDataKeepSetup() {
        // Clear all trophy room data
        let allKeys = UserDefaults.standard.dictionaryRepresentation().keys
        let trophyRoomKeys = allKeys.filter { $0.hasPrefix("trophyRoom_") }
        let completionKeys = allKeys.filter { $0.hasPrefix("completed_") }
        
        // Remove all trophy room-related data
        for key in trophyRoomKeys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        
        // Remove all completion data
        for key in completionKeys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        
        // Remove current trophy room
        UserDefaults.standard.removeObject(forKey: "currentTrophyRoomId")

        // Clear in-memory trophy rooms
        trophyRooms = []
        currentTrophyRoom = nil
    }
    
    // Load saved trophy rooms from UserDefaults
    private func loadSavedTrophyRooms() {
        // Get all UserDefaults keys that start with "trophyRoom_"
        let allKeys = UserDefaults.standard.dictionaryRepresentation().keys
        let trophyRoomKeys = allKeys.filter { $0.hasPrefix("trophyRoom_") }
        
        // Group keys by trophy room ID
        var trophyRoomData: [String: [String: String]] = [:]
        
        for key in trophyRoomKeys {
            let components = key.components(separatedBy: "_")
            if components.count >= 3 {
                let trophyRoomId = components[1]
                let property = components[2]
                
                if trophyRoomData[trophyRoomId] == nil {
                    trophyRoomData[trophyRoomId] = [:]
                }
                
                if let value = UserDefaults.standard.string(forKey: key) {
                    trophyRoomData[trophyRoomId]?[property] = value
                }
            }
        }
        
        // Create TrophyRoom objects from the data
        trophyRooms = []
        for (trophyRoomId, properties) in trophyRoomData {
            if let name = properties["name"],
               let description = properties["description"],
               let color = properties["color"],
               let uuid = UUID(uuidString: trophyRoomId) {
                
                // Get creation order, default to 0 if not found
                let creationOrder = properties["creationOrder"].flatMap { Int($0) } ?? 0
                
                let trophyRoom = TrophyRoom(id: uuid, name: name, description: description, color: color, achievements: [], isUnlocked: false, creationOrder: creationOrder)
                trophyRooms.append(trophyRoom)
                
                // Load unlock status for this trophy room
                loadTrophyRoomUnlockStatus(for: trophyRoom)
                
                // Load achievements for this trophy room
                loadAchievements(for: trophyRoom)
            }
        }
        
        // Sort trophy rooms by creation order to maintain consistent sequence
        trophyRooms.sort { $0.creationOrder < $1.creationOrder }
        
        // After loading trophy rooms, also load the current trophy room
        loadCurrentTrophyRoom()
    }
    
    // Save trophy room to AppStorage
    public func saveTrophyRoom(_ trophyRoom: TrophyRoom) {
        let nameKey = trophyRoomKey(for: trophyRoom.id, property: "name")
        let descriptionKey = trophyRoomKey(for: trophyRoom.id, property: "description")
        let colorKey = trophyRoomKey(for: trophyRoom.id, property: "color")
        let orderKey = trophyRoomKey(for: trophyRoom.id, property: "creationOrder")
        
        UserDefaults.standard.set(trophyRoom.name, forKey: nameKey)
        UserDefaults.standard.set(trophyRoom.description, forKey: descriptionKey)
        UserDefaults.standard.set(trophyRoom.color, forKey: colorKey)
        UserDefaults.standard.set(trophyRoom.creationOrder, forKey: orderKey)
        
        // Also save unlock status
        saveTrophyRoomUnlockStatus(trophyRoom)
    }
    
    // Delete trophy room from AppStorage
    public func deleteTrophyRoom(_ trophyRoom: TrophyRoom) {
        let nameKey = trophyRoomKey(for: trophyRoom.id, property: "name")
        let descriptionKey = trophyRoomKey(for: trophyRoom.id, property: "description")
        let colorKey = trophyRoomKey(for: trophyRoom.id, property: "color")
        let orderKey = trophyRoomKey(for: trophyRoom.id, property: "creationOrder")
        
        UserDefaults.standard.removeObject(forKey: nameKey)
        UserDefaults.standard.removeObject(forKey: descriptionKey)
        UserDefaults.standard.removeObject(forKey: colorKey)
        UserDefaults.standard.removeObject(forKey: orderKey)
    }
    
    // Get binding for trophy room name
    public func trophyRoomNameBinding(for trophyRoom: TrophyRoom) -> Binding<String> {
        return Binding(
            get: {
                let key = self.trophyRoomKey(for: trophyRoom.id, property: "name")
                return UserDefaults.standard.string(forKey: key) ?? trophyRoom.name
            },
            set: { newValue in
                let key = self.trophyRoomKey(for: trophyRoom.id, property: "name")
                UserDefaults.standard.set(newValue, forKey: key)
                // Update local trophy room array
                if let index = self.trophyRooms.firstIndex(where: { $0.id == trophyRoom.id }) {
                    self.trophyRooms[index].name = newValue
                }
            }
        )
    }
    
    // Get binding for trophy room color
    public func trophyRoomColorBinding(for trophyRoom: TrophyRoom) -> Binding<String> {
        return Binding(
            get: {
                let key = self.trophyRoomKey(for: trophyRoom.id, property: "color")
                return UserDefaults.standard.string(forKey: key) ?? trophyRoom.color
            },
            set: { newValue in
                let key = self.trophyRoomKey(for: trophyRoom.id, property: "color")
                UserDefaults.standard.set(newValue, forKey: key)
                // Update local trophy room array
                if let index = self.trophyRooms.firstIndex(where: { $0.id == trophyRoom.id }) {
                    self.trophyRooms[index].color = newValue
                }
            }
        )
    }
    
    // Load achievements for a specific trophy room
    public func loadAchievements(for trophyRoom: TrophyRoom) {
        let achievementsKey = trophyRoomKey(for: trophyRoom.id, property: "achievements")
        if let data = UserDefaults.standard.data(forKey: achievementsKey),
           let achievements = try? JSONDecoder().decode([Achievement].self, from: data) {
            // Update the trophy room in the trophyRooms array
            if let index = trophyRooms.firstIndex(where: { $0.id == trophyRoom.id }) {
                trophyRooms[index].achievements = achievements
            }
        }
    }
    
    // Save achievements for a specific trophy room
    public func saveAchievements(for trophyRoom: TrophyRoom) {
        let achievementsKey = trophyRoomKey(for: trophyRoom.id, property: "achievements")
        if let data = try? JSONEncoder().encode(trophyRoom.achievements) {
            UserDefaults.standard.set(data, forKey: achievementsKey)
        }
    }
    
    // Set the current active trophy room
    public func setCurrentTrophyRoom(_ trophyRoom: TrophyRoom) {
        currentTrophyRoom = trophyRoom
        UserDefaults.standard.set(trophyRoom.id.uuidString, forKey: "currentTrophyRoomId")
    }
    
    // Load the current trophy room from UserDefaults
    public func loadCurrentTrophyRoom() {
        if let currentTrophyRoomId = UserDefaults.standard.string(forKey: "currentTrophyRoomId"),
           let uuid = UUID(uuidString: currentTrophyRoomId),
           let savedTrophyRoom = trophyRooms.first(where: { $0.id == uuid }) {
            currentTrophyRoom = savedTrophyRoom
        } else if let firstTrophyRoom = trophyRooms.first {
            currentTrophyRoom = firstTrophyRoom
        } else {
            // do nothing
        }
    }
    
    // Get the current trophy room color as SwiftUI Color
    public func getCurrentTrophyRoomColor() -> Color {
        if let currentTrophyRoom = currentTrophyRoom {
            let color = getTrophyRoomColor(currentTrophyRoom)
            return color
        } else if let firstTrophyRoom = trophyRooms.first {
            let color = getTrophyRoomColor(firstTrophyRoom)
            return color
        }
        return .purple 
    }
    
    // Get trophy room color as SwiftUI Color
    public func getTrophyRoomColor(_ trophyRoom: TrophyRoom) -> Color {
        switch trophyRoom.color.lowercased() {
        case "purple": return .purple
        case "blue": return .blue
        case "green": return .green
        case "pink": return .pink
        case "orange": return .orange
        case "red": return .red
        case "yellow": return .yellow
        case "indigo": return .indigo
        default: return .purple
        }
    }
    
    // NEW: Achievement tracking methods
    public func trackGamePerformance(gameType: GameType, score: Double, time: Double, accuracy: Double) {
        // Update all relevant achievements in UNLOCKED rooms only
        for (roomIndex, room) in trophyRooms.enumerated() {
            if room.isUnlocked && !room.isCompleted {
                for (achievementIndex, achievement) in room.achievements.enumerated() {
                    if achievement.gameType == gameType {
                        updateAchievementProgress(achievement, score: score, time: time, accuracy: accuracy)
                    }
                }
            }
        }
        
        // Check for completions and unlock next room if needed
        checkRoomCompletions()
        updateTrophyScore()
    }
    
    public func checkAchievementCompletion(for achievement: Achievement) {
        // this method is called when the achievement is completed
    }
    
    public func unlockNextRoom() {
        // Find the next locked room and unlock it if current room is completed
        for (index, room) in trophyRooms.enumerated() {
            if !room.isUnlocked && index > 0 {
                let previousRoom = trophyRooms[index - 1]
                if isTrophyRoomCompleted(previousRoom) {
                    unlockTrophyRoom(room)
                    break
                }
            }
        }
    }
    
    public func updateTrophyScore() {
        // Calculate unlocked rooms and completed achievements
        trophyScore.unlockedRooms = trophyRooms.filter { $0.isUnlocked }.count
        trophyScore.completedAchievements = trophyRooms.flatMap { $0.achievements }.filter { $0.isCompleted }.count
        
        // Calculate total score
        trophyScore.calculateTotalScore()
    }
    
    private func updateAchievementProgress(_ achievement: Achievement, score: Double, time: Double, accuracy: Double) {
        // Find the achievement in the trophy room and update it
        for (roomIndex, room) in trophyRooms.enumerated() {
            if let achievementIndex = room.achievements.firstIndex(where: { $0.id == achievement.id }) {
                var updatedAchievement = room.achievements[achievementIndex] // Get the current achievement from storage
                
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
                
                // Check if achievement is completed
                if updatedAchievement.currentValue >= updatedAchievement.targetValue && !updatedAchievement.isCompleted {
                    updatedAchievement.isCompleted = true
                    updatedAchievement.completedDate = Date()
                }
                
                // Update the achievement in the array
                trophyRooms[roomIndex].achievements[achievementIndex] = updatedAchievement
                
                // Save the updated achievements
                saveAchievements(for: trophyRooms[roomIndex])
                break
            }
        }
    }
    
    private func checkRoomCompletions() {
        // Check if any room has all achievements completed
        for (roomIndex, room) in trophyRooms.enumerated() {
            if room.isUnlocked && !room.isCompleted {
                let allAchievementsCompleted = room.achievements.allSatisfy { $0.isCompleted }
                if allAchievementsCompleted {
                    // Mark room as completed
                    markTrophyRoomCompleted(room)
                    
                    // Clear room data to save memory
                    clearRoomData(room)
                    
                    // Unlock next room if available
                    unlockNextRoom(after: roomIndex)
                    
                    // Post notification for UI updates
                    NotificationCenter.default.post(
                        name: NSNotification.Name("TrophyRoomCompleted"),
                        object: room
                    )
                    
                    print("🎉 Room '\(room.name)' completed! Data cleared and next room unlocked.")
                }
            }
        }
    }
    
    // Clear achievement data for a completed room to save memory
    private func clearRoomData(_ room: TrophyRoom) {
        if let index = trophyRooms.firstIndex(where: { $0.id == room.id }) {
            // Reset all achievement progress but keep the room structure
            var clearedRoom = room
            clearedRoom.achievements = clearedRoom.achievements.map { achievement in
                var clearedAchievement = achievement
                clearedAchievement.currentValue = 0
                clearedAchievement.isCompleted = false
                clearedAchievement.completedDate = nil
                return clearedAchievement
            }
            clearedRoom.isCompleted = true
            
            trophyRooms[index] = clearedRoom
            saveAchievements(for: clearedRoom)
            
            print("🗑️ Cleared data for room '\(room.name)' to save memory")
        }
    }
    
    // Unlock the next room after completing current one
    private func unlockNextRoom(after currentIndex: Int) {
        let nextIndex = currentIndex + 1
        if nextIndex < trophyRooms.count {
            let nextRoom = trophyRooms[nextIndex]
            if !nextRoom.isUnlocked {
                unlockTrophyRoom(nextRoom)
                print("🔓 Unlocked next room: '\(nextRoom.name)'")
            }
        }
    }
    
    // DEBUG: Print all room and achievement status
    public func printAllRoomsStatus() {
        print("📊 ALL ROOMS STATUS:")
        print("   Total Rooms: \(trophyRooms.count)")
        
        if trophyRooms.isEmpty {
            print("   ❌ NO ROOMS FOUND! Have you completed the setup?")
            return
        }
        
        for (index, room) in trophyRooms.enumerated() {
            print("   Room \(index + 1): \(room.name)")
            print("     Unlocked: \(room.isUnlocked)")
            print("     Completed: \(room.isCompleted)")
            print("     Achievements: \(room.achievements.count)")
            
            let completedCount = room.achievements.filter { $0.isCompleted }.count
            print("     Completed Achievements: \(completedCount)/\(room.achievements.count)")
            
            // Only show first few achievements to avoid spam
            let achievementsToShow = Array(room.achievements.prefix(3))
            for achievement in achievementsToShow {
                print("       - \(achievement.name): \(achievement.currentValue)/\(achievement.targetValue) (\(achievement.isCompleted ? "✅" : "⏳"))")
            }
            if room.achievements.count > 3 {
                print("       ... and \(room.achievements.count - 3) more achievements")
            }
        }
    }
    
    // DEBUG: Check if setup is completed
    public func checkSetupStatus() {
        let hasCompletedSetup = UserDefaults.standard.bool(forKey: "hasCompletedFirstTimeSetup")
        print("🔧 SETUP STATUS:")
        print("   Has Completed Setup: \(hasCompletedSetup)")
        print("   Total Rooms: \(trophyRooms.count)")
        
        if !hasCompletedSetup {
            print("   ❌ SETUP NOT COMPLETED! Please complete the trophy room setup first.")
        } else if trophyRooms.isEmpty {
            print("   ❌ SETUP COMPLETED BUT NO ROOMS LOADED! There might be an issue with room loading.")
        } else {
            print("   ✅ Setup completed and rooms loaded successfully!")
        }
    }
    
    // NEW: Update achievements based on ScoreStorage data
    public func updateAchievementsFromScoreStorage() {
        print("📊 UPDATING ACHIEVEMENTS FROM SCORE STORAGE")
        
        for (roomIndex, room) in trophyRooms.enumerated() {
            if room.isUnlocked && !room.isCompleted {
                print("   Updating room: \(room.name)")
                
                for (achievementIndex, achievement) in room.achievements.enumerated() {
                    // Skip achievements without a game type
                    guard achievement.gameType != nil else {
                        continue
                    }
                    
                    var updatedAchievement = achievement
                    
                    // For now, we'll use a simplified approach that doesn't require ScoreStorage imports
                    // This will be updated when the games call trackGameCompletion
                    switch achievement.type {
                    case .completion:
                        // Keep existing current value, will be updated by trackGameCompletion
                        break
                        
                    case .speed:
                        // Keep existing current value, will be updated by trackGameCompletion
                        break
                        
                    case .accuracy:
                        // Keep existing current value, will be updated by trackGameCompletion
                        break
                        
                    case .milestone:
                        // Keep existing current value, will be updated by trackGameCompletion
                        break
                        
                    case .record:
                        // Keep existing current value, will be updated by trackGameCompletion
                        break
                    }
                    
                    // Check if achievement is completed
                    if updatedAchievement.currentValue >= updatedAchievement.targetValue && !updatedAchievement.isCompleted {
                        updatedAchievement.isCompleted = true
                        updatedAchievement.completedDate = Date()
                        print("     ✅ ACHIEVEMENT COMPLETED: \(updatedAchievement.name)")
                    }
                    
                    // Update if achievement was completed
                    if updatedAchievement.isCompleted != achievement.isCompleted {
                        trophyRooms[roomIndex].achievements[achievementIndex] = updatedAchievement
                        print("     📈 Updated: \(updatedAchievement.name) - \(updatedAchievement.currentValue)/\(updatedAchievement.targetValue)")
                    }
                }
                
                // Save updated achievements
                saveAchievements(for: trophyRooms[roomIndex])
            }
        }
        
        // Check for room completions
        checkRoomCompletions()
    }
    
}

// Form to create or edit a Trophy Room
public struct TrophyRoomFormView: View {
    @Binding var trophyRoom: TrophyRoom
    var onSave: (() -> Void)?
    
    let availableColors = ["purple", "blue", "green", "pink", "orange", "red", "yellow", "indigo"]
    
    public var body: some View {
        Form {
            Section(header: Text("Trophy Room Details")) {
                TextField("Trophy Room Name", text: $trophyRoom.name)
                TextField("Description", text: $trophyRoom.description)
                
                // Color picker
                HStack {
                    Text("Color")
                    Spacer()
                    ForEach(availableColors, id: \.self) { color in
                        Circle()
                            .fill(Color(color))
                            .frame(width: 30, height: 30)
                            .overlay(
                                Circle()
                                    .stroke(Color.primary, lineWidth: trophyRoom.color == color ? 2 : 0)
                            )
                            .onTapGesture {
                                trophyRoom.color = color
                            }
                    }
                }
            }
            Button("Save Trophy Room") {
                onSave?()
            }
            .disabled(trophyRoom.name.isEmpty)
        }
        .navigationTitle(trophyRoom.id == UUID()  ? "New Trophy Room" : "Edit Trophy Room")
    }
}

// Form to create or edit an Achievement
public struct AchievementFormView: View {
    @Binding var achievement: Achievement
    var onSave: (() -> Void)?
    
    public var body: some View {
        VStack(spacing: 20) {
            TextField("Achievement Name", text: $achievement.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Description", text: $achievement.description)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            HStack {
                Text("Type:")
                Spacer()
                Picker("Type", selection: $achievement.type) {
                    ForEach(AchievementType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            
            HStack {
                Text("Game Type:")
                Spacer()
                Picker("Game Type", selection: $achievement.gameType) {
                    Text("General").tag(nil as GameType?)
                    ForEach(GameType.allCases, id: \.self) { gameType in
                        Text(gameType.rawValue).tag(gameType as GameType?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            
            HStack {
                Text("Target Value:")
                Spacer()
                TextField("Target", value: $achievement.targetValue, format: .number)
                    .frame(width: 80)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            Button("Save Achievement") {
                onSave?()
            }
            .buttonStyle(.borderedProminent)
            .disabled(achievement.name.isEmpty)
        }
        .padding()
        .navigationTitle(achievement.name.isEmpty ? "New Achievement" : "Edit Achievement")
    }
}

public struct CreateMemoryItemView: View {
    @State private var selection: String? = nil
    @State private var trophyRoom = TrophyRoom(name: "")
    @State private var achievement = Achievement(name: "", type: .completion)
    var onCreateTrophyRoom: ((TrophyRoom) -> Void)?
    var onCreateAchievement: ((Achievement) -> Void)?
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("What would you like to create?")
                    .font(.title2)
                HStack(spacing: 24) {
                    Button(action: { selection = "trophyRoom" }) {
                        Text("New Trophy Room")
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(10)
                    }
                    Button(action: { selection = "achievement" }) {
                        Text("New Achievement")
                            .padding()
                            .background(Color.purple.opacity(0.2))
                            .cornerRadius(10)
                    }
                }
                if selection == "trophyRoom" {
                    TrophyRoomFormView(trophyRoom: $trophyRoom) {
                        onCreateTrophyRoom?(trophyRoom)
                        trophyRoom = TrophyRoom(name: "")
                        selection = nil
                    }
                } else if selection == "achievement" {
                    AchievementFormView(achievement: $achievement) {
                        onCreateAchievement?(achievement)
                        achievement = Achievement(name: "", type: .completion)
                        selection = nil
                    }
                }
            }
            .padding()
            .navigationTitle("Create Memory Item")
        }
    }
} 
