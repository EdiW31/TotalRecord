import SwiftUI

struct PalacesRoomsView: View {
    let palace: Palace
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.08), Color.blue.opacity(0.06), Color.pink.opacity(0.06)]), startPoint: .topLeading, endPoint: .bottomTrailing)
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
                    
                    // Room count
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
                
                // Rooms List
                if palace.rooms.isEmpty {
                    // Empty State
                    VStack(spacing: 16) {
                        Image(systemName: "door.left.hand.closed")
                            .font(.system(size: 64))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("No rooms in this palace")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text("This palace doesn't have any rooms yet. You can add rooms from the main creation page.")
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
                    // Rooms Grid
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ], spacing: 16) {
                            ForEach(palace.rooms) { room in
                                RoomDisplayCard(room: room)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 100)
                    }
                }
                
                Spacer()
            }
            .padding(.top)
        }
        .navigationTitle("Palace Rooms")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RoomDisplayCard: View {
    let room: Room
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "door.left.hand.closed")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(room.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                if !room.description.isEmpty {
                    Text(room.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(height: 120)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.95))
                .shadow(color: .blue.opacity(0.08), radius: 6, x: 0, y: 3)
        )
    }
}