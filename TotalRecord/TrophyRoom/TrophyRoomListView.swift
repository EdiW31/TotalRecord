import SwiftUI

struct TrophyRoomListView: View {
    @ObservedObject private var trophyRoomStorage = TrophyRoomStorage.shared
    @State private var showCreateSheet = false
    @State private var showCongratulations = false
    @State private var newlyUnlockedTrophyRoom: TrophyRoom?
    @State private var unlockAnimation = false
    @State private var refreshTrigger = false
    @State private var currentThemeColor: Color = .purple
    
    private func triggerHapticFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
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
                        
                        // For later implementation (poate cand termina cu all the rooms, then sa poti creaa new ones si sa add custom achievements)

                        // Button(action: { showCreateSheet = true }) {
                        //     Image(systemName: "plus.circle.fill")
                        //         .font(.system(size: 32))
                        //         .foregroundColor(.blue)
                        //         .opacity(0.5)
                        // }
                    }
                    .padding(.horizontal)
                    
                    TrophyScoreCard(score: trophyRoomStorage.trophyScore)
                        .padding(.horizontal)
                    
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
                                    }
                                } else {
                                    TrophyRoomCard(trophyRoom: trophyRoom, trophyRoomStorage: trophyRoomStorage) {
                                    }
                                    .onTapGesture {
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
            
            if let firstTrophyRoom = trophyRoomStorage.trophyRooms.first {
                if !firstTrophyRoom.isUnlocked {
                    trophyRoomStorage.trophyRooms[0].isUnlocked = true
                    trophyRoomStorage.saveTrophyRoomUnlockStatus(trophyRoomStorage.trophyRooms[0])
                }
            }
            
            currentThemeColor = trophyRoomStorage.getCurrentTrophyRoomColor()
            
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("TrophyRoomUnlocked"),
                object: nil,
                queue: .main
            ) { notification in
                if let unlockedTrophyRoom = notification.object as? TrophyRoom {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        triggerHapticFeedback()
                        newlyUnlockedTrophyRoom = unlockedTrophyRoom
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showCongratulations = true
                        }
                    }
                    
                    DispatchQueue.main.async {
                        trophyRoomStorage.objectWillChange.send()
                        refreshTrigger.toggle()
                    }
                }
            }
            
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("TrophyRoomCompleted"),
                object: nil,
                queue: .main
            ) { notification in
                if let completedTrophyRoom = notification.object as? TrophyRoom {
                    triggerHapticFeedback()
                    newlyUnlockedTrophyRoom = completedTrophyRoom
                    
                    
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showCongratulations = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        
                        trophyRoomStorage.objectWillChange.send()
                        refreshTrigger.toggle()
                        
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
            }

            if !trophyRoom.description.isEmpty {
                Text(trophyRoom.description)
                    .font(.body)
                    .foregroundColor(trophyRoom.isUnlocked ? .secondary : .secondary.opacity(0.6))
            }
            
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
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text("\(trophyRoom.achievements.count) achievement\(trophyRoom.achievements.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
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
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                    cardScale = 1.05
                }
                
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
    @ObservedObject private var trophyRoomStorage = TrophyRoomStorage.shared
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

                Button(action: {
                    trophyRoomStorage.markTrophyRoomCompleted(trophyRoom)
                    
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
                // .disabled(!allAchievementsCompleted)
                

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
                        LazyVStack(spacing: 20) {
                            // Memory Match Section
                            if !memoryMatchAchievements.isEmpty {
                                AchievementSection(
                                    title: "Memory Match",
                                    achievements: memoryMatchAchievements,
                                    onDeleteAchievement: deleteAchievement
                                )
                            }
                            
                            // Speed Match Section
                            if !speedMatchAchievements.isEmpty {
                                AchievementSection(
                                    title: "Speed Match",
                                    achievements: speedMatchAchievements,
                                    onDeleteAchievement: deleteAchievement
                                )
                            }
                            
                            // Sequence Recall Section
                            if !sequenceRecallAchievements.isEmpty {
                                AchievementSection(
                                    title: "Sequence Recall",
                                    achievements: sequenceRecallAchievements,
                                    onDeleteAchievement: deleteAchievement
                                )
                            }
                            
                            // Card Locator Section
                            if !cardLocatorAchievements.isEmpty {
                                AchievementSection(
                                    title: "Card Locator",
                                    achievements: cardLocatorAchievements,
                                    onDeleteAchievement: deleteAchievement
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .navigationTitle("Trophy Room Achievements")
        .onAppear {
            trophyRoomStorage.updateAchievementsFromScoreStorage()
        }
        .sheet(isPresented: $showAchievementSheet) {
            AchievementFormView(achievement: $newAchievement) {
                trophyRoom.achievements.append(newAchievement)
                trophyRoomStorage.saveAchievements(for: trophyRoom)
                showAchievementSheet = false
            }
        }
    }

    // var care verifica daca toate achievementurile sunt completate
    private var allAchievementsCompleted: Bool {
        return !trophyRoom.achievements.isEmpty && trophyRoom.achievements.allSatisfy { $0.isCompleted }
    }
    
    private var memoryMatchAchievements: [Achievement] {
        trophyRoom.achievements.filter { $0.gameType == .memoryMatch }
    }
    
    private var speedMatchAchievements: [Achievement] {
        trophyRoom.achievements.filter { $0.gameType == .speedMatch }
    }
    
    private var sequenceRecallAchievements: [Achievement] {
        trophyRoom.achievements.filter { $0.gameType == .sequenceRecall }
    }
    
    private var cardLocatorAchievements: [Achievement] {
        trophyRoom.achievements.filter { $0.gameType == .cardLocator }
    }
    
    private func deleteAchievement(_ achievement: Achievement) {
        if let index = trophyRoom.achievements.firstIndex(where: { $0.id == achievement.id }) {
            trophyRoom.achievements.remove(at: index)
            trophyRoomStorage.saveAchievements(for: trophyRoom)
        }
    }
    
}

struct AchievementSection: View {
    let title: String
    let achievements: [Achievement]
    let onDeleteAchievement: (Achievement) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(achievements.filter { $0.isCompleted }.count)/\(achievements.count)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(achievements) { achievement in
                    AchievementDisplayCard(achievement: achievement) {
                        onDeleteAchievement(achievement)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.9))
                .shadow(color: .purple.opacity(0.1), radius: 6, x: 0, y: 4)
        )
    }
}

struct AchievementDisplayCard: View {
    let achievement: Achievement
    var onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: achievementBadgeIcon)
                    .foregroundColor(achievement.isCompleted ? .green : .yellow)
                    .font(.title2)
                
                Spacer()
                
                // Button(action: onDelete) {
                //     Image(systemName: "trash")
                //         .foregroundColor(.red)
                //         .font(.caption)
                // }
                // .buttonStyle(PlainButtonStyle())
            }
            
            Text(achievement.name)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .lineLimit(2)
            
            if !achievement.description.isEmpty {
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            // Progress visualization based on achievement type
            progressView
            
            // Completion status with date
            if achievement.isCompleted {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Completed")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    if let completedDate = achievement.completedDate {
                        Spacer()
                        Text(formatDate(completedDate))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(achievement.isCompleted ? Color.green.opacity(0.05) : Color.white.opacity(0.9))
                .shadow(color: achievement.isCompleted ? .green.opacity(0.1) : .blue.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
    
    // Computed properties for better organization
    private var achievementBadgeIcon: String {
        switch achievement.type {
        case .completion:
            return "gamecontroller.fill"
        case .speed:
            return "timer"
        case .accuracy:
            return "target"
        case .milestone:
            return "star.fill"
        case .record:
            return "trophy.fill"
        }
    }
    
    @ViewBuilder
    private var progressView: some View {
        switch achievement.type {
        case .completion:
            if achievement.targetValue > 1 {
                HStack {
                    Text("\(Int(achievement.currentValue))/\(Int(achievement.targetValue))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    ProgressView(value: achievement.currentValue, total: achievement.targetValue)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .frame(width: 60)
                }
            }
        case .speed:
            HStack {
                Text("Best: \(formatTime(achievement.currentValue))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Target: \(formatTime(achievement.targetValue))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        case .accuracy:
            HStack {
                Text("\(Int(achievement.currentValue))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                ProgressView(value: achievement.currentValue, total: achievement.targetValue)
                    .progressViewStyle(LinearProgressViewStyle(tint: achievement.currentValue >= achievement.targetValue ? .green : .blue))
                    .frame(width: 60)
            }
        case .milestone:
            if achievement.targetValue > 1 {
                HStack {
                    Text("\(Int(achievement.currentValue))/\(Int(achievement.targetValue))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    ProgressView(value: achievement.currentValue, total: achievement.targetValue)
                        .progressViewStyle(LinearProgressViewStyle(tint: .purple))
                        .frame(width: 60)
                }
            }
        case .record:
            Text("Personal Record")
                .font(.caption)
                .foregroundColor(.orange)
                .fontWeight(.medium)
        }
    }
    
    private func formatTime(_ time: Double) -> String {
        if time < 60 {
            return String(format: "%.1fs", time)
        } else {
            let minutes = Int(time) / 60
            let seconds = Int(time) % 60
            return "\(minutes)m \(seconds)s"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
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
