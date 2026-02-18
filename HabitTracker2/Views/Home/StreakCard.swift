//
//  StreakCard.swift
//  HabitTracker2
import SwiftUI
import Combine

struct StreakCard: View {
    let habit: Habit
    @EnvironmentObject var viewModel: HabitViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: habit.type.icon)
                    .foregroundColor(.blue)
                Text(habit.type.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                Spacer()
            }
            
            Text("\(habit.streakCount)")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.blue)
            
            Text("day streak")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ProgressView(value: habit.isCompletedToday ? 1.0 : 0.0, total: 1.0)
                .tint(habit.isCompletedToday ? .green : .blue)
                .scaleEffect(x: 1, y: 0.5, anchor: .center)
        }
        .padding()
        .frame(width: 150)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
    }
}

