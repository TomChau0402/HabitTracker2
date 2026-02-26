import SwiftUI
import SwiftData

struct HabitFormView: View {
    @EnvironmentObject var viewModel: HabitViewModel
    @Environment(\.dismiss) var dismiss
    
    var existingHabit: Habit?
    
    @State private var selectedType: HabitType = .focusedWork
    @State private var reminderEnabled = false
    @State private var reminderTime = Date()
    @State private var notes = ""
    @State private var showingDeleteAlert = false
    
    // Enhanced color scheme matching HomeView with darker tones
    private let deepBlue = Color(red: 0.2, green: 0.4, blue: 0.9)
    private let teal = Color(red: 0.1, green: 0.7, blue: 0.8)
    private let darkBlue = Color(red: 0.1, green: 0.2, blue: 0.5)
    
    // Computed properties for gradients
    private var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [deepBlue, teal],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var cardGradient: LinearGradient {
        LinearGradient(
            colors: [.white.opacity(0.1), .white.opacity(0.05)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    init(existingHabit: Habit? = nil) {
        self.existingHabit = existingHabit
        _selectedType = State(initialValue: existingHabit?.type ?? .focusedWork)
        _reminderEnabled = State(initialValue: existingHabit?.reminderEnabled ?? false)
        _reminderTime = State(initialValue: existingHabit?.reminderTime ?? Date())
        _notes = State(initialValue: existingHabit?.notes ?? "")
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Dark gradient background matching HomeView
                LinearGradient(
                    colors: [Color.black.opacity(0.8), darkBlue],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header with icon
                        VStack(spacing: 16) {
                            // Animated icon based on selected type with enhanced design
                            ZStack {
                                // Glow effect
                                Circle()
                                    .fill(deepBlue.opacity(0.3))
                                    .frame(width: 120, height: 120)
                                    .blur(radius: 20)
                                
                                // Background circle
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 110, height: 110)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                LinearGradient(
                                                    colors: [.white.opacity(0.3), teal.opacity(0.3)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 2
                                            )
                                    )
                                
                                // Inner gradient circle
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [deepBlue.opacity(0.2), teal.opacity(0.2)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: selectedType.icon)
                                    .font(.system(size: 50))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.white, teal],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .symbolEffect(.bounce, value: selectedType)
                            }
                            .padding(.top, 20)
                            
                            Text(selectedType.rawValue)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, teal],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        }
                        
                        // Form Fields
                        VStack(spacing: 20) {
                            // Habit Type Selection Card
                            VStack(alignment: .leading, spacing: 16) {
                                Label {
                                    Text("Habit Type")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                } icon: {
                                    Image(systemName: "figure.mind.body")
                                        .foregroundColor(teal)
                                }
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(HabitType.allCases) { type in
                                            HabitTypeButton(
                                                type: type,
                                                isSelected: selectedType == type,
                                                action: { selectedType = type },
                                                deepBlue: deepBlue,
                                                teal: teal
                                            )
                                        }
                                    }
                                    .padding(.horizontal, 4)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [.white.opacity(0.2), teal.opacity(0.3)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                            )
                            
                            // Daily Target Card
                            VStack(alignment: .leading, spacing: 16) {
                                Label {
                                    Text("Daily Target")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                } icon: {
                                    Image(systemName: "target")
                                        .foregroundColor(teal)
                                }
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Your goal")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.6))
                                        Text(selectedType.targetDisplayValue)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(teal)
                                    }
                                    
                                    Spacer()
                                    
                                    // Target visualization with enhanced design
                                    ZStack {
                                        Circle()
                                            .stroke(deepBlue.opacity(0.3), lineWidth: 4)
                                            .frame(width: 70, height: 70)
                                        
                                        Circle()
                                            .trim(from: 0, to: 1.0)
                                            .stroke(
                                                primaryGradient,
                                                style: StrokeStyle(lineWidth: 4, lineCap: .round)
                                            )
                                            .frame(width: 70, height: 70)
                                            .rotationEffect(.degrees(-90))
                                            .shadow(color: teal.opacity(0.3), radius: 5, x: 0, y: 2)
                                        
                                        VStack(spacing: 0) {
                                            Text("100")
                                                .font(.headline)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                            Text("%")
                                                .font(.caption2)
                                                .foregroundColor(teal)
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [.white.opacity(0.2), teal.opacity(0.3)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                            )
                            
                            // Reminder Card
                            VStack(alignment: .leading, spacing: 16) {
                                Label {
                                    Text("Reminder")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                } icon: {
                                    Image(systemName: "bell.fill")
                                        .foregroundColor(teal)
                                }
                                
                                Toggle(isOn: $reminderEnabled.animation()) {
                                    Text("Enable daily reminder")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                }
                                .toggleStyle(SwitchToggleStyle(tint: teal))
                                
                                if reminderEnabled {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Reminder Time")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.6))
                                        
                                        HStack {
                                            // Time icon with glow
                                            ZStack {
                                                Circle()
                                                    .fill(deepBlue.opacity(0.2))
                                                    .frame(width: 40, height: 40)
                                                    .blur(radius: 8)
                                                
                                                Circle()
                                                    .fill(.ultraThinMaterial)
                                                    .frame(width: 40, height: 40)
                                                    .overlay(
                                                        Circle()
                                                            .stroke(teal.opacity(0.3), lineWidth: 1)
                                                    )
                                                
                                                Image(systemName: "clock.fill")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(teal)
                                            }
                                            
                                            DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                                                .labelsHidden()
                                                .datePickerStyle(.compact)
                                                .colorScheme(.dark)
                                                .accentColor(teal)
                                            
                                            Spacer()
                                            
                                            // Time display pill
                                            Text(reminderTime, style: .time)
                                                .font(.system(.body, design: .rounded))
                                                .fontWeight(.semibold)
                                                .foregroundColor(teal)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(
                                                    Capsule()
                                                        .fill(.ultraThinMaterial)
                                                        .overlay(
                                                            Capsule()
                                                                .stroke(teal.opacity(0.3), lineWidth: 1)
                                                        )
                                                )
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(.ultraThinMaterial.opacity(0.5))
                                        )
                                    }
                                    .transition(.opacity.combined(with: .slide))
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [.white.opacity(0.2), teal.opacity(0.3)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                            )
                            
                            // Notes Card
                            VStack(alignment: .leading, spacing: 16) {
                                Label {
                                    Text("Notes")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                } icon: {
                                    Image(systemName: "note.text")
                                        .foregroundColor(teal)
                                }
                                
                                TextEditor(text: $notes)
                                    .frame(height: 100)
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.ultraThinMaterial.opacity(0.5))
                                    )
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [deepBlue.opacity(0.5), teal.opacity(0.5)],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                                    .colorScheme(.dark)
                                
                                if notes.isEmpty {
                                    Text("Add any additional notes or motivation...")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.5))
                                        .padding(.leading, 4)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [.white.opacity(0.2), teal.opacity(0.3)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                            )
                            
                            // Delete Button (only for existing habits)
                            if existingHabit != nil {
                                Button(action: { showingDeleteAlert = true }) {
                                    HStack {
                                        Image(systemName: "trash.fill")
                                        Text("Delete Habit")
                                        Spacer()
                                    }
                                    .font(.headline)
                                    .foregroundColor(.red)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(.ultraThinMaterial)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(Color.red.opacity(0.5), lineWidth: 1)
                                            )
                                    )
                                }
                                .padding(.top, 8)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle(existingHabit == nil ? "New Habit" : "Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text(existingHabit == nil ? "New Habit" : "Edit Habit")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, teal],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: saveHabit) {
                        Text("Save")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(primaryGradient)
                                    .overlay(
                                        Capsule()
                                            .stroke(.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            .shadow(color: deepBlue.opacity(0.5), radius: 8, x: 0, y: 4)
                    }
                }
            }
            .alert("Delete Habit", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let habit = existingHabit {
                        viewModel.deleteHabit(habit)
                    }
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this habit? This action cannot be undone.")
            }
        }
    }
    
    private func saveHabit() {
        if let existingHabit = existingHabit {
            // Update existing habit
            existingHabit.type = selectedType
            existingHabit.reminderEnabled = reminderEnabled
            existingHabit.reminderTime = reminderEnabled ? reminderTime : nil
            existingHabit.notes = notes.isEmpty ? nil : notes
            viewModel.updateHabit(existingHabit)
        } else {
            // Create new habit
            viewModel.addHabit(
                type: selectedType,
                reminderTime: reminderEnabled ? reminderTime : nil,
                reminderEnabled: reminderEnabled,
                notes: notes.isEmpty ? nil : notes
            )
        }
        dismiss()
    }
}

// MARK: - Habit Type Button Component
struct HabitTypeButton: View {
    let type: HabitType
    let isSelected: Bool
    let action: () -> Void
    let deepBlue: Color
    let teal: Color
    
