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
    
    // Custom colors matching HomeView
    private let primaryGradient = LinearGradient(
        colors: [Color.blue, Color.cyan.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    private let cardBackground = Color(.secondarySystemBackground)
    private let accentColor = Color.blue
    
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
                // Background
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header with icon
                        VStack(spacing: 16) {
                            // Animated icon based on selected type
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.blue.opacity(0.2), Color.cyan.opacity(0.2)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: selectedType.icon)
                                    .font(.system(size: 50))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color.blue, Color.cyan],
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
                                        colors: [Color.primary, Color.blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        }
                        
                        // Form Fields
                        VStack(spacing: 20) {
                            // Habit Type Selection Card
                            VStack(alignment: .leading, spacing: 12) {
                                Label {
                                    Text("Habit Type")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                } icon: {
                                    Image(systemName: "figure.mind.body")
                                        .foregroundColor(.blue)
                                }
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(HabitType.allCases) { type in
                                            HabitTypeButton(
                                                type: type,
                                                isSelected: selectedType == type,
                                                action: { selectedType = type }
                                            )
                                        }
                                    }
                                    .padding(.horizontal, 4)
                                }
                            }
                            .padding()
                            .background(cardBackground)
                            .cornerRadius(16)
                            
                            // Daily Target Card
                            VStack(alignment: .leading, spacing: 12) {
                                Label {
                                    Text("Daily Target")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                } icon: {
                                    Image(systemName: "target")
                                        .foregroundColor(.blue)
                                }
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Your goal")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text(selectedType.targetDisplayValue)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.blue)
                                    }
                                    
                                    Spacer()
                                    
                                    // Target visualization
                                    ZStack {
                                        Circle()
                                            .stroke(Color.blue.opacity(0.2), lineWidth: 4)
                                            .frame(width: 60, height: 60)
                                        
                                        Circle()
                                            .trim(from: 0, to: 1.0)
                                            .stroke(
                                                primaryGradient,
                                                style: StrokeStyle(lineWidth: 4, lineCap: .round)
                                            )
                                            .frame(width: 60, height: 60)
                                            .rotationEffect(.degrees(-90))
                                        
                                        Text("100%")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            .padding()
                            .background(cardBackground)
                            .cornerRadius(16)
                            
                            // Reminder Card
                            VStack(alignment: .leading, spacing: 12) {
                                Label {
                                    Text("Reminder")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                } icon: {
                                    Image(systemName: "bell.fill")
                                        .foregroundColor(.blue)
                                }
                                
                                Toggle(isOn: $reminderEnabled.animation()) {
                                    Text("Enable daily reminder")
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                }
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                                
                                if reminderEnabled {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Reminder Time")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        HStack {
                                            Image(systemName: "clock.fill")
                                                .foregroundColor(.blue)
                                            
                                            DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                                                .labelsHidden()
                                                .datePickerStyle(.compact)
                                                .accentColor(.blue)
                                            
                                            Spacer()
                                        }
                                        .padding()
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(12)
                                    }
                                    .transition(.opacity.combined(with: .slide))
                                }
                            }
                            .padding()
                            .background(cardBackground)
                            .cornerRadius(16)
                            
                            // Notes Card
                            VStack(alignment: .leading, spacing: 12) {
                                Label {
                                    Text("Notes")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                } icon: {
                                    Image(systemName: "note.text")
                                        .foregroundColor(.blue)
                                }
                                
                                TextEditor(text: $notes)
                                    .frame(height: 100)
                                    .padding(8)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color.blue.opacity(0.3), Color.cyan.opacity(0.3)],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                                
                                if notes.isEmpty {
                                    Text("Add any additional notes or motivation...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.leading, 4)
                                }
                            }
                            .padding()
                            .background(cardBackground)
                            .cornerRadius(16)
                            
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
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
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
                            .foregroundColor(.secondary)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text(existingHabit == nil ? "New Habit" : "Edit Habit")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.primary, Color.blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: saveHabit) {
                        Text("Save")
                            .fontWeight(.semibold)
                            .foregroundStyle(primaryGradient)
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
    
    private let primaryGradient = LinearGradient(
        colors: [Color.blue, Color.cyan.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            isSelected ?
                            primaryGradient :
                            LinearGradient(
                                colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: type.icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? .white : .gray)
                }
                
                Text(type.rawValue)
                    .font(.caption2)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .multilineTextAlignment(.center)
                    .foregroundColor(isSelected ? .blue : .secondary)
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
    
    return HabitFormPreviewView(existingHabit: habit)
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
// MARK: - Previews (FIXED with all required parameters)




