import SwiftUI

struct TrophyRoomSetupView: View {
    @Binding var hasCompletedFirstTimeSetup: Bool
    @StateObject private var trophyRoomStorage = TrophyRoomStorage()
    @State private var currentTrophyRoomIndex = 0
    @State private var showTrophyRoomForm = false
    @State private var selectedColor: Color = .pink
    @State private var createdTrophyRooms: [TrophyRoom] = []
    
    // These are just examples of trophy rooms, the user can customize them
    let trophyRoomTemplates: [TrophyRoom] = [
        TrophyRoom(name: "Memory Match Master", description: "Master the art of matching pairs", color: "blue"),
        TrophyRoom(name: "Sequence Recall Expert", description: "Become an expert at remembering sequences", color: "orange"),
        TrophyRoom(name: "Card Locator Champion", description: "Champion the card location game", color: "green"),
        TrophyRoom(name: "Speed Match Legend", description: "Achieve legendary speed in matching", color: "purple"),
        TrophyRoom(name: "Memory Grandmaster", description: "Reach the pinnacle of memory mastery", color: "pink")
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.pink.opacity(0.13), Color.purple.opacity(0.10), Color.blue.opacity(0.10)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Text("Create Your Trophy Rooms")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.pink)
                    
                    Text("Trophy Room \(currentTrophyRoomIndex + 1) of \(trophyRoomTemplates.count)")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        ForEach(0..<trophyRoomTemplates.count, id: \.self) { index in
                            Rectangle()
                                .fill(index <= currentTrophyRoomIndex ? Color.pink : Color.gray.opacity(0.3))
                                .frame(height: 4)
                                .cornerRadius(2)
                        }
                    }
                    .padding(.horizontal, 40)
                }
                
                // The preview of the current trophy room
                VStack(spacing: 20) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 80, weight: .thin))
                        .foregroundColor(Color.fromString(trophyRoomTemplates[currentTrophyRoomIndex].color))
                    
                    VStack(spacing: 12) {
                        Text(trophyRoomTemplates[currentTrophyRoomIndex].name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(trophyRoomTemplates[currentTrophyRoomIndex].description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
                
                Spacer()
                
                // Action buttons for the current trophy room
                VStack(spacing: 16) {
                    HStack(spacing: 20) {
                        Button("Skip") {
                            // Save default trophy room and skip to next
                            saveCurrentTrophyRoom()
                            currentTrophyRoomIndex = min(currentTrophyRoomIndex + 1, trophyRoomTemplates.count - 1)
                        }
                        .foregroundColor(.secondary)
                        
                        Button("Customize") {
                            showTrophyRoomForm = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.pink)
                        
                        // If the user is on the last trophy room, show the complete setup button
                        if currentTrophyRoomIndex == trophyRoomTemplates.count - 1 {
                            // Complete setup button
                            Button("Complete Setup") {
                                saveCurrentTrophyRoom()
                                saveAllTrophyRoomsToStorage()
                                hasCompletedFirstTimeSetup = true
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                        } else {
                            Button("Next") {
                                // Save current trophy room and move to next
                                saveCurrentTrophyRoom()
                                currentTrophyRoomIndex = min(currentTrophyRoomIndex + 1, trophyRoomTemplates.count - 1)
                            }
                            .buttonStyle(.bordered)
                            .tint(.pink)
                        }
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
            .padding(.top, 100)
            .padding(.horizontal, 20)
        }
        .sheet(isPresented: $showTrophyRoomForm) {
            TrophyRoomCustomizationView(
                trophyRoom: trophyRoomTemplates[currentTrophyRoomIndex],
                onSave: { customizedTrophyRoom in
                    // Save the customized trophy room to our tracking array
                    if currentTrophyRoomIndex < createdTrophyRooms.count {
                        createdTrophyRooms[currentTrophyRoomIndex] = customizedTrophyRoom
                    } else {
                        createdTrophyRooms.append(customizedTrophyRoom)
                    }
                    
                    currentTrophyRoomIndex = min(currentTrophyRoomIndex + 1, trophyRoomTemplates.count - 1)
                    showTrophyRoomForm = false
                },
                onColorSelected: { color in
                    selectedColor = color
                }
            )
        }
        .onAppear {
            // Clear existing trophy rooms when starting setup
            createdTrophyRooms.removeAll()
        }
    }

    private func saveCurrentTrophyRoom() {
        let currentTrophyRoom = trophyRoomTemplates[currentTrophyRoomIndex]
        // Use customized trophy room if available, otherwise use template
        let trophyRoomToSave = currentTrophyRoomIndex < createdTrophyRooms.count ? createdTrophyRooms[currentTrophyRoomIndex] : currentTrophyRoom
        print("Saving current trophy room: \(trophyRoomToSave.name) with color: \(trophyRoomToSave.color)")
        createdTrophyRooms.append(trophyRoomToSave)
    }
    
    private func saveAllTrophyRoomsToStorage() {
        print("=== SAVING ALL TROPHY ROOMS TO STORAGE ===")
        print("Created trophy rooms count: \(createdTrophyRooms.count)")
        
        // clear existing trophy rooms
        trophyRoomStorage.trophyRooms.removeAll()
        
        for (index, trophyRoom) in createdTrophyRooms.enumerated() {
            print("Saving trophy room \(index): \(trophyRoom.name) with color: \(trophyRoom.color)")
            
            // Add default achievements for each trophy room
            var trophyRoomWithAchievements = trophyRoom
            trophyRoomWithAchievements.achievements = getDefaultAchievements(for: index)
            
            // Use addTrophyRoom to ensure proper creation order and unlock status
            trophyRoomStorage.addTrophyRoom(trophyRoomWithAchievements)
            trophyRoomStorage.saveAchievements(for: trophyRoomWithAchievements)
        }
        
        // Mark setup as completed
        UserDefaults.standard.set(true, forKey: "hasCompletedFirstTimeSetup")
        print("Setup marked as completed")
        print("=== END SAVING TROPHY ROOMS ===")
    }
    
    private func getDefaultAchievements(for roomIndex: Int) -> [Achievement] {
        switch roomIndex {
        case 0: 
            return [
                Achievement(name: "First Steps", description: "Complete your first Memory Match game", type: .completion, badgeIcon: "1.circle.fill", targetValue: 1, gameType: .memoryMatch),
                Achievement(name: "Speed Demon", description: "Complete Memory Match in under 3 minutes", type: .speed, badgeIcon: "bolt.fill", targetValue: 180, gameType: .memoryMatch),
                Achievement(name: "Perfect Match", description: "Get 100% accuracy in Memory Match", type: .accuracy, badgeIcon: "checkmark.circle.fill", targetValue: 100, gameType: .memoryMatch),
                Achievement(name: "Memory Champion", description: "Complete 5 Memory Match games", type: .milestone, badgeIcon: "star.fill", targetValue: 5, gameType: .memoryMatch),
                Achievement(name: "Record Breaker", description: "Beat your previous best time", type: .record, badgeIcon: "trophy.fill", targetValue: 0, gameType: .memoryMatch)
            ]
        case 1: 
            return [
                Achievement(name: "Pattern Learner", description: "Complete your first Sequence Recall game", type: .completion, badgeIcon: "1.circle.fill", targetValue: 1, gameType: .sequenceRecall),
                Achievement(name: "Quick Thinker", description: "Complete Sequence Recall in under 2 minutes", type: .speed, badgeIcon: "bolt.fill", targetValue: 120, gameType: .sequenceRecall),
                Achievement(name: "Perfect Memory", description: "Get 100% accuracy in Sequence Recall", type: .accuracy, badgeIcon: "checkmark.circle.fill", targetValue: 100, gameType: .sequenceRecall),
                Achievement(name: "Sequence Master", description: "Complete 5 Sequence Recall games", type: .milestone, badgeIcon: "star.fill", targetValue: 5, gameType: .sequenceRecall),
                Achievement(name: "Speed Champion", description: "Beat your previous best time", type: .record, badgeIcon: "trophy.fill", targetValue: 0, gameType: .sequenceRecall)
            ]
        case 2:
            return [
                Achievement(name: "Eye Opener", description: "Complete your first Card Locator game", type: .completion, badgeIcon: "1.circle.fill", targetValue: 1, gameType: .cardLocator),
                Achievement(name: "Quick Eye", description: "Complete Card Locator in under 90 seconds", type: .speed, badgeIcon: "bolt.fill", targetValue: 90, gameType: .cardLocator),
                Achievement(name: "Perfect Vision", description: "Get 100% accuracy in Card Locator", type: .accuracy, badgeIcon: "checkmark.circle.fill", targetValue: 100, gameType: .cardLocator),
                Achievement(name: "Location Master", description: "Complete 5 Card Locator games", type: .milestone, badgeIcon: "star.fill", targetValue: 5, gameType: .cardLocator),
                Achievement(name: "Speed Vision", description: "Beat your previous best time", type: .record, badgeIcon: "trophy.fill", targetValue: 0, gameType: .cardLocator)
            ]
        case 3:
            return [
                Achievement(name: "Speed Starter", description: "Complete your first Speed Match game", type: .completion, badgeIcon: "1.circle.fill", targetValue: 1, gameType: .speedMatch),
                Achievement(name: "Lightning Fast", description: "Complete Speed Match in under 60 seconds", type: .speed, badgeIcon: "bolt.fill", targetValue: 60, gameType: .speedMatch),
                Achievement(name: "Perfect Speed", description: "Get 100% accuracy in Speed Match", type: .accuracy, badgeIcon: "checkmark.circle.fill", targetValue: 100, gameType: .speedMatch),
                Achievement(name: "Speed Master", description: "Complete 5 Speed Match games", type: .milestone, badgeIcon: "star.fill", targetValue: 5, gameType: .speedMatch),
                Achievement(name: "Speed Legend", description: "Beat your previous best time", type: .record, badgeIcon: "trophy.fill", targetValue: 0, gameType: .speedMatch)
            ]
        case 4:
            return [
                Achievement(name: "Grandmaster Initiate", description: "Complete all game types at least once", type: .completion, badgeIcon: "1.circle.fill", targetValue: 4, gameType: .general),
                Achievement(name: "Multi-Game Master", description: "Complete 3 different game types", type: .milestone, badgeIcon: "bolt.fill", targetValue: 3, gameType: .general),
                Achievement(name: "Perfect Player", description: "Get 100% accuracy in any game", type: .accuracy, badgeIcon: "checkmark.circle.fill", targetValue: 100, gameType: .general),
                Achievement(name: "Game Champion", description: "Complete 20 games total", type: .milestone, badgeIcon: "star.fill", targetValue: 20, gameType: .general),
                Achievement(name: "Memory Legend", description: "Unlock all previous trophy rooms", type: .record, badgeIcon: "trophy.fill", targetValue: 4, gameType: .general)
            ]
        default:
            return []
        }
    }
}

struct TrophyRoomCustomizationView: View {
    @State private var trophyRoom: TrophyRoom
    @State private var showAchievementSheet = false
    @State private var newAchievement = Achievement(name: "", type: .completion)
    let onSave: (TrophyRoom) -> Void
    let onColorSelected: (Color) -> Void
    
    // These are the colors that the user can choose from
    let availableColors = ["purple", "blue", "green", "pink", "orange", "red", "yellow", "indigo"]
    
    init(trophyRoom: TrophyRoom, onSave: @escaping (TrophyRoom) -> Void, onColorSelected: @escaping (Color) -> Void) {
        self._trophyRoom = State(initialValue: trophyRoom)
        self.onSave = onSave
        self.onColorSelected = onColorSelected
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Customize Your Trophy Room")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.pink)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Trophy room name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Trophy Room Name")
                                .font(.headline)
                                .foregroundColor(.primary)
                            TextField("Enter trophy room name", text: $trophyRoom.name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // Trophy room description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                                .foregroundColor(.primary)
                            TextField("Enter description", text: $trophyRoom.description, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(3...6)
                        }
                        
                        // Color selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Choose Color")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                                ForEach(availableColors, id: \.self) { colorName in
                                    Button(action: {
                                        trophyRoom.color = colorName
                                        let color = Color.fromString(colorName)
                                        onColorSelected(color)
                                    }) {
                                        Circle()
                                            .fill(Color.fromString(colorName))
                                            .frame(width: 50, height: 50)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.primary, lineWidth: trophyRoom.color == colorName ? 3 : 0)
                                            )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        
                        // Achievement creation section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Add Achievements")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                                Button("Add Achievement") {
                                    newAchievement = Achievement(name: "", type: .completion)
                                    showAchievementSheet = true
                                }
                                .buttonStyle(.bordered)
                                .tint(.blue)
                            }
                            
                            if trophyRoom.achievements.isEmpty {
                                Text("No achievements added yet. Add some achievements to help track your progress.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                VStack(spacing: 8) {
                                    ForEach(trophyRoom.achievements) { achievement in
                                        HStack {
                                            Image(systemName: "star.fill")
                                                .foregroundColor(.yellow)
                                            Text(achievement.name)
                                                .font(.body)
                                            Spacer()
                                            Button("Delete") {
                                                if let index = trophyRoom.achievements.firstIndex(where: { $0.id == achievement.id }) {
                                                    trophyRoom.achievements.remove(at: index)
                                                }
                                            }
                                            .foregroundColor(.red)
                                            .font(.caption)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                
                Spacer()
                
                // Save button
                Button("Save Trophy Room") {
                    onSave(trophyRoom)
                }
                .buttonStyle(.borderedProminent)
                .tint(.pink)
                .disabled(trophyRoom.name.isEmpty)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .navigationTitle("Customize Trophy Room")
        }
        .sheet(isPresented: $showAchievementSheet) {
            AchievementFormView(achievement: $newAchievement) {
                trophyRoom.achievements.append(newAchievement)
                showAchievementSheet = false
            }
        }
    }
}

extension Color {
    static func fromString(_ colorName: String) -> Color {
        switch colorName.lowercased() {
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
}

#Preview {
    TrophyRoomSetupView(hasCompletedFirstTimeSetup: .constant(false))
}
