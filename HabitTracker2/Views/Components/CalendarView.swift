import SwiftUI
import Combine

struct CalendarView: View {
    let habit: Habit
    let entries: [HabitEntry]
    @State private var currentMonth = Date()
    
    let calendar = Calendar.current
    let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    
    // Custom colors matching HomeView
    private let primaryGradient = LinearGradient(
        colors: [Color.blue, Color.cyan.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    private let completedGradient = LinearGradient(
        colors: [Color.green, Color.mint],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        VStack(spacing: 20) {
            // Month header with enhanced styling
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(primaryGradient)
                        .frame(width: 36, height: 36)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Circle())
                        .shadow(color: .blue.opacity(0.1), radius: 3, x: 0, y: 2)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(monthYearString)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.primary, Color.blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    // Streak indicator for the month
                    let completedCount = daysInMonth.compactMap { $0 }.filter { isDateCompleted($0) }.count
                    let totalDays = daysInMonth.compactMap { $0 }.count
                    if totalDays > 0 {
                        Text("\(completedCount)/\(totalDays) completed")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(primaryGradient)
                        .frame(width: 36, height: 36)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Circle())
                        .shadow(color: .blue.opacity(0.1), radius: 3, x: 0, y: 2)
                }
            }
            .padding(.horizontal)
            
            // Day headers with gradient
            HStack {
                ForEach(Array(daysOfWeek.enumerated()), id: \.element) { index, day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(index == 0 || index == 6 ? .blue.opacity(0.8) : .secondary)
                }
            }
            .padding(.horizontal, 4)
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(daysInMonth.indices, id: \.self) { index in
                    if let date = daysInMonth[index] {
                        DayCell(
                            date: date,
                            isCompleted: isDateCompleted(date),
                            isToday: calendar.isDateInToday(date)
                        )
                    } else {
                        Color.clear
                            .frame(height: 44)
                    }
                }
            }
            .padding(.horizontal, 4)
            
            // Legend
            HStack(spacing: 16) {
                Label {
                    Text("Completed")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                } icon: {
                    Circle()
                        .fill(completedGradient)
                        .frame(width: 12, height: 12)
                }
                
                Label {
                    Text("Today")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                } icon: {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color.blue, Color.cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 12, height: 12)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .blue.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.3), Color.cyan.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
    
    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    var daysInMonth: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstDay) - 1
        let numberOfDays = range.count
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday)
        
        for day in 1...numberOfDays {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        
        // Pad the end if needed to maintain grid structure
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days
    }
    
    func isDateCompleted(_ date: Date) -> Bool {
        entries.contains { entry in
            calendar.isDate(entry.date, inSameDayAs: date) && entry.isCompleted
        }
    }
    
    func previousMonth() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if let newDate = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
                currentMonth = newDate
            }
        }
    }
    
    func nextMonth() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if let newDate = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
                currentMonth = newDate
            }
        }
    }
}

struct DayCell: View {
    let date: Date
    let isCompleted: Bool
    let isToday: Bool
    
    // Custom colors
    private let completedGradient = LinearGradient(
        colors: [Color.green, Color.mint],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    private let todayGradient = LinearGradient(
        colors: [Color.blue, Color.cyan],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        ZStack {
            // Background for completed days
            if isCompleted {
                Circle()
                    .fill(completedGradient)
                    .frame(width: 38, height: 38)
                    .shadow(color: .green.opacity(0.3), radius: 3, x: 0, y: 2)
            }
            
            // Border for today
            if isToday && !isCompleted {
                Circle()
                    .stroke(
                        todayGradient,
                        lineWidth: 2.5
                    )
                    .frame(width: 38, height: 38)
                    .background(
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 36, height: 36)
                    )
            }
            
            // Day number
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 16, weight: isCompleted || isToday ? .semibold : .regular))
                .foregroundColor(
                    isCompleted ? .white :
                    isToday ? .blue :
                    .primary
                )
        }
        .frame(height: 44)
        .contentShape(Circle())
    }
}

// MARK: - Previews (FIXED PARAMETER ORDER)
#Preview("Calendar View - With Data") {
    let habit = Habit(
        id: UUID(),
        type: .focusedWork,
        streakCount: 7,
        lastCompletedDate: nil,
        reminderTime: nil,
        reminderEnabled: false,
        notes: nil
    )
    
    // Create entries for different dates with correct parameter order
    let calendar = Calendar.current
    let today = Date()
    let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
    let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
    let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: today)!
    let lastWeek = calendar.date(byAdding: .day, value: -7, to: today)!
    
    // Fixed parameter order: id, date, value, isCompleted, notes
    let entries = [
        HabitEntry(id: UUID(), date: today, value: 30, isCompleted: true, notes: nil),
        HabitEntry(id: UUID(), date: yesterday, value: 30, isCompleted: true, notes: nil),
        HabitEntry(id: UUID(), date: twoDaysAgo, value: 30, isCompleted: true, notes: nil),
        HabitEntry(id: UUID(), date: threeDaysAgo, value: 30, isCompleted: false, notes: nil),
        HabitEntry(id: UUID(), date: lastWeek, value: 30, isCompleted: true, notes: nil)
    ]
    
    CalendarView(habit: habit, entries: entries)
        .padding()
        .background(Color(.systemBackground))
}

#Preview("Calendar View - Empty") {
    let habit = Habit(
        id: UUID(),
        type: .water,
        streakCount: 0,
        lastCompletedDate: nil,
        reminderTime: nil,
        reminderEnabled: false,
        notes: nil
    )
    
    CalendarView(habit: habit, entries: [])
        .padding()
        .background(Color(.systemBackground))
}

#Preview("Calendar View - Dark Mode") {
    let habit = Habit(
        id: UUID(),
        type: .mindfulness,
        streakCount: 12,
        lastCompletedDate: nil,
        reminderTime: nil,
        reminderEnabled: false,
        notes: nil
    )
    
    let calendar = Calendar.current
    let today = Date()
    
    // Fixed parameter order: id, date, value, isCompleted, notes
    let entries = [
        HabitEntry(id: UUID(), date: today, value: 10, isCompleted: true, notes: nil)
    ]
    
    CalendarView(habit: habit, entries: entries)
        .padding()
        .background(Color(.systemBackground))
        .preferredColorScheme(.dark)
}
