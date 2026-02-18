//
//  HabitTracker2App.swift
//  HabitTracker2
//
import SwiftUI
import SwiftData

@main
struct HabitTrackerApp: App {
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: Habit.self, HabitEntry.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
        }
    }
}

struct ContentView: View {
    var body: some View {
        HomeView()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Habit.self, HabitEntry.self, configurations: config)
    
    ContentView()
        .modelContainer(container)
}
