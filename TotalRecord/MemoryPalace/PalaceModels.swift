import SwiftUI
import Foundation

// MARK: - Data Models
public struct Palace: Identifiable, Codable, Equatable {
    public let id: UUID
    public var name: String
    public var description: String
    public var color: String  // Store color as String for AppStorage compatibility
    public var rooms: [Room]
    public var isUnlocked: Bool = false
    public var creationOrder: Int // Track creation order for consistent positioning

    public init(id: UUID = UUID(), name: String, description: String = "", color: String = "purple", rooms: [Room] = [], isUnlocked: Bool = false, creationOrder: Int = 0) {
        self.id = id
        self.name = name
        self.description = description
        self.color = color
        self.rooms = rooms
        self.isUnlocked = isUnlocked
        self.creationOrder = creationOrder
    }
    
    // Implement Equatable
    public static func == (lhs: Palace, rhs: Palace) -> Bool {
        return lhs.id == rhs.id
    }
}

public struct Room: Identifiable, Codable, Equatable {
    public let id: UUID
    public var name: String
    public var description: String
    public var assignedCard: String?

    public init(id: UUID = UUID(), name: String, description: String = "") {
        self.id = id
        self.name = name
        self.description = description
    }
    
    // Implement Equatable
    public static func == (lhs: Room, rhs: Room) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Palace Storage Manager
public class PalaceStorage: ObservableObject {
    @Published public var palaces: [Palace] = []
    @Published public var currentPalace: Palace?
    
    // AppStorage keys for each palace
    private func palaceKey(for id: UUID, property: String) -> String {
        return "palace_\(id.uuidString)_\(property)"
    }
    
    // Load palaces from AppStorage
    public func loadPalaces() {
        if palaces.isEmpty {
            // Load saved palaces from UserDefaults
            loadSavedPalaces()
            
            // If no saved palaces exist, create an empty array
            if palaces.isEmpty {
                palaces = []
            }
            
            // Ensure first palace is unlocked if any exist
            if let firstPalace = palaces.first {
                if !firstPalace.isUnlocked {
                    palaces[0].isUnlocked = true
                    savePalaceUnlockStatus(palaces[0])
                }
            }
            
            // Load current palace
            loadCurrentPalace()
        }
    }
    // Add a new palace
    public func addPalace(_ palace: Palace) {
        // Assign creation order based on current count
        var newPalace = palace
        newPalace.creationOrder = palaces.count
        
        palaces.append(newPalace)
        savePalace(newPalace)
        
        // If this is the first palace, unlock it
        if palaces.count == 1 {
            newPalace.isUnlocked = true
            savePalaceUnlockStatus(newPalace)
        }
    }
    
    // Save palace unlock status
    public func savePalaceUnlockStatus(_ palace: Palace) {
        let unlockKey = palaceKey(for: palace.id, property: "isUnlocked")
        UserDefaults.standard.set(palace.isUnlocked, forKey: unlockKey)
    }
    
    // Load palace unlock status
    private func loadPalaceUnlockStatus(for palace: Palace) {
        let unlockKey = palaceKey(for: palace.id, property: "isUnlocked")
        if let index = palaces.firstIndex(where: { $0.id == palace.id }) {
            palaces[index].isUnlocked = UserDefaults.standard.bool(forKey: unlockKey)
        }
    }

    public func canUnlockPalace(_ palace: Palace) -> Bool {
        // Get the index of this palace
        guard let currentIndex = palaces.firstIndex(where: { $0.id == palace.id }) else { 
            print("❌ canUnlockPalace: Palace not found in array")
            return false 
        }
        
        // First palace is always unlockable
        if currentIndex == 0 { 
            print("✅ canUnlockPalace: First palace is always unlockable")
            return true 
        }
        
        // Check if previous palace is completed
        let previousPalace = palaces[currentIndex - 1]
        let isCompleted = isPalaceCompleted(previousPalace)
        print("🔍 canUnlockPalace: Palace '\(palace.name)' (index \(currentIndex)) - Previous palace '\(previousPalace.name)' completed: \(isCompleted)")
        return isCompleted
    }

    public func unlockPalace(_ palace: Palace) {
        guard canUnlockPalace(palace) else { return }
        
        if let index = palaces.firstIndex(where: { $0.id == palace.id }) {
            palaces[index].isUnlocked = true
            savePalaceUnlockStatus(palaces[index])
            setCurrentPalace(palaces[index]) // Change theme to unlocked palace
            
            // Post notification that palace was unlocked
            NotificationCenter.default.post(
                name: NSNotification.Name("PalaceUnlocked"),
                object: palace
            )
        }
    }

