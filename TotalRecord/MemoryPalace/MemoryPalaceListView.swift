import SwiftUI

struct MemoryPalaceListView: View {
    @StateObject private var palaceStorage = PalaceStorage()
    @State private var showCreateSheet = false
    @State private var showCongratulations = false
    @State private var newlyUnlockedPalace: Palace?
    @State private var unlockAnimation = false
    @State private var currentThemeColor: Color = .purple
    @State private var refreshTrigger = false
    
    // Haptic feedback
    private func triggerHapticFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    // Background gradient colors
    private var backgroundGradientColors: [Color] {
        [
            currentThemeColor.opacity(0.13),
            currentThemeColor.opacity(0.10),
            Color.pink.opacity(0.10)
        ]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: backgroundGradientColors), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                VStack(spacing: 24) {
                    // Title and Buttons
                    HStack {
                        Text("Memory Palaces")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(currentThemeColor)
                        Spacer()
                        

                        
                        // Clear all data button
                        Button(action: { 
                            palaceStorage.clearAllDataKeepSetup()
                        }) {
                            Image(systemName: "trash.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.red)
                                .opacity(0.7)
                        }
                        
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
                                let _ = refreshTrigger // Force refresh when unlock status changes
                                if palace.isUnlocked {
                                    NavigationLink(destination: PalacesRoomsView(palace: $palaceStorage.palaces[index])) {
                                        PalaceCard(palace: palace, palaceStorage: palaceStorage) {
                                            palaceStorage.deletePalace(palace)
                                            palaceStorage.palaces.remove(at: index)
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .onTapGesture {
                                        // Disabled to prevent random theme changes
                                    }
                                } else {
                                    PalaceCard(palace: palace, palaceStorage: palaceStorage) {
                                        // No delete action for locked palaces
                                    }
                                    .onTapGesture {
                                        // Disabled to prevent random theme changes
                                    }
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
        
        // Congratulations Overlay
        .overlay(
            Group {
                if showCongratulations, let palace = newlyUnlockedPalace {
                    CongratulationsView(palace: palace) {
                        print("Dismissing congrats screen for palace: \(palace.name)")
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showCongratulations = false
                            newlyUnlockedPalace = nil
                        }
                        // Force UI refresh after dismissal
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            palaceStorage.objectWillChange.send()
                            refreshTrigger.toggle()
                        }
                    }
                }
            }
        )
        .sheet(isPresented: $showCreateSheet) {
            CreateMemoryItemView(onCreatePalace: { newPalace in
                palaceStorage.addPalace(newPalace)
                showCreateSheet = false
            })
        }
        .onChange(of: palaceStorage.currentPalace) { newPalace in
            if let palace = newPalace {
                let newColor = palaceStorage.getPalaceColor(palace)
                print("Theme changing from \(currentThemeColor) to \(newColor) for palace: \(palace.name)")
                currentThemeColor = newColor
            }
        }
        .onAppear {
            palaceStorage.loadPalaces()
            palaceStorage.loadCurrentPalace()
            
            // Ensure first palace is always unlocked by default
            if let firstPalace = palaceStorage.palaces.first {
                if !firstPalace.isUnlocked {
                    palaceStorage.palaces[0].isUnlocked = true
                    palaceStorage.savePalaceUnlockStatus(palaceStorage.palaces[0])
                }
            }
            
            // Set theme color based on current palace (not always first palace)
            currentThemeColor = palaceStorage.getCurrentPalaceColor()
            
            // Listen for palace unlock notifications
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("PalaceUnlocked"),
                object: nil,
                queue: .main
            ) { notification in
                if let unlockedPalace = notification.object as? Palace {
                    // Small delay to let the UI update first
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        triggerHapticFeedback()
                        newlyUnlockedPalace = unlockedPalace
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showCongratulations = true
                        }
                    }
                    
                    // Force UI refresh to show unlock button changes
                    DispatchQueue.main.async {
                        palaceStorage.objectWillChange.send()
                        // Also refresh the view to show unlock button changes
                        refreshTrigger.toggle()
                    }
                }
            }
            
            // Listen for palace completion notifications
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("PalaceCompleted"),
                object: nil,
                queue: .main
            ) { notification in
                if let completedPalace = notification.object as? Palace {
                    triggerHapticFeedback()
                    newlyUnlockedPalace = completedPalace
                    
                    // NO AUTO-UNLOCK: User must manually unlock next palace
                    // This ensures consistent behavior and user control
                    
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showCongratulations = true
                    }
                    
                    // Force UI refresh to show unlock button changes for next palace
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        print("Refreshing UI after palace completion for: \(completedPalace.name)")
                        
                        // Force multiple refresh mechanisms to ensure UI updates
                        palaceStorage.objectWillChange.send()
                        refreshTrigger.toggle()
                        
                        // Also force a palace storage refresh
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            print("Secondary UI refresh for unlock button visibility")
                            palaceStorage.objectWillChange.send()
                            refreshTrigger.toggle()
                        }
                    }
                }
            }
        }
    }
}

