import SwiftUI
import Foundation

// MARK: - Data Models
public struct Palace: Identifiable, Codable {
    public let id: UUID
    public var name: String
    public var description: String
    public var color: String  // Store color as String for AppStorage compatibility
    public var rooms: [Room]

    public init(id: UUID = UUID(), name: String, description: String = "", color: String = "purple", rooms: [Room] = []) {
        self.id = id
        self.name = name
        self.description = description
        self.color = color
        self.rooms = rooms
    }
}

public struct Room: Identifiable, Codable {
    public let id: UUID
    public var name: String
    public var description: String
    public var assignedCard: String?

    public init(id: UUID = UUID(), name: String, description: String = "") {
        self.id = id
        self.name = name
        self.description = description
    }
}

// MARK: - Palace Storage Manager
public class PalaceStorage: ObservableObject {
    @Published public var palaces: [Palace] = []
    
    // AppStorage keys for each palace
    private func palaceKey(for id: UUID, property: String) -> String {
        return "palace_\(id.uuidString)_\(property)"
    }
    
    // Load palaces from AppStorage
    public func loadPalaces() {
        // Check if user has completed first-time setup
        let hasCompletedSetup = UserDefaults.standard.bool(forKey: "hasCompletedFirstTimeSetup")
        
        if hasCompletedSetup {
            // User has completed setup, load saved palaces from UserDefaults
            loadSavedPalaces()
        } else {
            // First time setup - load default palaces
            if palaces.isEmpty {
                palaces = [
                    Palace(name: "The Grand Library", description: "A vast library with endless shelves, perfect for storing facts and stories.", color: "purple"),
                    Palace(name: "Sunny Beach House", description: "A bright, airy house by the sea, ideal for visualizing lists and sequences.", color: "blue"),
                    Palace(name: "Mountain Retreat", description: "A peaceful mountain cabin, great for memorizing complex concepts.", color: "green"),
                    Palace(name: "City Art Gallery", description: "A modern gallery with colorful rooms for creative memory journeys.", color: "pink")
                ]
            }
        }
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
                
                let palace = Palace(id: uuid, name: name, description: description, color: color)
                palaces.append(palace)
                
                // Load rooms for this palace
                loadRooms(for: palace)
            }
        }
    }
    
    // Save palace to AppStorage
    public func savePalace(_ palace: Palace) {
        let nameKey = palaceKey(for: palace.id, property: "name")
        let descriptionKey = palaceKey(for: palace.id, property: "description")
        let colorKey = palaceKey(for: palace.id, property: "color")
        
        UserDefaults.standard.set(palace.name, forKey: nameKey)
        UserDefaults.standard.set(palace.description, forKey: descriptionKey)
        UserDefaults.standard.set(palace.color, forKey: colorKey)
    }
    
    // Delete palace from AppStorage
    public func deletePalace(_ palace: Palace) {
        let nameKey = palaceKey(for: palace.id, property: "name")
        let descriptionKey = palaceKey(for: palace.id, property: "description")
        let colorKey = palaceKey(for: palace.id, property: "color")
        
        UserDefaults.standard.removeObject(forKey: nameKey)
        UserDefaults.standard.removeObject(forKey: descriptionKey)
        UserDefaults.standard.removeObject(forKey: colorKey)
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