    public func getUnlockCondition(for palace: Palace) -> String {
        guard let currentIndex = palaces.firstIndex(where: { $0.id == palace.id }) else { return "" }
        
        if currentIndex == 0 { return "Available from start" }
        
        let previousPalace = palaces[currentIndex - 1]
        if isPalaceCompleted(previousPalace) {
            return "Ready to unlock!"
        } else {
            return "Complete \(previousPalace.name) to unlock"
        }
    }
    
    // Mark a palace as completed (call this when user finishes using it)
    public func markPalaceCompleted(_ palace: Palace) {
        let completionKey = "completed_\(palace.id.uuidString)"
        UserDefaults.standard.set(true, forKey: completionKey)
        print("✅ markPalaceCompleted: Marked '\(palace.name)' as completed with key: \(completionKey)")
        
        // NO AUTO-UNLOCK: Palaces must be manually unlocked by user
        // This ensures consistent behavior and user control
    }
    
    // Check if a palace has been completed
    public func isPalaceCompleted(_ palace: Palace) -> Bool {
        let completionKey = "completed_\(palace.id.uuidString)"
        let isCompleted = UserDefaults.standard.bool(forKey: completionKey)
        print("🔍 isPalaceCompleted: Palace '\(palace.name)' completed: \(isCompleted) (key: \(completionKey))")
        return isCompleted
    }
    
    // Reset all palaces to locked state (useful for testing)
    public func resetAllPalaces() {
        for (index, palace) in palaces.enumerated() {
            if index > 0 { // Keep first palace unlocked
                palaces[index].isUnlocked = false
                savePalace(palaces[index])
            }
        }
        
        // Clear all completion statuses
        for palace in palaces {
            UserDefaults.standard.removeObject(forKey: "completed_\(palace.id.uuidString)")
        }
    }
    
    // Clear all data and reset to initial state
    public func clearAllData() {
        // Clear all palace data
        let allKeys = UserDefaults.standard.dictionaryRepresentation().keys
        let palaceKeys = allKeys.filter { $0.hasPrefix("palace_") }
        let completionKeys = allKeys.filter { $0.hasPrefix("completed_") }
        
        // Remove all palace-related data
        for key in palaceKeys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        
        // Remove all completion data
        for key in completionKeys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        
        // Remove current palace
        UserDefaults.standard.removeObject(forKey: "currentPalaceId")
        
        // Reset setup flag to show setup screen again
        UserDefaults.standard.set(false, forKey: "hasCompletedFirstTimeSetup")
        
        // Clear in-memory palaces
        palaces = []
        currentPalace = nil
    }
    
    // Clear all data but keep setup completed (don't show setup screen again)
    public func clearAllDataKeepSetup() {
        // Clear all palace data
        let allKeys = UserDefaults.standard.dictionaryRepresentation().keys
        let palaceKeys = allKeys.filter { $0.hasPrefix("palace_") }
        let completionKeys = allKeys.filter { $0.hasPrefix("completed_") }
        
        // Remove all palace-related data
        for key in palaceKeys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        
        // Remove all completion data
        for key in completionKeys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        
        // Remove current palace
        UserDefaults.standard.removeObject(forKey: "currentPalaceId")
        
        // Keep setup completed so setup screen doesn't show again
        // hasCompletedFirstTimeSetup remains true
        
        // Clear in-memory palaces
        palaces = []
        currentPalace = nil
    }
    
