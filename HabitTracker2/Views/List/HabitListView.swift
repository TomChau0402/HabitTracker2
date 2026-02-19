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
    
    // Custom colors matching HomeView
    private let primaryGradient = LinearGradient(
        colors: [Color.blue, Color.cyan.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    private let cardBackground = Color(.secondarySystemBackground)
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                List {
                    // Header Section
                    Section {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Your Habits")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color.primary, Color.blue],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                
                                Text("\(habits.count) total • \(habits.filter { $0.isCompletedToday }.count) completed today")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Stats pill
                            let completionPercentage = habits.isEmpty ? 0 : Int((Double(habits.filter { $0.isCompletedToday }.count) / Double(habits.count)) * 100)
                            Text("\(completionPercentage)%")
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(primaryGradient.opacity(0.2))
                                )
                                .foregroundColor(.blue)
                                .overlay(
                                    Capsule()
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color.blue.opacity(0.5), Color.cyan.opacity(0.5)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                        }
                        .padding(.vertical, 8)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                    
                    // Habits List
                    ForEach(habits) { habit in
                        HabitRowView(habit: habit)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedHabit = habit
                                }
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.secondarySystemBackground))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .shadow(color: .blue.opacity(0.1), radius: 5, x: 0, y: 2)
                            )
                    }
                    .onDelete { indexSet in
                        withAnimation {
                            viewModel.deleteHabit(at: indexSet)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.footnote)
                                .fontWeight(.semibold)
                            Text("Back")
                                .font(.body)
                        }
                        .foregroundStyle(primaryGradient)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("All Habits")
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
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingForm = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(primaryGradient)
                            .symbolRenderingMode(.hierarchical)
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

// MARK: - Preview Wrapper
#Preview("Habit List") {
    HabitListPreviewWrapper()
}

#Preview("Habit List - Dark Mode") {
    HabitListPreviewWrapper()
        .preferredColorScheme(.dark)
}

struct HabitListPreviewWrapper: View {
    let container: ModelContainer
    let viewModel: HabitViewModel
    
    init() {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try! ModelContainer(for: Habit.self, HabitEntry.self, configurations: config)
        
        // Add sample data
        let context = container.mainContext
        let sampleHabits = [
            Habit(
                id: UUID(),
                type: .focusedWork,
                streakCount: 7,
                lastCompletedDate: nil,
                reminderTime: Date(),
                reminderEnabled: true,
                notes: "Deep work sessions"
            ),
            Habit(
                id: UUID(),
                type: .water,
                streakCount: 3,
                lastCompletedDate: nil,
                reminderTime: nil,
                reminderEnabled: false,
                notes: nil
            ),
            Habit(
                id: UUID(),
                type: .mindfulness,
                streakCount: 12,
                lastCompletedDate: nil,
                reminderTime: Date(),
                reminderEnabled: true,
                notes: "Morning meditation"
            ),
            Habit(
                id: UUID(),
                type: .reading,
                streakCount: 5,
                lastCompletedDate: nil,
                reminderTime: nil,
                reminderEnabled: false,
                notes: nil
            ),
            Habit(
                id: UUID(),
                type: .dailyWalk,
                streakCount: 2,
                lastCompletedDate: nil,
                reminderTime: nil,
                reminderEnabled: false,
                notes: nil
            ),
            Habit(
                id: UUID(),
                type: .screenOff,
                streakCount: 4,
                lastCompletedDate: nil,
                reminderTime: Date(),
                reminderEnabled: true,
                notes: "No screens after 10:30"
            )
        ]
        
        for habit in sampleHabits {
            context.insert(habit)
        }
        
        // Mark some as completed for preview
        if sampleHabits.count >= 3 {
            let entry1 = HabitEntry(value: 30, isCompleted: true)
            entry1.habit = sampleHabits[0]
            context.insert(entry1)
            
            let entry2 = HabitEntry(value: 2, isCompleted: true)
            entry2.habit = sampleHabits[1]
            context.insert(entry2)
            
            let entry3 = HabitEntry(value: 10, isCompleted: true)
            entry3.habit = sampleHabits[2]
            context.insert(entry3)
        }
        
        let vm = HabitViewModel()
        vm.modelContext = context
        self.viewModel = vm
    }
    
    var body: some View {
        HabitListView()
            .environmentObject(viewModel)
            .modelContainer(container)
    }
}
