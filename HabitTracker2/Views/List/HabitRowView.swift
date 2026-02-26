//
//  HabitRowView.swift
//  HabitTracker2
//

import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    
    // Custom colors - defined as static constants or computed properties
    private let deepBlue = Color(red: 0.2, green: 0.4, blue: 0.9)
    private let teal = Color(red: 0.1, green: 0.7, blue: 0.8)
    private let darkBlue = Color(red: 0.1, green: 0.2, blue: 0.5)
    
    // Computed properties for gradients (to avoid initialization order issues)
    private var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [deepBlue, teal],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var completedGradient: LinearGradient {
        LinearGradient(
            colors: [Color.green, Color.mint],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var incompleteGradient: LinearGradient {
        LinearGradient(
            colors: [deepBlue.opacity(0.5), teal.opacity(0.5)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon with enhanced gradient background and glow
            ZStack {
                // Glow effect
                Circle()
                    .fill(habit.isCompletedToday ? Color.green.opacity(0.3) : deepBlue.opacity(0.3))
                    .frame(width: 58, height: 58)
                    .blur(radius: 10)
                
                // Main icon background with gradient
                Circle()
                    .fill(
                        LinearGradient(
                            colors: habit.isCompletedToday ?
                                [.green.opacity(0.2), .mint.opacity(0.2)] :
                                [deepBlue.opacity(0.2), teal.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)
                    .overlay(
                        Circle()
                            .stroke(
                                habit.isCompletedToday ?
                                    completedGradient.opacity(0.6) :
                                    primaryGradient.opacity(0.6),
                                lineWidth: 2.5
                            )
                    )
                    .shadow(color: habit.isCompletedToday ? .green.opacity(0.3) : deepBlue.opacity(0.3),
                           radius: 8, x: 0, y: 4)
                
                Image(systemName: habit.type.icon)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(habit.isCompletedToday ? .green : .white)
                    .scaleEffect(habit.isCompletedToday ? 1.1 : 1.0)
            }
            
            // Details
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(habit.type.rawValue)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Reminder indicator with enhanced styling
                    if habit.reminderEnabled {
                        HStack(spacing: 6) {
                            Image(systemName: "bell.badge.fill")
                                .font(.caption2)
                                .foregroundColor(teal)
                            if let reminderTime = habit.reminderTime {
                                Text(reminderTime, style: .time)
                                    .font(.caption2)
                                    .fontWeight(.medium)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Capsule()
                                        .stroke(teal.opacity(0.5), lineWidth: 1)
                                )
                        )
                        .foregroundColor(.white)
                    }
                }
                
                HStack(spacing: 10) {
                    // Target pill with enhanced design
                    HStack(spacing: 4) {
                        Image(systemName: "scope")
                            .font(.system(size: 8))
                            .foregroundColor(teal)
                        Text(habit.type.targetDisplayValue)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Capsule()
                                    .stroke(
                                        LinearGradient(
                                            colors: [deepBlue.opacity(0.5), teal.opacity(0.5)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                    )
                    .foregroundColor(.white)
                    
                    // Streak indicator with enhanced design
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                        Text("\(habit.streakCount)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.orange)
                        Text(habit.streakCount == 1 ? "day" : "days")
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Capsule()
                                    .stroke(Color.orange.opacity(0.4), lineWidth: 1)
                            )
                    )
                }
            }
            
            Spacer()
            
            // Completion indicator with enhanced styling
            if habit.isCompletedToday {
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(Color.green.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .blur(radius: 8)
                    
                    // Main circle
                    Circle()
                        .fill(completedGradient)
                        .frame(width: 34, height: 34)
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.5), lineWidth: 1.5)
                        )
                        .shadow(color: .green.opacity(0.5), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .symbolEffect(.bounce, value: habit.isCompletedToday)
            } else {
                ZStack {
                    Circle()
                        .stroke(
                            incompleteGradient,
                            lineWidth: 2
                        )
                        .frame(width: 34, height: 34)
                    
                    Circle()
                        .fill(deepBlue.opacity(0.1))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle()
                                .stroke(teal.opacity(0.3), lineWidth: 0.5)
                        )
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.2),
                                    habit.isCompletedToday ? .green.opacity(0.3) : teal.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        .scaleEffect(habit.isCompletedToday ? 1.01 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: habit.isCompletedToday)
    }
}

// MARK: - Previews with proper background
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
    
    return ZStack {
        // Dark gradient background matching HomeView
        LinearGradient(
            colors: [Color.black.opacity(0.8), Color(red: 0.1, green: 0.2, blue: 0.5)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        
        VStack {
            HabitRowView(habit: habit)
                .padding(.horizontal)
            Spacer()
        }
        .padding(.top, 20)
    }
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
    
    return ZStack {
        LinearGradient(
            colors: [Color.black.opacity(0.8), Color(red: 0.1, green: 0.2, blue: 0.5)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        
        VStack {
            HabitRowView(habit: habit)
                .padding(.horizontal)
            Spacer()
        }
        .padding(.top, 20)
    }
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
    
    return ZStack {
        LinearGradient(
            colors: [Color.black.opacity(0.8), Color(red: 0.1, green: 0.2, blue: 0.5)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        
        VStack {
            HabitRowView(habit: habit)
                .padding(.horizontal)
            Spacer()
        }
        .padding(.top, 20)
    }
    .previewLayout(.sizeThatFits)
}

#Preview("Habit Row - No Reminder") {
    let habit = Habit(
        id: UUID(),
        type: .reading,
        streakCount: 5,
        lastCompletedDate: nil,
        reminderTime: nil,
        reminderEnabled: false,
        notes: nil
    )
    
    return ZStack {
        LinearGradient(
            colors: [Color.black.opacity(0.8), Color(red: 0.1, green: 0.2, blue: 0.5)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        
        VStack {
            HabitRowView(habit: habit)
                .padding(.horizontal)
            Spacer()
        }
        .padding(.top, 20)
    }
    .previewLayout(.sizeThatFits)
}
