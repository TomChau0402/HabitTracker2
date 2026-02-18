//
//  HabitRowView.swift
//  HabitTracker2
//

import SwiftUI
import Combine

struct HabitRowView: View {
    let habit: Habit
    
    var body: some View {
        HStack(spacing: 15) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: habit.type.icon)
                    .foregroundColor(.blue)
            }
            
            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.type.rawValue)
                    .font(.headline)
                
                HStack {
                    Text("Target: \(habit.type.targetDisplayValue)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if habit.reminderEnabled {
                        Image(systemName: "bell.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Spacer()
            
            // Streak
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(habit.streakCount)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text("streak")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
        .background(habit.isCompletedToday ? Color.green.opacity(0.1) : Color.clear)
        .cornerRadius(8)
    }
}

#Preview("Habit Row - Completed Today") {
    let habit = Habit(type: .focusedWork, streakCount: 7, reminderEnabled: true)
    let entry = HabitEntry(value: 30, isCompleted: true)
    entry.habit = habit
    habit.entries = [entry]
    
    return List {
        HabitRowView(habit: habit)
    }
    .previewLayout(.sizeThatFits)
}

#Preview("Habit Row - Not Completed") {
    let habit = Habit(type: .water, streakCount: 3)
    
    return List {
        HabitRowView(habit: habit)
    }
    .previewLayout(.sizeThatFits)
}

#Preview("Habit Row - Long Streak") {
    let habit = Habit(type: .mindfulness, streakCount: 30, reminderEnabled: true)
    
    return List {
        HabitRowView(habit: habit)
    }
    .previewLayout(.sizeThatFits)
}
