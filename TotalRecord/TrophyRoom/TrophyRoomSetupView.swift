import SwiftUI

struct TrophyRoomSetupView: View {
    @Binding var hasCompletedFirstTimeSetup: Bool
    @ObservedObject private var trophyRoomStorage = TrophyRoomStorage.shared
    @State private var currentTrophyRoomIndex = 0
    @State private var showTrophyRoomForm = false
    @State private var selectedColor: Color = .pink
    @State private var createdTrophyRooms: [TrophyRoom] = []
    
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
                            Button("Complete Setup") {
                                saveCurrentTrophyRoom()
                                saveAllTrophyRoomsToStorage()
                                hasCompletedFirstTimeSetup = true
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                        } else {
                            Button("Next") {
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
            createdTrophyRooms.removeAll()
        }
    }

    private func saveCurrentTrophyRoom() {
        let currentTrophyRoom = trophyRoomTemplates[currentTrophyRoomIndex]
        let trophyRoomToSave = currentTrophyRoomIndex < createdTrophyRooms.count ? createdTrophyRooms[currentTrophyRoomIndex] : currentTrophyRoom
        createdTrophyRooms.append(trophyRoomToSave)
    }
    
    private func saveAllTrophyRoomsToStorage() {
        
        // clear existing trophy rooms
        trophyRoomStorage.trophyRooms.removeAll()
        
        for (index, trophyRoom) in createdTrophyRooms.enumerated() {
            print("Saving trophy room: \(trophyRoom.name)")
            
            var trophyRoomWithAchievements = trophyRoom
            trophyRoomWithAchievements.achievements = createRoomAchievements(for: index, roomName: trophyRoom.name)
            
            trophyRoomStorage.addTrophyRoom(trophyRoomWithAchievements)
            trophyRoomStorage.saveAchievements(for: trophyRoomWithAchievements)
        }
        
        UserDefaults.standard.set(true, forKey: "hasCompletedFirstTimeSetup")
    }
    
    private func createRoomAchievements(for roomIndex: Int, roomName: String) -> [Achievement] {
        var allAchievements: [Achievement] = []
        
        // Calculate difficulty multiplier based on room index (0-4)
        let difficultyMultiplier = Double(roomIndex + 1)
        let baseGames = 3 + roomIndex // Start with 3 games, increase by 1 each room
        let baseTime = 180.0 - (Double(roomIndex) * 30.0) // Start at 3 min, decrease by 30s each room
        let baseAccuracy = 70.0 + (Double(roomIndex) * 5.0) // Start at 70%, increase by 5% each room
        
        // Memory Match Achievements
        allAchievements.append(contentsOf: [
            Achievement(
                name: "\(roomName) - Memory Starter",
                description: "Complete \(Int(baseGames)) Memory Match games",
                type: .completion,
                badgeIcon: "brain.head.profile",
                targetValue: Double(baseGames),
                gameType: .memoryMatch
            ),
            Achievement(
                name: "\(roomName) - Memory Master",
                description: "Get \(Int(baseAccuracy))% accuracy in Memory Match",
                type: .accuracy,
                badgeIcon: "target",
                targetValue: baseAccuracy,
                gameType: .memoryMatch
            ),
            Achievement(
                name: "\(roomName) - Memory Streak",
                description: "Get \(Int(2 * difficultyMultiplier)) streaks in Memory Match",
                type: .milestone,
                badgeIcon: "star.fill",
                targetValue: 2 * difficultyMultiplier,
                gameType: .memoryMatch
            )
        ])
        
        // Speed Match Achievements
        allAchievements.append(contentsOf: [
            Achievement(
                name: "\(roomName) - Speed Starter",
                description: "Complete \(Int(baseGames)) Speed Match games",
                type: .completion,
                badgeIcon: "bolt.fill",
                targetValue: Double(baseGames),
                gameType: .speedMatch
            ),
            // Achievement(
            //     name: "\(roomName) - Speed Demon",
            //     description: "Complete Speed Match in under \(Int(baseTime * 0.7)) seconds",
            //     type: .speed,
            //     badgeIcon: "timer",
            //     targetValue: baseTime * 0.7,
            //     gameType: .speedMatch
            // ),
            Achievement(
                name: "\(roomName) - Speed Accuracy",
                description: "Get \(Int(baseAccuracy))% accuracy in Speed Match",
                type: .accuracy,
                badgeIcon: "target",
                targetValue: baseAccuracy,
                gameType: .speedMatch
            ),
            Achievement(
                name: "\(roomName) - Speed Streak",
                description: "Get \(Int(3 * difficultyMultiplier)) streaks in Speed Match",
                type: .milestone,
                badgeIcon: "star.fill",
                targetValue: 3 * difficultyMultiplier,
                gameType: .speedMatch
            )
        ])
        
        // Sequence Recall Achievements
        allAchievements.append(contentsOf: [
            Achievement(
                name: "\(roomName) - Sequence Starter",
                description: "Complete \(Int(baseGames)) Sequence Recall games",
                type: .completion,
                badgeIcon: "list.number",
                targetValue: Double(baseGames),
                gameType: .sequenceRecall
            ),
            // Achievement(
            //     name: "\(roomName) - Sequence Speed",
            //     description: "Complete Sequence Recall in under \(Int(baseTime)) seconds",
            //     type: .speed,
            //     badgeIcon: "timer",
            //     targetValue: baseTime,
            //     gameType: .sequenceRecall
            // ),
            Achievement(
                name: "\(roomName) - Sequence Master",
                description: "Get \(Int(baseAccuracy))% accuracy in Sequence Recall",
                type: .accuracy,
                badgeIcon: "target",
                targetValue: baseAccuracy,
                gameType: .sequenceRecall
            ),
            Achievement(
                name: "\(roomName) - Sequence Length",
                description: "Remember sequences of length \(Int(3 + roomIndex))",
                type: .milestone,
                badgeIcon: "star.fill",
                targetValue: Double(3 + roomIndex),
                gameType: .sequenceRecall
            )
        ])
        
        // Card Locator Achievements
        allAchievements.append(contentsOf: [
            Achievement(
                name: "\(roomName) - Locator Starter",
                description: "Complete \(Int(baseGames)) Card Locator games",
                type: .completion,
                badgeIcon: "eye.fill",
                targetValue: Double(baseGames),
                gameType: .cardLocator
            ),
            // Achievement(
            //     name: "\(roomName) - Locator Speed",
            //     description: "Complete Card Locator in under \(Int(baseTime * 0.8)) seconds",
            //     type: .speed,
            //     badgeIcon: "timer",
            //     targetValue: baseTime * 0.8,
            //     gameType: .cardLocator
            // ),
            Achievement(
                name: "\(roomName) - Locator Accuracy",
                description: "Get \(Int(baseAccuracy))% accuracy in Card Locator",
                type: .accuracy,
                badgeIcon: "target",
                targetValue: baseAccuracy,
                gameType: .cardLocator
            ),
            Achievement(
                name: "\(roomName) - Locator Targets",
                description: "Find \(Int(4 + roomIndex)) targets in Card Locator",
                type: .milestone,
                badgeIcon: "star.fill",
                targetValue: Double(4 + roomIndex),
                gameType: .cardLocator
            )
        ])
        
        return allAchievements
    }
}

