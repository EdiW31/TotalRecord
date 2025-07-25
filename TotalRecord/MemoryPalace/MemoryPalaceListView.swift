import SwiftUI
// Use the Palace model and CreateMemoryItemView from Models/PalaceModels.swift
// (No explicit import needed if files are in the same target)

struct MemoryPalaceListView: View {
    // random mai mult pentru test sa vad ca merge, no database :/
    @State private var palaces: [Palace] = [
        Palace(name: "The Grand Library", description: "A vast library with endless shelves, perfect for storing facts and stories."),
        Palace(name: "Sunny Beach House", description: "A bright, airy house by the sea, ideal for visualizing lists and sequences."),
        Palace(name: "Mountain Retreat", description: "A peaceful mountain cabin, great for memorizing complex concepts."),
        Palace(name: "City Art Gallery", description: "A modern gallery with colorful rooms for creative memory journeys.")
    ]
    @State private var showCreateSheet = false

// Removed the unused and empty addPalace() function.

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
                            ForEach(Array(palaces.enumerated()), id: \.element.id) { index, palace in
                                NavigationLink(destination: PalacesRoomsView(palace: $palaces[index])) {
                                    PalaceCard(palace: palace) {
                                        // ma folosesc direct de remove la lista ca sa mearga asta, se apeleaza cand se apeleaza onDelete din Palace Card
                                        palaces.remove(at: index) // O(1) delete
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
                palaces.append(newPalace)
                showCreateSheet = false
            })
        }
    }
}

struct PalaceCard: View {
    let palace: Palace
    var onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(palace.name)
                    .font(.title2).fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "building.columns")
                    .foregroundColor(.purple)
                
                //buton de delete a palatului
                Button(action:{
                    onDelete()
                }){
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
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.95))
                .shadow(color: .purple.opacity(0.10), radius: 6, x: 0, y: 4)
        )
    }
}
