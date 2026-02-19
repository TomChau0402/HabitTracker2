//
//  HabitRowView.swift
//  HabitTracker2
//

import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    
    // Custom colors matching HomeView
    private let primaryGradient = LinearGradient(
        colors: [Color.blue, Color.cyan.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon with gradient background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: habit.isCompletedToday ?
                                [Color.green, Color.mint] :
                                [Color.blue, Color.cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                    .opacity(0.15)
                
                Image(systemName: habit.type.icon)
                    .font(.title3)
                    .foregroundColor(habit.isCompletedToday ? .green : .blue)
            }
            
            // Details
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(habit.type.rawValue)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    // Reminder indicator
                    if habit.reminderEnabled {
                        HStack(spacing: 4) {
                            Image(systemName: "bell.fill")
                                .font(.caption2)
                            if let reminderTime = habit.reminderTime {
                                Text(reminderTime, style: .time)
                                    .font(.caption2)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Capsule())
                        .foregroundColor(.blue)
                    }
                }
                
                HStack(spacing: 12) {
                    // Target pill
                    Label {
                        Text(habit.type.targetDisplayValue)
                            .font(.caption2)
                    } icon: {
                        Image(systemName: "target")
                            .font(.caption2)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Capsule())
                    .foregroundColor(.secondary)
                    
                    // Streak indicator
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                        Text("\(habit.streakCount) day\(habit.streakCount == 1 ? "" : "s")")
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .clipShape(Capsule())
                    .foregroundColor(.orange)
                }
            }
            
            Spacer()
            
            // Completion indicator
            if habit.isCompletedToday {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.green)
                    .symbolEffect(.bounce, value: habit.isCompletedToday)
            } else {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.3), Color.cyan.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .fill(Color.blue.opacity(0.05))
                            .frame(width: 20, height: 20)
                    )
            }
        }
        .padding(.vertical, 8)
        .opacity(habit.isCompletedToday ? 1 : 0.9)
    }
}

// MARK: - Previews
#Preview("Habit Row - Completed") {
    let habit = Habit(
        id: UUID(),
        type: .focusedWork,
        streakCount: 7,
        lastCompletedDate: nil,
        reminderTime: Date(),
        reminderEnabled: true,
        notes: nil
    )
    
    // Mark as completed
    let entry = HabitEntry(value: 30, isCompleted: true)
    entry.habit = habit
    habit.entries = [entry]
    
    return List {
        HabitRowView(habit: habit)
    }
    .listStyle(.plain)
    .previewLayout(.sizeThatFits)
}

#Preview("Habit Row - Incomplete") {
    let habit = Habit(
        id: UUID(),
        type: .water,
        streakCount: 3,
        lastCompletedDate: nil,
        reminderTime: nil,
        reminderEnabled: false,
        notes: nil
    )
    
    return List {
        HabitRowView(habit: habit)
    }
    .listStyle(.plain)
    .previewLayout(.sizeThatFits)
}

#Preview("Habit Row - Long Streak") {
    let habit = Habit(
        id: UUID(),
        type: .mindfulness,
        streakCount: 30,
        lastCompletedDate: nil,
        reminderTime: Date(),
        reminderEnabled: true,
        notes: nil
    )
    
    return List {
        HabitRowView(habit: habit)
    }
    .listStyle(.plain)
    .previewLayout(.sizeThatFits)
}