    // Load saved palaces from UserDefaults
    private func loadSavedPalaces() {
        // Get all UserDefaults keys that start with "palace_"
        let allKeys = UserDefaults.standard.dictionaryRepresentation().keys
        let palaceKeys = allKeys.filter { $0.hasPrefix("palace_") }
        
        // Group keys by palace ID
        var palaceData: [String: [String: String]] = [:]
        
        for key in palaceKeys {
            let components = key.components(separatedBy: "_")
            if components.count >= 3 {
                let palaceId = components[1]
                let property = components[2]
                
                if palaceData[palaceId] == nil {
                    palaceData[palaceId] = [:]
                }
                
                if let value = UserDefaults.standard.string(forKey: key) {
                    palaceData[palaceId]?[property] = value
                }
            }
        }
        
        // Create Palace objects from the data
        palaces = []
        for (palaceId, properties) in palaceData {
            if let name = properties["name"],
               let description = properties["description"],
               let color = properties["color"],
               let uuid = UUID(uuidString: palaceId) {
                
                // Get creation order, default to 0 if not found
                let creationOrder = properties["creationOrder"].flatMap { Int($0) } ?? 0
                
                let palace = Palace(id: uuid, name: name, description: description, color: color, isUnlocked: false, creationOrder: creationOrder)
                palaces.append(palace)
                
                // Load unlock status for this palace
                loadPalaceUnlockStatus(for: palace)
                
                // Load rooms for this palace
                loadRooms(for: palace)
            }
        }
        
        // Sort palaces by creation order to maintain consistent sequence
        palaces.sort { $0.creationOrder < $1.creationOrder }
        
        // After loading palaces, also load the current palace
        loadCurrentPalace()
    }
    
    // Save palace to AppStorage
    public func savePalace(_ palace: Palace) {
        let nameKey = palaceKey(for: palace.id, property: "name")
        let descriptionKey = palaceKey(for: palace.id, property: "description")
        let colorKey = palaceKey(for: palace.id, property: "color")
        let orderKey = palaceKey(for: palace.id, property: "creationOrder")
        
        UserDefaults.standard.set(palace.name, forKey: nameKey)
        UserDefaults.standard.set(palace.description, forKey: descriptionKey)
        UserDefaults.standard.set(palace.color, forKey: colorKey)
        UserDefaults.standard.set(palace.creationOrder, forKey: orderKey)
        
        // Also save unlock status
        savePalaceUnlockStatus(palace)
    }
    
    // Delete palace from AppStorage
    public func deletePalace(_ palace: Palace) {
        let nameKey = palaceKey(for: palace.id, property: "name")
        let descriptionKey = palaceKey(for: palace.id, property: "description")
        let colorKey = palaceKey(for: palace.id, property: "color")
        let orderKey = palaceKey(for: palace.id, property: "creationOrder")
        
        UserDefaults.standard.removeObject(forKey: nameKey)
        UserDefaults.standard.removeObject(forKey: descriptionKey)
        UserDefaults.standard.removeObject(forKey: colorKey)
        UserDefaults.standard.removeObject(forKey: orderKey)
    }
    
    // Get binding for palace name
    public func palaceNameBinding(for palace: Palace) -> Binding<String> {
        return Binding(
            get: {
                let key = self.palaceKey(for: palace.id, property: "name")
                return UserDefaults.standard.string(forKey: key) ?? palace.name
            },
            set: { newValue in
                let key = self.palaceKey(for: palace.id, property: "name")
                UserDefaults.standard.set(newValue, forKey: key)
                // Update local palace array
                if let index = self.palaces.firstIndex(where: { $0.id == palace.id }) {
                    self.palaces[index].name = newValue
                }
            }
        )
    }
    
    // Get binding for palace color
    public func palaceColorBinding(for palace: Palace) -> Binding<String> {
        return Binding(
            get: {
                let key = self.palaceKey(for: palace.id, property: "color")
                return UserDefaults.standard.string(forKey: key) ?? palace.color
            },
            set: { newValue in
                let key = self.palaceKey(for: palace.id, property: "color")
                UserDefaults.standard.set(newValue, forKey: key)
                // Update local palace array
                if let index = self.palaces.firstIndex(where: { $0.id == palace.id }) {
                    self.palaces[index].color = newValue
                }
            }
        )
    }
    
    // Load rooms for a specific palace
    public func loadRooms(for palace: Palace) {
        let roomsKey = palaceKey(for: palace.id, property: "rooms")
        if let data = UserDefaults.standard.data(forKey: roomsKey),
           let rooms = try? JSONDecoder().decode([Room].self, from: data) {
            // Update the palace in the palaces array
            if let index = palaces.firstIndex(where: { $0.id == palace.id }) {
                palaces[index].rooms = rooms
            }
        }
    }
    
    // Save rooms for a specific palace
    public func saveRooms(for palace: Palace) {
        let roomsKey = palaceKey(for: palace.id, property: "rooms")
        if let data = try? JSONEncoder().encode(palace.rooms) {
            UserDefaults.standard.set(data, forKey: roomsKey)
        }
    }
    
