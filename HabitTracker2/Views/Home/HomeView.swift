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
    
    // Enhanced color scheme with darker tones - FIXED: Removed 'default' parameter
    private let deepBlue = Color(red: 0.2, green: 0.4, blue: 0.9)
    private let teal = Color(red: 0.1, green: 0.7, blue: 0.8)
    private let darkBlue = Color(red: 0.1, green: 0.2, blue: 0.5)
    
    private let primaryGradient = LinearGradient(
        colors: [Color(red: 0.2, green: 0.4, blue: 0.9),
                 Color(red: 0.1, green: 0.7, blue: 0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    private let darkGradient = LinearGradient(
        colors: [Color.black.opacity(0.8), Color(red: 0.1, green: 0.2, blue: 0.5)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    private let accentColor = Color(red: 0.2, green: 0.4, blue: 0.9)
    private let cardBackground = Color(.systemGray6)
    private let darkCardBackground = Color(.systemGray5).opacity(0.9)
    private let secondaryText = Color.secondary
    
    init() {
        _viewModel = StateObject(wrappedValue: HabitViewModel())
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Dark gradient background
                darkGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header with enhanced styling
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Today's Progress")
                                    .font(.system(size: 34, weight: .heavy))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.white, teal.opacity(0.9)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                
                                HStack(spacing: 12) {
                                    // Date pill
                                    HStack(spacing: 6) {
                                        Image(systemName: "calendar")
                                            .font(.caption)
                                            .foregroundColor(.cyan)
                                        Text(formattedDate)
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Capsule())
                                    
                                    // Streak summary
                                    let totalStreak = habits.reduce(0) { $0 + $1.streakCount }
                                    HStack(spacing: 4) {
                                        Image(systemName: "flame.fill")
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                        Text("\(totalStreak)")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.orange)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Capsule())
                                }
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 16) {
                                // List button with enhanced design
                                Button(action: { showingList = true }) {
                                    Image(systemName: "list.bullet.rectangle")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .frame(width: 50, height: 50)
                                        .background(
                                            Circle()
                                                .fill(.ultraThinMaterial)
                                                .overlay(
                                                    Circle()
                                                        .stroke(
                                                            LinearGradient(
                                                                colors: [.white.opacity(0.5), .cyan.opacity(0.5)],
                                                                startPoint: .topLeading,
                                                                endPoint: .bottomTrailing
                                                            ),
                                                            lineWidth: 1
                                                        )
                                                )
                                        )
                                        .shadow(color: .cyan.opacity(0.3), radius: 8, x: 0, y: 4)
                                }
                                
                                // Add button with enhanced design
                                Button(action: { showingForm = true }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .frame(width: 50, height: 50)
                                        .background(
                                            Circle()
                                                .fill(primaryGradient)
                                                .overlay(
                                                    Circle()
                                                        .stroke(.white.opacity(0.3), lineWidth: 2)
                                                )
                                        )
                                        .shadow(color: .blue.opacity(0.5), radius: 10, x: 0, y: 5)
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
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    } icon: {
                                        Image(systemName: "flame.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.orange)
                                            .symbolEffect(.bounce, options: .repeating)
                                    }
                                    
                                    Spacer()
                                    
                                    // Today's completion badge
                                    let completedCount = habits.filter { $0.isCompletedToday }.count
                                    Text("\(completedCount)/\(habits.count) today")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(.ultraThinMaterial)
                                                .overlay(
                                                    Capsule()
                                                        .stroke(
                                                            LinearGradient(
                                                                colors: [.cyan.opacity(0.5), .blue.opacity(0.5)],
                                                                startPoint: .leading,
                                                                endPoint: .trailing
                                                            ),
                                                            lineWidth: 1
                                                        )
                                                )
                                        )
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        ForEach(habits) { habit in
                                            StreakCard(habit: habit)
                                                .environmentObject(viewModel)
                                                .onTapGesture {
                                                    withAnimation(.spring(response: 0.3)) {
                                                        selectedHabit = habit
                                                    }
                                                }
                                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.bottom, 8)
                                }
                            }
                        }
                        
                        // Today's Progress Card
                        TodayProgressView(habits: habits)
                            .environmentObject(viewModel)
                            .padding(.horizontal)
                            .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
                        
                        // Quick Actions Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Label {
                                    Text("Quick Actions")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                } icon: {
                                    Image(systemName: "bolt.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.yellow)
                                        .symbolEffect(.pulse)
                                }
                                
                                Spacer()
                                
                                Text("Tap to track")
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Capsule())
                                    .foregroundColor(.white.opacity(0.8))
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
                                        .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Motivational Quote
                        if habits.filter({ $0.isCompletedToday }).count == habits.count && !habits.isEmpty {
                            HStack {
                                Image(systemName: "star.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.yellow)
                                
                                Text("Perfect day! You've completed all habits! 🎉")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Image(systemName: "star.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.yellow)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [.yellow.opacity(0.5), .orange.opacity(0.5)],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ),
                                                lineWidth: 2
                                            )
                                    )
                            )
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
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
            viewModel.modelContext = modelContext
            viewModel.createDefaultHabitsIfNeeded()
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }
}

