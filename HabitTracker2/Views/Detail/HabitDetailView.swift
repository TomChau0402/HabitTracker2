//
//  HabitDetailView.swift
//  HabitTracker2
import SwiftUI
import SwiftData

struct HabitDetailView: View {
    @EnvironmentObject var viewModel: HabitViewModel
    @Environment(\.dismiss) var dismiss
    @State var habit: Habit
    @State private var showingEditForm = false
    @State private var showingDeleteAlert = false
    
    var entries: [HabitEntry] {
        viewModel.entries(for: habit)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 15) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: habit.type.icon)
                                .font(.system(size: 50))
                                .foregroundColor(.blue)
                        }
                        
                        Text(habit.type.rawValue)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Target: \(habit.type.targetDisplayValue)")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    // Stats Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        StatCard(value: "\(habit.streakCount)", label: "Current Streak", icon: "flame.fill")
                        StatCard(value: "\(entries.count)", label: "Total Days", icon: "calendar")
                        StatCard(value: "\(bestStreak())", label: "Best Streak", icon: "trophy.fill")
                    }
                    .padding(.horizontal)
                    
                    // Today's Status
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Today's Status")
                            .font(.headline)
                        
                        HStack {
                            Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(habit.isCompletedToday ? .green : .gray)
                                .font(.title2)
                            
                            Text(habit.isCompletedToday ? "Completed" : "Not Started")
                                .foregroundColor(habit.isCompletedToday ? .green : .primary)
                            
                            Spacer()
                            
                            Button(action: {
                                viewModel.toggleHabitCompletion(habit)
                            }) {
                                Text(habit.isCompletedToday ? "Undo" : "Mark Complete")
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(habit.isCompletedToday ? Color.red : Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    // Reminder
                    if habit.reminderEnabled, let reminderTime = habit.reminderTime {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Reminder")
                                .font(.headline)
                            
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(.blue)
                                Text("Daily at \(reminderTime, formatter: timeFormatter)")
                                Spacer()
                                Toggle("", isOn: Binding(
                                    get: { habit.reminderEnabled },
                                    set: { newValue in
                                        habit.reminderEnabled = newValue
                                        viewModel.updateHabit(habit)
                                    }
                                ))
                                .labelsHidden()
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }
                    
                    // Notes
                    if let notes = habit.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Notes")
                                .font(.headline)
                            
                            Text(notes)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }
                    
                    // Calendar
                    VStack(alignment: .leading) {
                        Text("History")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        CalendarView(habit: habit, entries: entries)
                    }
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(action: { showingEditForm = true }) {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive, action: { showingDeleteAlert = true }) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .alert("Delete Habit", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    viewModel.deleteHabit(habit)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this habit? This action cannot be undone.")
            }
            .sheet(isPresented: $showingEditForm) {
                HabitFormView(existingHabit: habit)
                    .environmentObject(viewModel)
            }
        }
    }
    
    func bestStreak() -> Int {
        // Simple implementation - in a real app, you'd calculate this from entries
        return habit.streakCount
    }
    
    var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

// MARK: - Simple Preview (No complex setup)
#Preview("Habit Detail") {
    // Create a simple habit for preview
    let habit = Habit(
        type: .focusedWork,
        streakCount: 7,
        lastCompletedDate: nil,
        reminderTime: Date(),
        reminderEnabled: true,
        notes: "Sample notes for preview"
    )
    

    
}
