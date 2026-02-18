//
//  HabitEntry.swift
//  HabitTracker2
//
import Foundation
import SwiftUI
import SwiftData
import Combine

@Model
final class HabitEntry {
    var id: UUID
    var date: Date
    var value: Double
    var isCompleted: Bool
    var notes: String?
    
    @Relationship(inverse: \Habit.entries) var habit: Habit?
    
    init(id: UUID = UUID(), date: Date = Date(), value: Double, isCompleted: Bool = false, notes: String? = nil) {
        self.id = id
        self.date = date
        self.value = value
        self.isCompleted = isCompleted
        self.notes = notes
    }
}

#Preview {
    let entry = HabitEntry(value: 30, isCompleted: true)
    return VStack {
        Text("Habit Entry Preview")
            .font(.headline)
        Text("Date: \(entry.date.formatted(date: .abbreviated, time: .shortened))")
        Text("Completed: \(entry.isCompleted ? "Yes" : "No")")
    }
    .padding()
}
