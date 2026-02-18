
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
    
    init(existingHabit: Habit? = nil) {
        self.existingHabit = existingHabit
        _selectedType = State(initialValue: existingHabit?.type ?? .focusedWork)
        _reminderEnabled = State(initialValue: existingHabit?.reminderEnabled ?? false)
        _reminderTime = State(initialValue: existingHabit?.reminderTime ?? Date())
        _notes = State(initialValue: existingHabit?.notes ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Habit Type", selection: $selectedType) {
                        ForEach(HabitType.allCases) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    
                    HStack {
                        Text("Daily Target")
                        Spacer()
                        Text(selectedType.targetDisplayValue)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Habit Details")
                }
                
                Section {
                    Toggle("Enable Reminder", isOn: $reminderEnabled)
                    
                    if reminderEnabled {
                        DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    }
                } header: {
                    Text("Reminder")
                } footer: {
                    Text("Get notified to complete this habit daily")
                }
                
                Section {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                } header: {
                    Text("Notes")
                }
                
                if existingHabit != nil {
                    Section {
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            HStack {
                                Spacer()
                                Text("Delete Habit")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(existingHabit == nil ? "New Habit" : "Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveHabit()
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

#Preview("New Habit Form") {
    HabitFormPreviewView()
}

struct HabitFormPreviewView: View {
    let container: ModelContainer
    let viewModel: HabitViewModel
    
    init() {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try! ModelContainer(for: Habit.self, HabitEntry.self, configurations: config)
        
        let vm = HabitViewModel()
        vm.modelContext = container.mainContext
        vm.createDefaultHabitsIfNeeded()
        self.viewModel = vm
        // Return the view without using 'return' keyword
    }
    var body: some View {
        // Create container and context
        HabitFormView()
            .environmentObject(viewModel)
            .modelContainer(container)
    }
}

// MARK: - Previews (FIXED with all required parameters)




