import SwiftUI
// Use the Palace model and CreateMemoryItemView from Models/PalaceModels.swift
// (No explicit import needed if files are in the same target)

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
                    .foregroundColor(Color(palace.color))
                
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
            
            // Color indicator
            HStack {
                Text("Color:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Circle()
                    .fill(Color(palace.color))
                    .frame(width: 20, height: 20)
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.95))
                .shadow(color: Color(palace.color).opacity(0.10), radius: 6, x: 0, y: 4)
        )
    }
}