struct TrophyRoomCustomizationView: View {
    @State private var trophyRoom: TrophyRoom
    @State private var customName: String = ""
    @State private var customDescription: String = ""
    @State private var selectedColor: String = ""
    let onSave: (TrophyRoom) -> Void
    let onColorSelected: (Color) -> Void
    
    // These are the colors that the user can choose from
    let availableColors = ["purple", "blue", "green", "pink", "orange", "red", "yellow", "indigo"]
    
    init(trophyRoom: TrophyRoom, onSave: @escaping (TrophyRoom) -> Void, onColorSelected: @escaping (Color) -> Void) {
        self._trophyRoom = State(initialValue: trophyRoom)
        self._customName = State(initialValue: trophyRoom.name)
        self._customDescription = State(initialValue: trophyRoom.description)
        self._selectedColor = State(initialValue: trophyRoom.color)
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
                            TextField("Enter trophy room name", text: $customName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // Trophy room description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                                .foregroundColor(.primary)
                            TextField("Enter description", text: $customDescription, axis: .vertical)
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
                                        selectedColor = colorName
                                        let color = Color.fromString(colorName)
                                        onColorSelected(color)
                                    }) {
                                        Circle()
                                            .fill(Color.fromString(colorName))
                                            .frame(width: 50, height: 50)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.primary, lineWidth: selectedColor == colorName ? 3 : 0)
                                            )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        
                    }
                    .padding(.horizontal, 24)
                }
                
                Spacer()
                
                // Save button
                Button("Save Trophy Room") {
                    // Create updated trophy room with custom values
                    var updatedTrophyRoom = trophyRoom
                    updatedTrophyRoom.name = customName
                    updatedTrophyRoom.description = customDescription
                    updatedTrophyRoom.color = selectedColor
                    
                    onSave(updatedTrophyRoom)
                }
                .buttonStyle(.borderedProminent)
                .tint(.pink)
                .disabled(customName.isEmpty)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .navigationTitle("Customize Trophy Room")
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