    private var selectedGradient: LinearGradient {
        LinearGradient(
            colors: [deepBlue, teal],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    // Glow effect when selected
                    if isSelected {
                        Circle()
                            .fill(deepBlue.opacity(0.3))
                            .frame(width: 70, height: 70)
                            .blur(radius: 10)
                    }
                    
                    Circle()
                        .fill(
                            isSelected ?
                            selectedGradient :
                                LinearGradient(
                                    colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                        )
                        .frame(width: 60, height: 60)
                        .overlay(
                            Circle()
                                .stroke(
                                    isSelected ?
                                        .white.opacity(0.5) :
                                        .white.opacity(0.1),
                                    lineWidth: isSelected ? 2 : 1
                                )
                        )
                        .shadow(color: isSelected ? deepBlue.opacity(0.5) : .clear,
                               radius: 8, x: 0, y: 4)
                    
                    Image(systemName: type.icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? .white : .gray)
                }
                
                Text(type.rawValue)
                    .font(.caption2)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .multilineTextAlignment(.center)
                    .foregroundColor(isSelected ? .white : .gray)
                    .lineLimit(2)
                    .frame(width: 70)
                    .minimumScaleFactor(0.8)
            }
            .padding(.vertical, 4)
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview("New Habit Form") {
    HabitFormPreviewView()
}

#Preview("Edit Habit Form") {
    let habit = Habit(
        id: UUID(),
        type: .mindfulness,
        streakCount: 5,
        lastCompletedDate: nil,
        reminderTime: Date(),
        reminderEnabled: true,
        notes: "Meditate in the morning for clarity and focus"
    )
    
    HabitFormPreviewView(existingHabit: habit)
}

#Preview("Dark Mode") {
    HabitFormPreviewView()
        .preferredColorScheme(.dark)
}

struct HabitFormPreviewView: View {
    let container: ModelContainer
    let viewModel: HabitViewModel
    let existingHabit: Habit?
    
    init(existingHabit: Habit? = nil) {
        self.existingHabit = existingHabit
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try! ModelContainer(for: Habit.self, HabitEntry.self, configurations: config)
        
        let vm = HabitViewModel()
        vm.modelContext = container.mainContext
        vm.createDefaultHabitsIfNeeded()
        self.viewModel = vm
    }
    
    var body: some View {
        HabitFormView(existingHabit: existingHabit)
            .environmentObject(viewModel)
            .modelContainer(container)
    }
}
