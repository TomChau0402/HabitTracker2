import SwiftUI
import Combine

struct CalendarView: View {
    let habit: Habit
    let entries: [HabitEntry]
    @State private var currentMonth = Date()
    
    let calendar = Calendar.current
    let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    
    // Enhanced color scheme matching HomeView with darker tones
    private let deepBlue = Color(red: 0.2, green: 0.4, blue: 0.9)
    private let teal = Color(red: 0.1, green: 0.7, blue: 0.8)
    private let darkBlue = Color(red: 0.1, green: 0.2, blue: 0.5)
    
    // Computed properties for gradients
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
    
    private var todayGradient: LinearGradient {
        LinearGradient(
            colors: [deepBlue, teal],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Month header with enhanced styling
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                colors: [.white.opacity(0.3), teal.opacity(0.3)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                        )
                        .shadow(color: deepBlue.opacity(0.3), radius: 5, x: 0, y: 2)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(monthYearString)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, teal],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    // Streak indicator for the month
                    let completedCount = daysInMonth.compactMap { $0 }.filter { isDateCompleted($0) }.count
                    let totalDays = daysInMonth.compactMap { $0 }.count
                    if totalDays > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption2)
                                .foregroundColor(.green)
                            Text("\(completedCount)/\(totalDays) completed")
                                .font(.caption2)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                colors: [.white.opacity(0.3), teal.opacity(0.3)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                        )
                        .shadow(color: deepBlue.opacity(0.3), radius: 5, x: 0, y: 2)
                }
            }
            .padding(.horizontal)
            
            // Day headers with gradient
            HStack {
                ForEach(Array(daysOfWeek.enumerated()), id: \.element) { index, day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(
                            index == 0 || index == 6 ?
                                teal.opacity(0.9) :
                                .white.opacity(0.7)
                        )
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
                            isToday: calendar.isDateInToday(date),
                            deepBlue: deepBlue,
                            teal: teal
                        )
                    } else {
                        Color.clear
                            .frame(height: 44)
                    }
                }
            }
            .padding(.horizontal, 4)
            
            // Legend
            HStack(spacing: 20) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(completedGradient)
                        .frame(width: 12, height: 12)
                        .shadow(color: .green.opacity(0.3), radius: 3, x: 0, y: 1)
                    
                    Text("Completed")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                HStack(spacing: 8) {
                    Circle()
                        .stroke(
                            todayGradient,
                            lineWidth: 2
                        )
                        .frame(width: 12, height: 12)
                        .background(
                            Circle()
                                .fill(deepBlue.opacity(0.2))
                                .frame(width: 10, height: 10)
                        )
                    
                    Text("Today")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.2), teal.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
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
    let deepBlue: Color
    let teal: Color
    
    // Computed properties for gradients
    private var completedGradient: LinearGradient {
        LinearGradient(
            colors: [Color.green, Color.mint],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var todayGradient: LinearGradient {
        LinearGradient(
            colors: [deepBlue, teal],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        ZStack {
            // Background for completed days with glow
            if isCompleted {
                Circle()
                    .fill(completedGradient)
                    .frame(width: 40, height: 40)
                    .shadow(color: .green.opacity(0.4), radius: 8, x: 0, y: 2)
                
                // Inner glow
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 20, height: 20)
                    .blur(radius: 5)
            }
            
            // Border and background for today
            if isToday && !isCompleted {
                Circle()
                    .stroke(
                        todayGradient,
                        lineWidth: 2.5
                    )
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(deepBlue.opacity(0.15))
                            .frame(width: 38, height: 38)
                    )
                    .shadow(color: deepBlue.opacity(0.3), radius: 5, x: 0, y: 2)
            }
            
            // Background for regular days (ultra thin material)
            if !isCompleted && !isToday {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 36, height: 36)
                    .opacity(0.5)
            }
            
            // Day number
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 16, weight: isCompleted || isToday ? .bold : .medium))
                .foregroundColor(
                    isCompleted ? .white :
                    isToday ? .white :
                    .white.opacity(0.8)
                )
        }
        .frame(height: 44)
        .contentShape(Circle())
    }
}

// MARK: - Previews with proper background
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
    
    // Create entries for different dates
    let calendar = Calendar.current
    let today = Date()
    let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
    let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
    let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: today)!
    let lastWeek = calendar.date(byAdding: .day, value: -7, to: today)!
    
    let entries = [
        HabitEntry(id: UUID(), date: today, value: 30, isCompleted: true, notes: nil),
        HabitEntry(id: UUID(), date: yesterday, value: 30, isCompleted: true, notes: nil),
        HabitEntry(id: UUID(), date: twoDaysAgo, value: 30, isCompleted: true, notes: nil),
        HabitEntry(id: UUID(), date: threeDaysAgo, value: 30, isCompleted: false, notes: nil),
        HabitEntry(id: UUID(), date: lastWeek, value: 30, isCompleted: true, notes: nil)
    ]
    
    return ZStack {
        // Dark gradient background matching HomeView
        LinearGradient(
            colors: [Color.black.opacity(0.8), Color(red: 0.1, green: 0.2, blue: 0.5)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        
        CalendarView(habit: habit, entries: entries)
            .padding()
    }
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
    
    return ZStack {
        LinearGradient(
            colors: [Color.black.opacity(0.8), Color(red: 0.1, green: 0.2, blue: 0.5)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        
        CalendarView(habit: habit, entries: [])
            .padding()
    }
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
    
    let entries = [
        HabitEntry(id: UUID(), date: today, value: 10, isCompleted: true, notes: nil)
    ]
    
    return ZStack {
        LinearGradient(
            colors: [Color.black.opacity(0.8), Color(red: 0.1, green: 0.2, blue: 0.5)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        
        CalendarView(habit: habit, entries: entries)
            .padding()
    }
}
