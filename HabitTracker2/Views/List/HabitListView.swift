//
//  HabitListView.swift
//  HabitTracker2

import SwiftUI
import SwiftData
import Combine

struct HabitListView: View {
    @EnvironmentObject var viewModel: HabitViewModel
    @Environment(\.dismiss) var dismiss
    @Query private var habits: [Habit]
    @State private var showingForm = false
    @State private var selectedHabit: Habit?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(habits) { habit in
                    HabitRowView(habit: habit)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedHabit = habit
                        }
                }
                .onDelete { indexSet in
                    viewModel.deleteHabit(at: indexSet)
                }
            }
            .navigationTitle("All Habits")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingForm = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingForm) {
                HabitFormView()
                    .environmentObject(viewModel)
            }
            .sheet(item: $selectedHabit) { habit in
                HabitDetailView(habit: habit)
                    .environmentObject(viewModel)
            }
        }
    }
}

#Preview("Habit List") {
    HabitListPreviewWrapper()
}

struct HabitListPreviewWrapper:View {
    let container: ModelContainer
    let viewModel: HabitViewModel
    
    init() {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try! ModelContainer(for: Habit.self, HabitEntry.self, configurations: config)
        
        // Add sample data
        let context = container.mainContext
        let sampleHabits = [
            Habit(type: .focusedWork, streakCount: 7, reminderEnabled: true),
            Habit(type: .water, streakCount: 3),
            Habit(type: .mindfulness, streakCount: 12, reminderEnabled: true),
            Habit(type: .reading, streakCount: 5),
            Habit(type: .dailyWalk, streakCount: 2),
            Habit(type: .screenOff, streakCount: 4)
        ]
        
        for habit in sampleHabits {
            context.insert(habit)
        }
        
        let vm = HabitViewModel()
        vm.modelContext = context
        self.viewModel = vm
    }
    
    var body: some View {
        return HabitListView()
            .environmentObject(viewModel)
            .modelContainer(container)
    }
}
