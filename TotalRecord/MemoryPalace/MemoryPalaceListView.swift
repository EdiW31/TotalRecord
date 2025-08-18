import SwiftUI

struct MemoryPalaceListView: View {
    @StateObject private var palaceStorage = PalaceStorage()
    @State private var showCreateSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.13), Color.blue.opacity(0.10), Color.pink.opacity(0.10)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                VStack(spacing: 24) {
                    // Title and Add Button
                    HStack {
                        Text("Memory Palaces")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.purple)
                        Spacer()
                        Button(action: { showCreateSheet = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.blue)
                                .opacity(0.5)
                        }
                    }
                    .padding(.horizontal)
                    
                    // List of Palaces
                    ScrollView {
                        VStack(spacing: 18) {
                            ForEach(Array(palaceStorage.palaces.enumerated()), id: \.element.id) { index, palace in
                                NavigationLink(destination: PalacesRoomsView(palace: $palaceStorage.palaces[index])) {
                                    PalaceCard(palace: palace, palaceStorage: palaceStorage) {
                                        palaceStorage.deletePalace(palace)
                                        palaceStorage.palaces.remove(at: index)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                .onTapGesture {
                                    palaceStorage.setCurrentPalace(palace)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 24)
                    }
                    Spacer()
                }
                .padding(.top, 32)
            }
        }
        .sheet(isPresented: $showCreateSheet) {
            CreateMemoryItemView(onCreatePalace: { newPalace in
                palaceStorage.palaces.append(newPalace)
                palaceStorage.savePalace(newPalace)
                showCreateSheet = false
            })
        }
        .onAppear {
            palaceStorage.loadPalaces()
            palaceStorage.loadCurrentPalace()
        }
    }
}

struct PalaceCard: View {
    let palace: Palace
    let palaceStorage: PalaceStorage
    var onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                // Editable palace name with AppStorage binding
                TextField("Palace Name", text: palaceStorage.palaceNameBinding(for: palace))
                    .font(.title2).fontWeight(.bold)
                    .foregroundColor(.primary)
                    .textFieldStyle(PlainTextFieldStyle())
                
                Spacer()
                
                Image(systemName: "building.columns")
                    .foregroundColor(palaceStorage.getPalaceColor(palace))
                
                // Delete button
                Button(action: {
                    onDelete()
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
            }

            if !palace.description.isEmpty {
                Text(palace.description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            // Room count indicator
            HStack {
                Image(systemName: "door.left.hand.closed")
                    .foregroundColor(.blue)
                    .font(.caption)
                Text("\(palace.rooms.count) room\(palace.rooms.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            // Color indicator
            HStack {
                Text("Color:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Circle()
                    .fill(palaceStorage.getPalaceColor(palace))
                    .frame(width: 20, height: 20)
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.95))
                .shadow(color: palaceStorage.getPalaceColor(palace).opacity(0.10), radius: 6, x: 0, y: 4)
        )
    }
}

// MARK: - PalacesRoomsView
struct PalacesRoomsView: View {
    @Binding var palace: Palace
    @StateObject private var palaceStorage = PalaceStorage()
    @State private var showRoomSheet = false
    @State private var newRoom = Room(name: "")

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.08), Color.blue.opacity(0.06), Color.pink.opacity(0.06)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                // Palace Info Header
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "building.columns.fill")
                            .font(.title)
                            .foregroundColor(.purple)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(palace.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)

                            if !palace.description.isEmpty {
                                Text(palace.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                        }

                        Spacer()
                    }

                    HStack {
                        Image(systemName: "door.left.hand.closed")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text("\(palace.rooms.count) room\(palace.rooms.count == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.9))
                        .shadow(color: .purple.opacity(0.1), radius: 6, x: 0, y: 4)
                )
                .padding(.horizontal)

                // Add Room Button
                Button(action: {
                    newRoom = Room(name: "")
                    showRoomSheet = true
                }) {
                    Label("Add Room", systemImage: "plus")
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple.opacity(0.15))
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                // Room Grid or Empty State
                if palace.rooms.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "door.left.hand.closed")
                            .font(.system(size: 64))
                            .foregroundColor(.gray.opacity(0.5))

                        Text("No rooms in this palace")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)

                        Text("This palace doesn't have any rooms yet. You can add rooms using the button above.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(40)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.7))
                            .shadow(color: .gray.opacity(0.1), radius: 8, x: 0, y: 4)
                    )
                    .padding(.horizontal)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(palace.rooms) { room in
                                RoomDisplayCard(room: room) {
                                    if let index = palace.rooms.firstIndex(where: { $0.id == room.id }) {
                                        palace.rooms.remove(at: index)
                                        palaceStorage.saveRooms(for: palace)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .navigationTitle("Palace Rooms")
        .sheet(isPresented: $showRoomSheet) {
            RoomFormView(room: $newRoom) {
                palace.rooms.append(newRoom)
                palaceStorage.saveRooms(for: palace)
                showRoomSheet = false
            }
        }
    }
}

// MARK: - RoomDisplayCard
struct RoomDisplayCard: View {
    let room: Room
    var onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "door.left.hand.closed")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Text(room.name)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            if !room.description.isEmpty {
                Text(room.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.9))
                .shadow(color: .blue.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}
