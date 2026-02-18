//
//  HabitViewModel.swift
//  HabitTracker2
//
import Foundation
import SwiftUI
import SwiftData
import Combine

@MainActor
class HabitViewModel: ObservableObject {
//    private var modelContext: ModelContext
    var modelContext: ModelContext!
    @Published var selectedDate = Date()
    
    init() {}
//    init(modelContext: ModelContext) {
//        self.modelContext = modelContext
//        createDefaultHabitsIfNeeded()
//    }
    
    var habits: [Habit] {
        let descriptor = FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.createdAt)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func entries(for habit: Habit) -> [HabitEntry] {
        let habitId = habit.id
        let descriptor = FetchDescriptor<HabitEntry>(
            predicate: #Predicate { $0.habit?.id == habitId },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func entriesForSelectedDate() -> [HabitEntry] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = #Predicate<HabitEntry> { entry in
            entry.date >= startOfDay && entry.date < endOfDay
        }
        
        let descriptor = FetchDescriptor<HabitEntry>(predicate: predicate)
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    // MARK: - Create
    func addHabit(type: HabitType, reminderTime: Date? = nil, reminderEnabled: Bool = false, notes: String? = nil) {
        let newHabit = Habit(
            type: type,
            reminderTime: reminderTime,
            reminderEnabled: reminderEnabled,
            notes: notes
        )
        modelContext.insert(newHabit)
        saveContext()
    }
    
    // MARK: - Update
    func updateHabit(_ habit: Habit) {
        saveContext()
    }
    
    func toggleHabitCompletion(_ habit: Habit) {
        habit.toggleCompletion()
        saveContext()
    }
    
    // MARK: - Delete
    func deleteHabit(_ habit: Habit) {
        modelContext.delete(habit)
        saveContext()
    }
    
    func deleteHabit(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(habits[index])
        }
        saveContext()
    }
    
    // MARK: - Private Methods
    func createDefaultHabitsIfNeeded() {
        let descriptor = FetchDescriptor<Habit>()
        let existingHabits = (try? modelContext.fetch(descriptor)) ?? []
        
        if existingHabits.isEmpty {
            for type in HabitType.allCases {
                addHabit(type: type)
            }
        }
    }
    
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}

#Preview {
    PreviewWrapper()
}

struct PreviewWrapper:View {
    let viewModel: HabitViewModel
    let container: ModelContainer
    
    init() {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try! ModelContainer(for: Habit.self, HabitEntry.self, configurations: config)
        
        //    let viewModel = HabitViewModel(modelContext: container.mainContext)
        let vm = HabitViewModel()
        vm.modelContext = container.mainContext
        vm.createDefaultHabitsIfNeeded()
        self.viewModel = vm
    }
    
    var body: some View {
        VStack {
            Text("ViewModel Preview")
                .font(.headline)
            
            Text("Habits count: \(viewModel.habits.count)")
            
            Button("Add Sample Habit") {
                viewModel.addHabit(type: .focusedWork)
            }
        }
        .padding()
        .modelContainer(container)
    }
}

