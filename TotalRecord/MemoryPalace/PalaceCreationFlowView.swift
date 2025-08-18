import SwiftUI

struct PalaceCreationFlowView: View {
    @Binding var hasCompletedFirstTimeSetup: Bool
    @StateObject private var palaceStorage = PalaceStorage()
    @State private var currentPalaceIndex = 0
    @State private var showPalaceForm = false
    @State private var selectedColor: Color = .pink
    @State private var createdPalaces: [Palace] = []
    
    // these are just examples of palaces, the user can customize them
    let palaceTemplates: [Palace] = [
        Palace(name: "My Study Room", description: "A quiet space for learning and memorizing facts.", color: "blue"),
        Palace(name: "Kitchen Memories", description: "Use familiar kitchen items to remember daily tasks.", color: "orange"),
        Palace(name: "Garden Path", description: "A peaceful garden to store nature-related memories.", color: "green"),
        Palace(name: "City Streets", description: "Navigate through familiar streets to find information.", color: "purple"),
        Palace(name: "Beach House", description: "A relaxing beach setting for creative memory storage.", color: "pink")
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.pink.opacity(0.13), Color.purple.opacity(0.10), Color.blue.opacity(0.10)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Text("Create Your Memory Palaces")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.pink)
                    
                    Text("Palace \(currentPalaceIndex + 1) of \(palaceTemplates.count)")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        ForEach(0..<palaceTemplates.count, id: \.self) { index in
                            Rectangle()
                                .fill(index <= currentPalaceIndex ? Color.pink : Color.gray.opacity(0.3))
                                .frame(height: 4)
                                .cornerRadius(2)
                        }
                    }
                    .padding(.horizontal, 40)
                }
                
                // the preview od the current palace
                VStack(spacing: 20) {
                    Image(systemName: "building.columns")
                        .font(.system(size: 80, weight: .thin))
                        .foregroundColor(Color.fromString(palaceTemplates[currentPalaceIndex].color))
                    
                    VStack(spacing: 12) {
                        Text(palaceTemplates[currentPalaceIndex].name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(palaceTemplates[currentPalaceIndex].description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
                
                Spacer()
                
                // Action buttons for the current palace
                VStack(spacing: 16) {
                    HStack(spacing: 20) {
                        Button("Skip") {
                            // Save default palace and skip to next
                            saveCurrentPalace()
                            currentPalaceIndex = min(currentPalaceIndex + 1, palaceTemplates.count - 1)
                        }
                        .foregroundColor(.secondary)
                        
                        Button("Customize") {
                            showPalaceForm = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.pink)
                        
                        // if the user is on the last palace, show the complete setup button
                        if currentPalaceIndex == palaceTemplates.count - 1 {
                            // Complete setup button
                            Button("Complete Setup") {
                                saveCurrentPalace()
                                saveAllPalacesToStorage()
                                hasCompletedFirstTimeSetup = true
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                        } else {
                            Button("Next") {
                                // Save current palace and move to next
                                saveCurrentPalace()
                                currentPalaceIndex = min(currentPalaceIndex + 1, palaceTemplates.count - 1)
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
        .sheet(isPresented: $showPalaceForm) {
            PalaceCustomizationView(
                palace: palaceTemplates[currentPalaceIndex],
                onSave: { customizedPalace in
                    // Save the customized palace to our tracking array
                    if currentPalaceIndex < createdPalaces.count {
                        createdPalaces[currentPalaceIndex] = customizedPalace
                    } else {
                        createdPalaces.append(customizedPalace)
                    }
                    
                    currentPalaceIndex = min(currentPalaceIndex + 1, palaceTemplates.count - 1)
                    showPalaceForm = false
                },
                onColorSelected: { color in
                    selectedColor = color
                }
            )
        }
        .onAppear {
            // Clear existing palaces when starting setup
            createdPalaces.removeAll()
        }
    }

    private func saveCurrentPalace() {
        let currentPalace = palaceTemplates[currentPalaceIndex]
        // Use customized palace if available, otherwise use template
        let palaceToSave = currentPalaceIndex < createdPalaces.count ? createdPalaces[currentPalaceIndex] : currentPalace
        print("Saving current palace: \(palaceToSave.name) with color: \(palaceToSave.color)")
        createdPalaces.append(palaceToSave)
    }
    
    private func saveAllPalacesToStorage() {
        print("=== SAVING ALL PALACES TO STORAGE ===")
        print("Created palaces count: \(createdPalaces.count)")
        
        // Clear existing palaces and save all created palaces to PalaceStorage
        palaceStorage.palaces.removeAll()
        
        for (index, palace) in createdPalaces.enumerated() {
            print("Saving palace \(index): \(palace.name) with color: \(palace.color)")
            palaceStorage.palaces.append(palace)
            palaceStorage.savePalace(palace)
            palaceStorage.saveRooms(for: palace)
        }
        
        // Set the first palace as current (unlocked)
        if let firstPalace = createdPalaces.first {
            print("Setting first palace as current: \(firstPalace.name) with color: \(firstPalace.color)")
            palaceStorage.setCurrentPalace(firstPalace)
        }
        
        // Mark setup as completed
        UserDefaults.standard.set(true, forKey: "hasCompletedFirstTimeSetup")
        print("Setup marked as completed")
        print("=== END SAVING PALACES ===")
    }
}

// MARK: - Palace Customization View
struct PalaceCustomizationView: View {
    @State private var palace: Palace
    @State private var showRoomSheet = false
    @State private var newRoom = Room(name: "")
    let onSave: (Palace) -> Void
    let onColorSelected: (Color) -> Void
    
    // these are the colors that the user can choose from
    let availableColors = ["purple", "blue", "green", "pink", "orange", "red", "yellow", "indigo"]
    
    init(palace: Palace, onSave: @escaping (Palace) -> Void, onColorSelected: @escaping (Color) -> Void) {
        self._palace = State(initialValue: palace)
        self.onSave = onSave
        self.onColorSelected = onColorSelected
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Customize Your Palace")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.pink)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Palace name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Palace Name")
                                .font(.headline)
                                .foregroundColor(.primary)
                            TextField("Enter palace name", text: $palace.name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // Palace description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                                .foregroundColor(.primary)
                            TextField("Enter description", text: $palace.description, axis: .vertical)
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
                                        palace.color = colorName
                                        let color = Color.fromString(colorName)
                                        onColorSelected(color)
                                    }) {
                                        Circle()
                                            .fill(Color.fromString(colorName))
                                            .frame(width: 50, height: 50)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.primary, lineWidth: palace.color == colorName ? 3 : 0)
                                            )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        
                        // Room creation section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Add Rooms")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                                Button("Add Room") {
                                    newRoom = Room(name: "")
                                    showRoomSheet = true
                                }
                                .buttonStyle(.bordered)
                                .tint(.blue)
                            }
                            
                            if palace.rooms.isEmpty {
                                Text("No rooms added yet. Add some rooms to help organize your memories.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                VStack(spacing: 8) {
                                    ForEach(palace.rooms) { room in
                                        HStack {
                                            Image(systemName: "door.left.hand.closed")
                                                .foregroundColor(.blue)
                                            Text(room.name)
                                                .font(.body)
                                            Spacer()
                                            Button("Delete") {
                                                if let index = palace.rooms.firstIndex(where: { $0.id == room.id }) {
                                                    palace.rooms.remove(at: index)
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
                Button("Save Palace") {
                    onSave(palace)
                }
                .buttonStyle(.borderedProminent)
                .tint(.pink)
                .disabled(palace.name.isEmpty)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .navigationTitle("Customize Palace")
        }
        .sheet(isPresented: $showRoomSheet) {
            RoomFormView(room: $newRoom) {
                palace.rooms.append(newRoom)
                showRoomSheet = false
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
    PalaceCreationFlowView(hasCompletedFirstTimeSetup: .constant(false))
}
