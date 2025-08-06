import SwiftUI
import Foundation

// MARK: - Data Models
struct Palace: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var color: String  // Store color as String for AppStorage compatibility
    var rooms: [Room]

    init(id: UUID = UUID(), name: String, description: String = "", color: String = "purple", rooms: [Room] = []) {
        self.id = id
        self.name = name
        self.description = description
        self.color = color
        self.rooms = rooms
    }
}

struct Room: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var assignedCard: String?

    init(id: UUID = UUID(), name: String, description: String = "") {
        self.id = id
        self.name = name
        self.description = description
    }
}

// MARK: - Palace Storage Manager
class PalaceStorage: ObservableObject {
    @Published var palaces: [Palace] = []
    
    // AppStorage keys for each palace
    private func palaceKey(for id: UUID, property: String) -> String {
        return "palace_\(id.uuidString)_\(property)"
    }
    
    // Load palaces from AppStorage
    func loadPalaces() {
        // For now, load default palaces if none exist
        if palaces.isEmpty {
            palaces = [
                Palace(name: "The Grand Library", description: "A vast library with endless shelves, perfect for storing facts and stories.", color: "purple"),
                Palace(name: "Sunny Beach House", description: "A bright, airy house by the sea, ideal for visualizing lists and sequences.", color: "blue"),
                Palace(name: "Mountain Retreat", description: "A peaceful mountain cabin, great for memorizing complex concepts.", color: "green"),
                Palace(name: "City Art Gallery", description: "A modern gallery with colorful rooms for creative memory journeys.", color: "pink")
            ]
        }
    }
    
    // Save palace to AppStorage
    func savePalace(_ palace: Palace) {
        let nameKey = palaceKey(for: palace.id, property: "name")
        let descriptionKey = palaceKey(for: palace.id, property: "description")
        let colorKey = palaceKey(for: palace.id, property: "color")
        
        UserDefaults.standard.set(palace.name, forKey: nameKey)
        UserDefaults.standard.set(palace.description, forKey: descriptionKey)
        UserDefaults.standard.set(palace.color, forKey: colorKey)
    }
    
    // Delete palace from AppStorage
    func deletePalace(_ palace: Palace) {
        let nameKey = palaceKey(for: palace.id, property: "name")
        let descriptionKey = palaceKey(for: palace.id, property: "description")
        let colorKey = palaceKey(for: palace.id, property: "color")
        
        UserDefaults.standard.removeObject(forKey: nameKey)
        UserDefaults.standard.removeObject(forKey: descriptionKey)
        UserDefaults.standard.removeObject(forKey: colorKey)
    }
    
    // Get binding for palace name
    func palaceNameBinding(for palace: Palace) -> Binding<String> {
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
    func palaceColorBinding(for palace: Palace) -> Binding<String> {
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
}

// MARK: - Form Views
// Form to create or edit a Palace
struct PalaceFormView: View {
    @Binding var palace: Palace
    var onSave: (() -> Void)?
    
    let availableColors = ["purple", "blue", "green", "pink", "orange", "red", "yellow", "indigo"]
    
    var body: some View {
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
struct RoomFormView: View {
    @Binding var room: Room
    var onSave: (() -> Void)?
    var body: some View {
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
struct CreateMemoryItemView: View {
    @State private var selection: String? = nil
    @State private var palace = Palace(name: "")
    @State private var room = Room(name: "")
    var onCreatePalace: ((Palace) -> Void)?
    var onCreateRoom: ((Room) -> Void)?
    var body: some View {
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
