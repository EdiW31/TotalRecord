import SwiftUI

struct TrophyRoomListView: View {
    @StateObject private var trophyRoomStorage = TrophyRoomStorage()
    @State private var showCreateSheet = false
    @State private var showCongratulations = false
    @State private var newlyUnlockedTrophyRoom: TrophyRoom?
    @State private var unlockAnimation = false
    @State private var refreshTrigger = false
    @State private var currentThemeColor: Color = .purple
    
    // Haptic feedback
    private func triggerHapticFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    // Background gradient colors, changes based on theme and themeColor
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
                        Text("Trophy Room")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(currentThemeColor)
                        Spacer()
                        
                        // Clear all data button
                        Button(action: { 
                            trophyRoomStorage.clearAllDataKeepSetup()
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
                    
                    // Trophy Score Card
                    TrophyScoreCard(score: trophyRoomStorage.trophyScore)
                        .padding(.horizontal)
                    
                    // List of Trophy Rooms
                    ScrollView {
                        VStack(spacing: 18) {
                            ForEach(Array(trophyRoomStorage.trophyRooms.enumerated()), id: \.element.id) { index, trophyRoom in
                                let _ = refreshTrigger // Force refresh when unlock status changes
                                if trophyRoom.isUnlocked {
                                    NavigationLink(destination: TrophyRoomAchievementsView(trophyRoom: $trophyRoomStorage.trophyRooms[index])) {
                                        TrophyRoomCard(trophyRoom: trophyRoom, trophyRoomStorage: trophyRoomStorage) {
                                            trophyRoomStorage.deleteTrophyRoom(trophyRoom)
                                            trophyRoomStorage.trophyRooms.remove(at: index)
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .onTapGesture {
                                        // Disabled to prevent random theme changes
                                    }
                                } else {
                                    TrophyRoomCard(trophyRoom: trophyRoom, trophyRoomStorage: trophyRoomStorage) {
                                        // No delete action for locked trophy rooms
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
                if showCongratulations, let trophyRoom = newlyUnlockedTrophyRoom {
                    CongratulationsView(trophyRoom: trophyRoom) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showCongratulations = false
                            newlyUnlockedTrophyRoom = nil
                        }
                        // UI Refresh
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            trophyRoomStorage.objectWillChange.send()
                            refreshTrigger.toggle()
                        }
                    }
                }
            }
        )
        .sheet(isPresented: $showCreateSheet) {
            CreateMemoryItemView(onCreateTrophyRoom: { newTrophyRoom in
                trophyRoomStorage.addTrophyRoom(newTrophyRoom)
                showCreateSheet = false
            })
        }
        .onChange(of: trophyRoomStorage.currentTrophyRoom) { newTrophyRoom in
            if let trophyRoom = newTrophyRoom {
                let newColor = trophyRoomStorage.getTrophyRoomColor(trophyRoom)
                currentThemeColor = newColor
            }
        }
        .onAppear {
            trophyRoomStorage.loadTrophyRooms()
            trophyRoomStorage.loadCurrentTrophyRoom()
            
            // Ensure first trophy room is always unlocked by default
            if let firstTrophyRoom = trophyRoomStorage.trophyRooms.first {
                if !firstTrophyRoom.isUnlocked {
                    trophyRoomStorage.trophyRooms[0].isUnlocked = true
                    trophyRoomStorage.saveTrophyRoomUnlockStatus(trophyRoomStorage.trophyRooms[0])
                }
            }
            
            // Set theme color based on current trophy room (not always first trophy room)
            currentThemeColor = trophyRoomStorage.getCurrentTrophyRoomColor()
            
            // Listen for trophy room unlock notifications
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("TrophyRoomUnlocked"),
                object: nil,
                queue: .main
            ) { notification in
                if let unlockedTrophyRoom = notification.object as? TrophyRoom {
                    // Small delay to let the UI update first
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        triggerHapticFeedback()
                        newlyUnlockedTrophyRoom = unlockedTrophyRoom
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showCongratulations = true
                        }
                    }
                    
                    // Force UI refresh to show unlock button changes
                    DispatchQueue.main.async {
                        trophyRoomStorage.objectWillChange.send()
                        // Also refresh the view to show unlock button changes
                        refreshTrigger.toggle()
                    }
                }
            }
            
            // Listen for trophy room completion notifications
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("TrophyRoomCompleted"),
                object: nil,
                queue: .main
            ) { notification in
                if let completedTrophyRoom = notification.object as? TrophyRoom {
                    triggerHapticFeedback()
                    newlyUnlockedTrophyRoom = completedTrophyRoom
                    
                    // NO AUTO-UNLOCK: User must manually unlock next trophy room
                    // This ensures consistent behavior and user control
                    
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showCongratulations = true
                    }
                    
                    // Force UI refresh to show unlock button changes for next trophy room
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        
                        // Force multiple refresh mechanisms to ensure UI updates
                        trophyRoomStorage.objectWillChange.send()
                        refreshTrigger.toggle()
                        
                        // Also force a trophy room storage refresh
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            trophyRoomStorage.objectWillChange.send()
                            refreshTrigger.toggle()
                        }
                    }
                }
            }
        }
    }
}