struct PalaceCard: View {
    let palace: Palace
    let palaceStorage: PalaceStorage
    var onDelete: () -> Void
    @State private var cardScale: CGFloat = 1.0
    @State private var cardOpacity: Double = 1.0

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                // Palace name (only editable if unlocked)
                if palace.isUnlocked {
                    TextField("Palace Name", text: palaceStorage.palaceNameBinding(for: palace))
                        .font(.title2).fontWeight(.bold)
                        .foregroundColor(.primary)
                        .textFieldStyle(PlainTextFieldStyle())
                } else {
                    Text(palace.name)
                        .font(.title2).fontWeight(.bold)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Lock/Unlock icon
                Image(systemName: palace.isUnlocked ? "building.columns" : "lock.fill")
                    .foregroundColor(palace.isUnlocked ? palaceStorage.getPalaceColor(palace) : .gray)
                
                // Delete button (only for unlocked palaces)
                if palace.isUnlocked {
                    Button(action: { onDelete() }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }

            if !palace.description.isEmpty {
                Text(palace.description)
                    .font(.body)
                    .foregroundColor(palace.isUnlocked ? .secondary : .secondary.opacity(0.6))
            }
            
            // Content for locked vs unlocked palaces
            if !palace.isUnlocked {
                                    // Unlock button for locked palaces
                    VStack(spacing: 8) {
                        Text(palaceStorage.getUnlockCondition(for: palace))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        // Debug info
                        Text("Can unlock: \(palaceStorage.canUnlockPalace(palace) ? "Yes" : "No")")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            palaceStorage.unlockPalace(palace)
                        }) {
                            Text("Unlock Palace")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    palaceStorage.canUnlockPalace(palace) ? Color.blue : Color.gray
                                )
                                .cornerRadius(8)
                        }
                        .disabled(!palaceStorage.canUnlockPalace(palace))
                        .onChange(of: palaceStorage.palaces) { _ in
                            // Force this card to refresh when palaces change
                            print("PalaceCard refresh triggered for: \(palace.name)")
                        }
                    }
                    .padding(.top, 8)
            } else {
                // Room count for unlocked palaces
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
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(palace.isUnlocked ? Color.white.opacity(0.95) : Color.gray.opacity(0.1))
                .shadow(color: palace.isUnlocked ? palaceStorage.getPalaceColor(palace).opacity(0.10) : .clear, radius: 6, x: 0, y: 4)
        )
        .overlay(
            // Lock overlay for locked palaces
            RoundedRectangle(cornerRadius: 16)
                .stroke(palace.isUnlocked ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
        )
        .scaleEffect(cardScale)
        .opacity(cardOpacity)
        .onAppear {
            // Animate card appearance
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                cardScale = 1.0
                cardOpacity = 1.0
            }
        }
        .onChange(of: palace.isUnlocked) { isUnlocked in
            if isUnlocked {
                // Celebration animation when palace unlocks
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                    cardScale = 1.05
                }
                
                // Add a subtle glow effect
                withAnimation(.easeInOut(duration: 0.8).repeatCount(3, autoreverses: true)) {
                    cardOpacity = 0.8
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        cardScale = 1.0
                        cardOpacity = 1.0
                    }
                }
            }
        }
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

                // Add Room Button and Complete Palace Button
                HStack(spacing: 12) {
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
                    
                    Button(action: {
                        palaceStorage.markPalaceCompleted(palace)
                        
                        // NO AUTO-UNLOCK: User must manually unlock next palace
                        // This ensures consistent behavior and user control
                        
                        // Post notification to trigger congratulations
                        NotificationCenter.default.post(
                            name: NSNotification.Name("PalaceCompleted"),
                            object: palace
                        )
                    }) {
                        Label("Mark Complete", systemImage: "checkmark.circle")
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.15))
                            .cornerRadius(12)
                    }
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

// MARK: - Congratulations View
struct CongratulationsView: View {
    let palace: Palace
    let onDismiss: () -> Void
    @State private var showConfetti = false
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            // Background blur
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            // Congratulations card
            VStack(spacing: 24) {
                // Trophy icon with animation
                ZStack {
                    Circle()
                        .fill(Color.yellow.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.yellow)
                        .scaleEffect(showConfetti ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: showConfetti)
                }
                
                // Confetti effect (simplified for now)
                if showConfetti {
                    // Simple confetti effect
                    HStack(spacing: 4) {
                        ForEach(0..<10, id: \.self) { _ in
                            Circle()
                                .fill([.red, .blue, .green, .yellow, .purple, .orange].randomElement()!)
                                .frame(width: 6, height: 6)
                                .scaleEffect(showConfetti ? 1.5 : 0.5)
                                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: showConfetti)
                        }
                    }
                }
                
                // Title
                Text("🎉 Congratulations! 🎉")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                // Palace name
                Text("You've unlocked")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                Text(palace.name)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.center)
                
                // Description
                if !palace.description.isEmpty {
                    Text(palace.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Continue button
                Button(action: onDismiss) {
                    Text("Continue Exploring")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                        .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    scale = 1.0
                    opacity = 1.0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showConfetti = true
                }
            }
        }
        .transition(.opacity.combined(with: .scale))
    }
}
