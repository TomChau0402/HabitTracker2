import SwiftUI
import SwiftData
import Combine

struct HabitListView: View {
    @EnvironmentObject var viewModel: HabitViewModel
    @Environment(\.dismiss) var dismiss
    @Query private var habits: [Habit]
    @State private var showingForm = false
    @State private var selectedHabit: Habit?
    
    // Enhanced color scheme matching HomeView with darker tones
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
    
    private let cardBackground = Color(.systemGray6)
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Dark gradient background matching HomeView
                darkGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        // Enhanced Header Section
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Your Habits")
                                    .font(.title)
                                    .fontWeight(.heavy)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.white, teal.opacity(0.9)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                
                                HStack(spacing: 8) {
                                    // Total count pill
                                    HStack(spacing: 4) {
                                        Image(systemName: "square.stack.fill")
                                            .font(.caption2)
                                        Text("\(habits.count) total")
                                            .font(.caption)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Capsule())
                                    
                                    // Completed today pill
                                    HStack(spacing: 4) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.caption2)
                                            .foregroundColor(.green)
                                        Text("\(habits.filter { $0.isCompletedToday }.count) today")
                                            .font(.caption)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Capsule())
                                }
                                .foregroundColor(.white.opacity(0.9))
                            }
                            
                            Spacer()
                            
                            // Enhanced stats pill
                            let completionPercentage = habits.isEmpty ? 0 : Int((Double(habits.filter { $0.isCompletedToday }.count) / Double(habits.count)) * 100)
                            ZStack {
                                Circle()
                                    .stroke(deepBlue.opacity(0.3), lineWidth: 3)
                                    .frame(width: 60, height: 60)
                                
                                Circle()
                                    .trim(from: 0, to: CGFloat(completionPercentage) / 100)
                                    .stroke(
                                        primaryGradient,
                                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                                    )
                                    .frame(width: 60, height: 60)
                                    .rotationEffect(.degrees(-90))
                                
                                VStack(spacing: 0) {
                                    Text("\(completionPercentage)")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Text("%")
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // Habits List
                        ForEach(habits) { habit in
                            HabitRowView(habit: habit)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedHabit = habit
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
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
                                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                        .onDelete { indexSet in
                            withAnimation {
                                viewModel.deleteHabit(at: indexSet)
                            }
                        }
                        
                        // Empty state
                        if habits.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "square.stack.3d.up.slash")
                                    .font(.system(size: 60))
                                    .foregroundStyle(primaryGradient)
                                
                                Text("No habits yet")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("Tap the + button to create your first habit")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                                    .multilineTextAlignment(.center)
                                
                                Button(action: { showingForm = true }) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Create Habit")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(
                                        Capsule()
                                            .fill(primaryGradient)
                                            .overlay(
                                                Capsule()
                                                    .stroke(.white.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left.circle.fill")
                                .font(.title3)
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(primaryGradient)
                            Text("Back")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("All Habits")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, teal],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingForm = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(primaryGradient)
                                    .overlay(
                                        Circle()
                                            .stroke(.white.opacity(0.3), lineWidth: 2)
                                    )
                            )
                            .shadow(color: deepBlue.opacity(0.5), radius: 8, x: 0, y: 4)
                    }
                }
            }
            .sheet(isPresented: $showingForm) {
                HabitFormView()
                    .environmentObject(viewModel)
            }
            .sheet(item: $selectedHabit) { habit in
                HabitDetailView(habit: habit)
                    .environmentObject(viewModel)
            }
        }
    }
}

// MARK: - Preview Wrapper
#Preview("Habit List") {
    HabitListPreviewWrapper()
}

#Preview("Habit List - Dark Mode") {
    HabitListPreviewWrapper()
        .preferredColorScheme(.dark)
}

struct HabitListPreviewWrapper: View {
    let container: ModelContainer
    let viewModel: HabitViewModel
    
    init() {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try! ModelContainer(for: Habit.self, HabitEntry.self, configurations: config)
        
        // Add sample data
        let context = container.mainContext
        let sampleHabits = [
            Habit(
                id: UUID(),
                type: .focusedWork,
                streakCount: 7,
                lastCompletedDate: nil,
                reminderTime: Date(),
                reminderEnabled: true,
                notes: "Deep work sessions"
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
                reminderTime: Date(),
                reminderEnabled: true,
                notes: "Morning meditation"
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
            
            let entry3 = HabitEntry(value: 10, isCompleted: true)
            entry3.habit = sampleHabits[2]
            context.insert(entry3)
        }
        
        let vm = HabitViewModel()
        vm.modelContext = context
        self.viewModel = vm
    }
    
    var body: some View {
        HabitListView()
            .environmentObject(viewModel)
            .modelContainer(container)
    }
}