    // Set the current active palace
    public func setCurrentPalace(_ palace: Palace) {
        currentPalace = palace
        // Save to UserDefaults for persistence
        UserDefaults.standard.set(palace.id.uuidString, forKey: "currentPalaceId")
        
        // Debug: Print when current palace is set
        print("Current palace set to: \(palace.name) with color: \(palace.color)")
    }
    
    // Load the current palace from UserDefaults
    public func loadCurrentPalace() {
        // Try to load the saved current palace first
        if let currentPalaceId = UserDefaults.standard.string(forKey: "currentPalaceId"),
           let uuid = UUID(uuidString: currentPalaceId),
           let savedPalace = palaces.first(where: { $0.id == uuid }) {
            currentPalace = savedPalace
            print("Loaded saved current palace: \(savedPalace.name) with color: \(savedPalace.color)")
        } else if let firstPalace = palaces.first {
            // Fallback to first palace if no saved current palace
            currentPalace = firstPalace
            print("No saved current palace, using first palace: \(firstPalace.name) with color: \(firstPalace.color)")
        } else {
            print("No palaces found to set as current")
        }
    }
    
    // Get the current palace color as SwiftUI Color
    public func getCurrentPalaceColor() -> Color {
        if let currentPalace = currentPalace {
            let color = getPalaceColor(currentPalace)
            print("Getting current palace color: \(currentPalace.name) -> \(currentPalace.color) -> \(color)")
            return color
        } else if let firstPalace = palaces.first {
            let color = getPalaceColor(firstPalace)
            print("No current palace, using first palace color: \(firstPalace.name) -> \(firstPalace.color) -> \(color)")
            return color
        }
        print("No palaces found, using default purple")
        return .purple // Default fallback
    }
    
    // Get palace color as SwiftUI Color
    public func getPalaceColor(_ palace: Palace) -> Color {
        switch palace.color.lowercased() {
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



// MARK: - Form Views
// Form to create or edit a Palace
public struct PalaceFormView: View {
    @Binding var palace: Palace
    var onSave: (() -> Void)?
    
    let availableColors = ["purple", "blue", "green", "pink", "orange", "red", "yellow", "indigo"]
    
    public var body: some View {
        Form {
            Section(header: Text("Palace Details")) {
                TextField("Palace Name", text: $palace.name)
                TextField("Description", text: $palace.description)
                
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
                                    .stroke(Color.primary, lineWidth: palace.color == color ? 2 : 0)
                            )
                            .onTapGesture {
                                palace.color = color
                            }
                    }
                }
            }
            Button("Save Palace") {
                onSave?()
            }
            .disabled(palace.name.isEmpty)
        }
        .navigationTitle(palace.id == UUID()  ? "New Palace" : "Edit Palace")
    }
}

// Form to create or edit a Room
public struct RoomFormView: View {
    @Binding var room: Room
    var onSave: (() -> Void)?
    public var body: some View {
        Form {
            Section(header: Text("Room Details")) {
                TextField("Room Name", text: $room.name)
                TextField("Description", text: $room.description)
            }
            Button("Save Room") {
                onSave?()
            }
            .disabled(room.name.isEmpty)
        }
        .navigationTitle(room.name.isEmpty ? "New Room" : "Edit Room")
    }
}

// MARK: - Parent View to Choose What to Create
public struct CreateMemoryItemView: View {
    @State private var selection: String? = nil
    @State private var palace = Palace(name: "")
    @State private var room = Room(name: "")
    var onCreatePalace: ((Palace) -> Void)?
    var onCreateRoom: ((Room) -> Void)?
    public var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("What would you like to create?")
                    .font(.title2)
                HStack(spacing: 24) {
                    Button(action: { selection = "palace" }) {
                        Text("New Palace")
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(10)
                    }
                    Button(action: { selection = "room" }) {
                        Text("New Room")
                            .padding()
                            .background(Color.purple.opacity(0.2))
                            .cornerRadius(10)
                    }
                }
                if selection == "palace" {
                    PalaceFormView(palace: $palace) {
                        onCreatePalace?(palace)
                        palace = Palace(name: "")
                        selection = nil
                    }
                } else if selection == "room" {
                    RoomFormView(room: $room) {
                        onCreateRoom?(room)
                        room = Room(name: "")
                        selection = nil
                    }
                }
            }
            .padding()
            .navigationTitle("Create Memory Item")
        }
    }
} 
