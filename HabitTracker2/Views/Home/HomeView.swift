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
    
    // Custom colors
    private let primaryGradient = LinearGradient(
        colors: [Color.blue, Color.cyan.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    private let accentColor = Color.blue
    private let cardBackground = Color(.secondarySystemBackground)
    private let secondaryText = Color.secondary
    
    init() {
        // Temporary initialization - will be updated in onAppear
        _viewModel = StateObject(wrappedValue: HabitViewModel())
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with gradient background
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Today's Progress")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.primary, .blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            
                            HStack {
                                Image(systemName: "calendar")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                Text(formattedDate)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 16) {
                            // List button
                            Button(action: { showingList = true }) {
                                Image(systemName: "list.bullet.rectangle")
                                    .font(.title2)
                                    .foregroundStyle(primaryGradient)
                                    .frame(width: 44, height: 44)
                                    .background(cardBackground)
                                    .clipShape(Circle())
                                    .shadow(color: .blue.opacity(0.1), radius: 5, x: 0, y: 2)
                            }
                            
                            // Add button
                            Button(action: { showingForm = true }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(primaryGradient)
                                    .frame(width: 44, height: 44)
                                    .background(cardBackground)
                                    .clipShape(Circle())
                                    .shadow(color: .blue.opacity(0.1), radius: 5, x: 0, y: 2)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Streak Cards Section
                    if !habits.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Label {
                                    Text("Your Streaks")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                } icon: {
                                    Image(systemName: "flame.fill")
                                        .foregroundColor(.orange)
                                }
                                
                                Spacer()
                                
                                Text("\(habits.filter { $0.isCompletedToday }.count)/\(habits.count) today")
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(Capsule())
                                    .foregroundColor(.blue)
                            }
                            .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(habits) { habit in
                                        StreakCard(habit: habit)
                                            .environmentObject(viewModel)
                                            .onTapGesture {
                                                selectedHabit = habit
                                            }
                                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 4)
                            }
                        }
                    }
                    
                    // Today's Progress Card
                    TodayProgressView(habits: habits)
                        .environmentObject(viewModel)
                        .padding(.horizontal)
                        .shadow(color: .blue.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    // Quick Actions Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Label {
                                Text("Quick Actions")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            } icon: {
                                Image(systemName: "bolt.fill")
                                    .foregroundColor(.yellow)
                            }
                            
                            Spacer()
                            
                            Text("Tap to track")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ],
                            spacing: 12
                        ) {
                            ForEach(habits) { habit in
                                QuickActionButton(habit: habit, viewModel: viewModel)
                                    .shadow(color: habit.isCompletedToday ? .green.opacity(0.2) : .gray.opacity(0.1),
                                            radius: 5, x: 0, y: 2)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Motivational Quote
                    if habits.filter({ $0.isCompletedToday }).count == habits.count {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("Perfect day! You've completed all habits! 🎉")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [.yellow.opacity(0.2), .orange.opacity(0.2)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemBackground))
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
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                viewModel.toggleHabitCompletion(habit)
            }
        }) {
            VStack(spacing: 12) {
                // Icon with gradient background
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: habit.isCompletedToday ?
                                    [.green, .mint] :
                                    [.blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .opacity(0.2)
                    
                    Image(systemName: habit.type.icon)
                        .font(.title2)
                        .foregroundColor(habit.isCompletedToday ? .green : .blue)
                        .scaleEffect(habit.isCompletedToday ? 1.1 : 1.0)
                }
                
                Text(habit.type.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .foregroundColor(.primary)
                
                // Target value pill
                Text(habit.type.targetDisplayValue)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(habit.isCompletedToday ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                    .clipShape(Capsule())
                    .foregroundColor(habit.isCompletedToday ? .green : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: habit.isCompletedToday ?
                                        [.green.opacity(0.5), .mint.opacity(0.5)] :
                                        [.blue.opacity(0.3), .cyan.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
            )
            .scaleEffect(habit.isCompletedToday ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: habit.isCompletedToday)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview("Home View") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Habit.self, HabitEntry.self, configurations: config)
    
    // Add sample data for preview
    let context = container.mainContext
    let sampleHabits = [
        Habit(
            id: UUID(),
            type: .focusedWork,
            streakCount: 7,
            lastCompletedDate: nil,
            reminderTime: nil,
            reminderEnabled: false,
            notes: nil
        ),
        Habit(
            id: UUID(),
            type: .water,
            streakCount: 3,
            lastCompletedDate: nil,
            reminderTime: nil,
            reminderEnabled: false,
            notes: nil
        ),
        Habit(
            id: UUID(),
            type: .mindfulness,
            streakCount: 12,
            lastCompletedDate: nil,
            reminderTime: nil,
            reminderEnabled: false,
            notes: nil
        ),
        Habit(
            id: UUID(),
            type: .reading,
            streakCount: 5,
            lastCompletedDate: nil,
            reminderTime: nil,
            reminderEnabled: false,
            notes: nil
        ),
        Habit(
            id: UUID(),
            type: .dailyWalk,
            streakCount: 2,
            lastCompletedDate: nil,
            reminderTime: nil,
            reminderEnabled: false,
            notes: nil
        ),
        Habit(
            id: UUID(),
            type: .screenOff,
            streakCount: 4,
            lastCompletedDate: nil,
            reminderTime: nil,
            reminderEnabled: false,
            notes: nil
        )
    ]
    
    for habit in sampleHabits {
        context.insert(habit)
    }
    
    // Mark some as completed for preview
    if sampleHabits.count >= 3 {
        let entry1 = HabitEntry(value: 30, isCompleted: true)
        entry1.habit = sampleHabits[0]
        context.insert(entry1)
        
        let entry2 = HabitEntry(value: 2, isCompleted: true)
        entry2.habit = sampleHabits[1]
        context.insert(entry2)
    }
    
    return HomeView()
        .modelContainer(container)
}

// MARK: - Dark Mode Preview
#Preview("Home View - Dark Mode") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Habit.self, HabitEntry.self, configurations: config)
    
    return HomeView()
        .modelContainer(container)
        .preferredColorScheme(.dark)
}
