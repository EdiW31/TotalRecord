import SwiftUI


// MARK: - Simple Palace Model for Creation Flow
struct CreationPalace {
    let id = UUID()
    var name: String
    var description: String
    var color: String
    
    init(name: String, description: String, color: String) {
        self.name = name
        self.description = description
        self.color = color
    }
}

// MARK: - Color Helper
extension Color {
    static func fromString(_ colorName: String) -> Color {
        switch colorName.lowercased() {
        case "purple": return .purple
        case "blue": return .blue
        case "green": return .green
        case "pink": return .pink
        case "orange": return .orange
        case "red": return .red
        case "yellow": return .yellow
        case "indigo": return .indigo
        default: return .purple
        }
    }
}

// MARK: - Palace Creation Flow View
struct PalaceCreationFlowView: View {
    @Binding var hasCompletedFirstTimeSetup: Bool
    @State private var currentPalaceIndex = 0
    @State private var showPalaceForm = false
    @State private var selectedColor: Color = .pink
    
    // 5 palace templates for first-time setup
    let palaceTemplates: [CreationPalace] = [
        CreationPalace(name: "My Study Room", description: "A quiet space for learning and memorizing facts.", color: "blue"),
        CreationPalace(name: "Kitchen Memories", description: "Use familiar kitchen items to remember daily tasks.", color: "orange"),
        CreationPalace(name: "Garden Path", description: "A peaceful garden to store nature-related memories.", color: "green"),
        CreationPalace(name: "City Streets", description: "Navigate through familiar streets to find information.", color: "purple"),
        CreationPalace(name: "Beach House", description: "A relaxing beach setting for creative memory storage.", color: "pink")
    ]
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(gradient: Gradient(colors: [Color.pink.opacity(0.13), Color.purple.opacity(0.10), Color.blue.opacity(0.10)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            // Main Content
            VStack(spacing: 30) {
                // Progress indicator
                VStack(spacing: 16) {
                    Text("Create Your Memory Palaces")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.pink)
                    
                    Text("Palace \(currentPalaceIndex + 1) of \(palaceTemplates.count)")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    // Progress bar
                    HStack(spacing: 8) {
                        ForEach(0..<palaceTemplates.count, id: \.self) { index in
                            Rectangle()
                                .fill(index <= currentPalaceIndex ? Color.pink : Color.gray.opacity(0.3))
                                .frame(height: 4)
                                .cornerRadius(2)
                        }
                    }
                    .padding(.horizontal, 40)
                }
                
                // Current palace preview
                VStack(spacing: 20) {
                    Image(systemName: "building.columns")
                        .font(.system(size: 80, weight: .thin))
                        .foregroundColor(Color.fromString(palaceTemplates[currentPalaceIndex].color))
                    
                    VStack(spacing: 12) {
                        Text(palaceTemplates[currentPalaceIndex].name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(palaceTemplates[currentPalaceIndex].description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 16) {
                    HStack(spacing: 20) {
                        Button("Skip") {
                            // Skip to next palace
                            currentPalaceIndex = min(currentPalaceIndex + 1, palaceTemplates.count - 1)
                        }
                        .foregroundColor(.secondary)
                        
                        Button("Customize") {
                            showPalaceForm = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.pink)
                        
                        if currentPalaceIndex == palaceTemplates.count - 1 {
                            // Final palace - Complete setup
                            Button("Complete Setup") {
                                // Mark setup as complete
                                hasCompletedFirstTimeSetup = true
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                        } else {
                            Button("Next") {
                                // Move to next palace
                                currentPalaceIndex = min(currentPalaceIndex + 1, palaceTemplates.count - 1)
                            }
                            .buttonStyle(.bordered)
                            .tint(.pink)
                        }
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
            .padding(.top, 100) // Add top padding to avoid dynamic island
            .padding(.horizontal, 20)
        }
        .sheet(isPresented: $showPalaceForm) {
            PalaceCustomizationView(
                palace: palaceTemplates[currentPalaceIndex],
                onSave: { customizedPalace in
                    currentPalaceIndex = min(currentPalaceIndex + 1, palaceTemplates.count - 1)
                    showPalaceForm = false
                },
                onColorSelected: { color in
                    selectedColor = color
                }
            )
        }
    }
}

// MARK: - Palace Customization View
struct PalaceCustomizationView: View {
    @State private var palace: CreationPalace
    let onSave: (CreationPalace) -> Void
    let onColorSelected: (Color) -> Void
    
    let availableColors = ["purple", "blue", "green", "pink", "orange", "red", "yellow", "indigo"]
    
    init(palace: CreationPalace, onSave: @escaping (CreationPalace) -> Void, onColorSelected: @escaping (Color) -> Void) {
        self._palace = State(initialValue: palace)
        self.onSave = onSave
        self.onColorSelected = onColorSelected
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Customize Your Palace")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.pink)
                
                VStack(spacing: 20) {
                    // Palace name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Palace Name")
                            .font(.headline)
                            .foregroundColor(.primary)
                        TextField("Enter palace name", text: $palace.name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Palace description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                            .foregroundColor(.primary)
                        TextField("Enter description", text: $palace.description, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                    }
                    
                    // Color selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Choose Color")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                            ForEach(availableColors, id: \.self) { colorName in
                                Button(action: {
                                    palace.color = colorName
                                    let color = Color.fromString(colorName)
                                    onColorSelected(color)
                                }) {
                                    Circle()
                                        .fill(Color.fromString(colorName))
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.primary, lineWidth: palace.color == colorName ? 3 : 0)
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Save button
                Button("Save Palace") {
                    onSave(palace)
                }
                .buttonStyle(.borderedProminent)
                .tint(.pink)
                .disabled(palace.name.isEmpty)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .navigationTitle("Customize Palace")
        }
    }
}

// MARK: - Preview
#Preview {
    PalaceCreationFlowView(hasCompletedFirstTimeSetup: .constant(false))
}