struct QuickActionButton: View {
    let habit: Habit
    let viewModel: HabitViewModel
    
    // Enhanced colors
    private let completedGradient = LinearGradient(
        colors: [Color.green, Color.mint],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    private let incompleteGradient = LinearGradient(
        colors: [Color.blue, Color.cyan],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                viewModel.toggleHabitCompletion(habit)
            }
        }) {
            VStack(spacing: 14) {
                // Icon with enhanced background
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(habit.isCompletedToday ? Color.green.opacity(0.3) : Color.blue.opacity(0.3))
                        .frame(width: 70, height: 70)
                        .blur(radius: 12)
                    
                    // Main icon background
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: habit.isCompletedToday ?
                                    [.green.opacity(0.3), .mint.opacity(0.3)] :
                                    [.blue.opacity(0.3), .cyan.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .overlay(
                            Circle()
                                .stroke(
                                    habit.isCompletedToday ?
                                        Color.green.opacity(0.6) :
                                        Color.blue.opacity(0.6),
                                    lineWidth: 2
                                )
                        )
                    
                    Image(systemName: habit.type.icon)
                        .font(.title2)
                        .foregroundColor(habit.isCompletedToday ? .green : .blue)
                        .scaleEffect(habit.isCompletedToday ? 1.2 : 1.0)
                }
                
                Text(habit.type.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .foregroundColor(.white)
                
                // Target value with enhanced styling
                HStack(spacing: 4) {
                    Image(systemName: "target")
                        .font(.system(size: 8))
                    Text(habit.type.targetDisplayValue)
                        .font(.system(size: 10, weight: .medium))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(habit.isCompletedToday ? Color.green.opacity(0.2) : Color.blue.opacity(0.2))
                        .overlay(
                            Capsule()
                                .stroke(
                                    habit.isCompletedToday ?
                                        Color.green.opacity(0.4) :
                                        Color.blue.opacity(0.4),
                                    lineWidth: 1
                                )
                        )
                )
                .foregroundColor(habit.isCompletedToday ? .green : .cyan)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                habit.isCompletedToday ?
                                    completedGradient.opacity(0.5) :
                                    incompleteGradient.opacity(0.5),
                                lineWidth: 2
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
        )
    ]
    
    for habit in sampleHabits {
        context.insert(habit)
    }
    
    // Mark some as completed for preview
    if sampleHabits.count >= 2 {
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

// MARK: - Light Mode Preview
#Preview("Home View - Light") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Habit.self, HabitEntry.self, configurations: config)
    
    return HomeView()
        .modelContainer(container)
        .preferredColorScheme(.light)
}