struct TrophyRoomCard: View {
    let trophyRoom: TrophyRoom
    let trophyRoomStorage: TrophyRoomStorage
    var onDelete: () -> Void
    @State private var cardScale: CGFloat = 1.0
    @State private var cardOpacity: Double = 1.0

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                // Trophy room name (only editable if unlocked)
                if trophyRoom.isUnlocked {
                    TextField("Trophy Room Name", text: trophyRoomStorage.trophyRoomNameBinding(for: trophyRoom))
                        .font(.title2).fontWeight(.bold)
                        .foregroundColor(.primary)
                        .textFieldStyle(PlainTextFieldStyle())
                } else {
                    Text(trophyRoom.name)
                        .font(.title2).fontWeight(.bold)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Lock/Unlock icon
                Image(systemName: trophyRoom.isUnlocked ? "trophy.fill" : "lock.fill")
                    .foregroundColor(trophyRoom.isUnlocked ? trophyRoomStorage.getTrophyRoomColor(trophyRoom) : .gray)
                
                // Delete button (only for unlocked trophy rooms)
                if trophyRoom.isUnlocked {
                    Button(action: { onDelete() }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }

            if !trophyRoom.description.isEmpty {
                Text(trophyRoom.description)
                    .font(.body)
                    .foregroundColor(trophyRoom.isUnlocked ? .secondary : .secondary.opacity(0.6))
            }
            
            // Content for locked vs unlocked trophy rooms
            if !trophyRoom.isUnlocked {
                    // Unlock button for locked trophy rooms
                    VStack(spacing: 8) {
                        Text(trophyRoomStorage.getUnlockCondition(for: trophyRoom))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        // Debug info
                        Text("Can unlock: \(trophyRoomStorage.canUnlockTrophyRoom(trophyRoom) ? "Yes" : "No")")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            trophyRoomStorage.unlockTrophyRoom(trophyRoom)
                        }) {
                            Text("Unlock Trophy Room")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    trophyRoomStorage.canUnlockTrophyRoom(trophyRoom) ? Color.blue : Color.gray
                                )
                                .cornerRadius(8)
                        }
                        .disabled(!trophyRoomStorage.canUnlockTrophyRoom(trophyRoom))
                        .onChange(of: trophyRoomStorage.trophyRooms) { _ in
                            // Force this card to refresh when trophy rooms change
                        }
                    }
                    .padding(.top, 8)
            } else {
                // Achievement count for unlocked trophy rooms
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text("\(trophyRoom.achievements.count) achievement\(trophyRoom.achievements.count == 1 ? "" : "s")")
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
                        .fill(trophyRoomStorage.getTrophyRoomColor(trophyRoom))
                        .frame(width: 20, height: 20)
                    Spacer()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(trophyRoom.isUnlocked ? Color.white.opacity(0.95) : Color.gray.opacity(0.1))
                .shadow(color: trophyRoom.isUnlocked ? trophyRoomStorage.getTrophyRoomColor(trophyRoom).opacity(0.10) : .clear, radius: 6, x: 0, y: 4)
        )
        .overlay(
            // Lock overlay for locked trophy rooms
            RoundedRectangle(cornerRadius: 16)
                .stroke(trophyRoom.isUnlocked ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
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
        .onChange(of: trophyRoom.isUnlocked) { isUnlocked in
            if isUnlocked {
                // Celebration animation when trophy room unlocks
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

struct TrophyRoomAchievementsView: View {
    @Binding var trophyRoom: TrophyRoom
    @StateObject private var trophyRoomStorage = TrophyRoomStorage()
    @State private var showAchievementSheet = false
    @State private var newAchievement = Achievement(name: "", type: .completion)

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.08), Color.blue.opacity(0.06), Color.pink.opacity(0.06)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                // Trophy Room Info Header
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .font(.title)
                            .foregroundColor(.yellow)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(trophyRoom.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)

                            if !trophyRoom.description.isEmpty {
                                Text(trophyRoom.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                        }

                        Spacer()
                    }

                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text("\(trophyRoom.achievements.count) achievement\(trophyRoom.achievements.count == 1 ? "" : "s")")
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

                // Add Achievement Button and Complete Trophy Room Button
                HStack(spacing: 12) {
                    Button(action: {
                        newAchievement = Achievement(name: "", type: .completion)
                        showAchievementSheet = true
                    }) {
                        Label("Add Achievement", systemImage: "plus")
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.purple.opacity(0.15))
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        trophyRoomStorage.markTrophyRoomCompleted(trophyRoom)
                        
                        
                        // Post notification to trigger congratulations
                        NotificationCenter.default.post(
                            name: NSNotification.Name("TrophyRoomCompleted"),
                            object: trophyRoom
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

                // Achievement Grid or Empty State
                if trophyRoom.achievements.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.gray.opacity(0.5))

                        Text("No achievements in this trophy room")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)

                        Text("This trophy room doesn't have any achievements yet. You can add achievements using the button above.")
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
                            ForEach(trophyRoom.achievements) { achievement in
                                AchievementDisplayCard(achievement: achievement) {
                                    if let index = trophyRoom.achievements.firstIndex(where: { $0.id == achievement.id }) {
                                        trophyRoom.achievements.remove(at: index)
                                        trophyRoomStorage.saveAchievements(for: trophyRoom)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .navigationTitle("Trophy Room Achievements")
        .sheet(isPresented: $showAchievementSheet) {
            AchievementFormView(achievement: $newAchievement) {
                trophyRoom.achievements.append(newAchievement)
                trophyRoomStorage.saveAchievements(for: trophyRoom)
                showAchievementSheet = false
            }
        }
    }
}

struct AchievementDisplayCard: View {
    let achievement: Achievement
    var onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.title2)
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Text(achievement.name)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            if !achievement.description.isEmpty {
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            // Progress indicator
            if achievement.type == .speed || achievement.type == .accuracy {
                ProgressView(value: achievement.currentValue, total: achievement.targetValue)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
            }
            
            // Completion status
            if achievement.isCompleted {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Completed")
                        .font(.caption)
                        .foregroundColor(.green)
                }
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

struct CongratulationsView: View {
    let trophyRoom: TrophyRoom
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
                
                // Trophy room name
                Text("You've unlocked")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                Text(trophyRoom.name)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.center)
                
                // Description
                if !trophyRoom.description.isEmpty {
                    Text(trophyRoom.description)
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

struct TrophyScoreCard: View {
    let score: TrophyScore
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "trophy.fill")
                    .font(.title)
                    .foregroundColor(.yellow)
                
                VStack(alignment: .leading) {
                    Text("Trophy Score")
                        .font(.headline)
                    Text("\(score.totalScore)")
                        .font(.title)
                        .fontWeight(.bold)
                }
                Spacer()
            }
            
            // Progress indicators
            HStack {
                Label("\(score.unlockedRooms)/5 Rooms", systemImage: "trophy.fill")
                Spacer()
                Label("\(score.completedAchievements)/25 Achievements", systemImage: "checkmark.circle.fill")
            }
            .font(.caption)
            
            // Progress bar
            ProgressView(value: score.overallProgress)
                .progressViewStyle(LinearProgressViewStyle(tint: .yellow))
        }
        .padding()
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    TrophyRoomListView()
}
