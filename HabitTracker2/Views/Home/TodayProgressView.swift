//
//  TodayProgressView.swift
//  HabitTracker2
//

import SwiftUI
import Combine

struct TodayProgressView: View {
    let habits: [Habit]
    @EnvironmentObject var viewModel: HabitViewModel
    
    var completedCount: Int {
        habits.filter { $0.isCompletedToday }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Daily Progress")
                    .font(.headline)
                Spacer()
                Text("\(completedCount)/\(habits.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: Double(completedCount), total: Double(habits.count))
                .tint(.blue)
                .scaleEffect(x: 1, y: 2, anchor: .center)
            
            HStack(spacing: 15) {
                ForEach(habits) { habit in
                    VStack(spacing: 4) {
                        Image(systemName: habit.type.icon)
                            .font(.caption)
                            .foregroundColor(habit.isCompletedToday ? .green : .gray)
                        Text(habit.type.rawValue.prefix(3))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(15)
    }
}


