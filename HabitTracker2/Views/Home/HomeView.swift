//
//  HomeView.swift
//  HabitTracker2
import SwiftUI
import SwiftData
import Combine

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = HabitViewModel()
    @Query private var habits: [Habit]
    @State private var showingForm = false
    @State private var selectedHabit: Habit?
    @State private var showingList = false
    
    init() {
        // Temporary initialization - will be updated in onAppear
        _viewModel = StateObject(wrappedValue: HabitViewModel())
//        _viewModel = StateObject(wrappedValue: HabitViewModel(modelContext: ModelContext()))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Today's Progress")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Text(formattedDate)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        
                        Button(action: { showingList = true }) {
                            Image(systemName: "list.bullet")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        
                        Button(action: { showingForm = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Streak Cards
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Your Streaks")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(habits) { habit in
                                    StreakCard(habit: habit)
                                        .environmentObject(viewModel)
                                        .onTapGesture {
                                            selectedHabit = habit
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Today's Progress
                    TodayProgressView(habits: habits)
                        .environmentObject(viewModel)
                        .padding(.horizontal)
                    
                    // Quick Actions
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Quick Actions")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(habits) { habit in
                                QuickActionButton(habit: habit, viewModel: viewModel)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingForm) {
                HabitFormView()
                    .environmentObject(viewModel)
            }
            .sheet(isPresented: $showingList) {
                HabitListView()
                    .environmentObject(viewModel)
            }
            .sheet(item: $selectedHabit) { habit in
                HabitDetailView(habit: habit)
                    .environmentObject(viewModel)
            }
        }
        .onAppear {
            // Update viewModel with modelContext
            viewModel.modelContext = modelContext
            viewModel.createDefaultHabitsIfNeeded()
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter.string(from: Date())
    }
}

struct QuickActionButton: View {
    let habit: Habit
    let viewModel: HabitViewModel
    
    var body: some View {
        Button(action: {
            viewModel.toggleHabitCompletion(habit)
        }) {
            VStack(spacing: 8) {
                Image(systemName: habit.type.icon)
                    .font(.title2)
                Text(habit.type.rawValue)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                Text(habit.type.targetDisplayValue)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(habit.isCompletedToday ? Color.green.opacity(0.2) : Color.gray.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(habit.isCompletedToday ? Color.green : Color.clear, lineWidth: 1)
            )
        }
        .foregroundColor(habit.isCompletedToday ? .green : .primary)
    }
}

#Preview("Home View") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Habit.self, HabitEntry.self, configurations: config)
    
    // Add sample data for preview
    let context = container.mainContext
    let sampleHabits = [
        Habit(type: .focusedWork, streakCount: 7),
        Habit(type: .water, streakCount: 3),
        Habit(type: .mindfulness, streakCount: 12),
        Habit(type: .reading, streakCount: 5),
        Habit(type: .dailyWalk, streakCount: 2),
        Habit(type: .screenOff, streakCount: 4)
    ]
    
    for habit in sampleHabits {
        context.insert(habit)
    }
    
    return HomeView()
        .modelContainer(container)
}
