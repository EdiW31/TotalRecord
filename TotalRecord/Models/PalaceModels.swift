import SwiftUI
import Foundation

// MARK: - Data Models
struct Palace: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var rooms: [Room]

    init(id: UUID = UUID(), name: String, description: String = "", rooms: [Room] = []) {
        self.id = id
        self.name = name
        self.description = description
        self.rooms = rooms
    }
}

struct Room: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String

    init(id: UUID = UUID(), name: String, description: String = "") {
        self.id = id
        self.name = name
        self.description = description
    }
}

// MARK: - Form Views
// Form to create or edit a Palace
struct PalaceFormView: View {
    @Binding var palace: Palace
    var onSave: (() -> Void)?
    var body: some View {
        Form {
            Section(header: Text("Palace Details")) {
                TextField("Palace Name", text: $palace.name)
                TextField("Description", text: $palace.description)
            }
            Button("Save Palace") {
                onSave?()
            }
            .disabled(palace.name.isEmpty)
        }
        .navigationTitle(palace.id == UUID() ? "New Palace" : "Edit Palace")
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