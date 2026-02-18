//
//  Habit.swift
//  HabitTracker2
//
import Foundation
import SwiftUI
import SwiftData
import Combine

enum HabitType: String, CaseIterable, Identifiable, Codable {
    case focusedWork = "Focused Work"
    case water = "Water Intake"
    case mindfulness = "Mindfulness"
    case reading = "Reading"
    case dailyWalk = "Daily Walk"
    case screenOff = "Screen Off"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .focusedWork: return "timer"
        case .water: return "drop.fill"
        case .mindfulness: return "brain.head.profile"
        case .reading: return "book.fill"
        case .dailyWalk: return "figure.walk"
        case .screenOff: return "moon.fill"
        }
    }
    
    var unit: String {
        switch self {
        case .focusedWork: return "minutes"
        case .water: return "liters"
        case .mindfulness: return "minutes"
        case .reading: return "minutes"
        case .dailyWalk: return "walk"
        case .screenOff: return "PM"
        }
    }
    
    var targetValue: Double {
        switch self {
        case .focusedWork: return 30
        case .water: return 2.0
        case .mindfulness: return 10
        case .reading: return 20
        case .dailyWalk: return 1
        case .screenOff: return 22.5 // 10:30 PM = 22.5
        }
    }
    
    var targetDisplayValue: String {
        switch self {
        case .focusedWork: return "30 min"
        case .water: return "2 L"
        case .mindfulness: return "10 min"
        case .reading: return "20 min"
        case .dailyWalk: return "1 walk"
        case .screenOff: return "10:30 PM"
        }
    }
}

@Model
final class Habit {
    var id: UUID
    var typeRawValue: String
    var streakCount: Int = 0
    var lastCompletedDate: Date? = nil
    var reminderTime: Date? = nil
    var reminderEnabled: Bool = false
    var notes: String? = nil
    var createdAt: Date = Date()
   
    
    @Relationship(deleteRule: .cascade) var entries: [HabitEntry]?
    
    var type: HabitType {
        get {
            HabitType(rawValue: typeRawValue) ?? .focusedWork
        }
        set {
            typeRawValue = newValue.rawValue
        }
    }
    
    var isCompletedToday: Bool {
        guard let entries = entries else { return false }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return entries.contains { entry in
            calendar.isDate(entry.date, inSameDayAs: today) && entry.isCompleted
        }
    }
    
    init(id: UUID = UUID(), type: HabitType, streakCount: Int = 0, lastCompletedDate: Date? = nil, reminderTime: Date? = nil, reminderEnabled: Bool = false, notes: String? = nil) {
        self.id = id
        self.typeRawValue = type.rawValue
        self.streakCount = streakCount
        self.lastCompletedDate = lastCompletedDate
        self.reminderTime = reminderTime
        self.reminderEnabled = reminderEnabled
        self.notes = notes
        self.createdAt = Date()
    }
    
    func toggleCompletion() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if isCompletedToday {
            // Remove today's entry
            entries?.removeAll { calendar.isDate($0.date, inSameDayAs: today) }
            streakCount = max(0, streakCount - 1)
        } else {
            // Add completion entry
            let entry = HabitEntry(value: type.targetValue, isCompleted: true)
            entry.habit = self
            
            if entries == nil {
                entries = [entry]
            } else {
                entries?.append(entry)
            }
            
            // Update streak
            if let lastDate = lastCompletedDate, calendar.isDate(lastDate, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: today) ?? today) {
                streakCount += 1
            } else {
                streakCount = 1
            }
            
            lastCompletedDate = today
        }
    }
}

#Preview {
    let habit = Habit(type: .focusedWork, streakCount: 7, reminderEnabled: true, notes: "Sample habit for preview")
    return VStack {
        Text("Habit Model Preview")
            .font(.headline)
        Text(habit.type.rawValue)
        Text("Streak: \(habit.streakCount)")
    }
    .padding()
}

