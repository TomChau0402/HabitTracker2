//
//  ReminderToggle.swift
//  HabitTracker2
//
import SwiftUI

struct ReminderToggle: View {
    @Binding var isEnabled: Bool
    @Binding var reminderTime: Date
    var onToggle: ((Bool) -> Void)?
    
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Enhanced Toggle
            Toggle(isOn: $isEnabled.animation(.spring(response: 0.3, dampingFraction: 0.7))) {
                HStack(spacing: 12) {
                    // Icon with gradient background
                    ZStack {
                        Circle()
                            .fill(isEnabled ? deepBlue.opacity(0.2) : Color.gray.opacity(0.1))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 16))
                            .foregroundColor(isEnabled ? teal : .gray)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Enable Reminder")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("Get notified daily")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: teal)) // Changed from primaryGradient to teal
            .onChange(of: isEnabled) { newValue in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    onToggle?(newValue)
                }
            }
            .padding(.horizontal, 4)
            
            // Time picker section (when enabled)
            if isEnabled {
                VStack(alignment: .leading, spacing: 12) {
                    // Divider with gradient
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [deepBlue.opacity(0.3), teal.opacity(0.3), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 1)
                        .padding(.vertical, 4)
                    
                    HStack(spacing: 16) {
                        // Time icon with glow
                        ZStack {
                            Circle()
                                .fill(deepBlue.opacity(0.2))
                                .frame(width: 40, height: 40)
                                .blur(radius: 8)
                            
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 40, height: 40)
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
                            
                            Image(systemName: "clock.fill")
                                .font(.system(size: 16))
                                .foregroundColor(teal)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Reminder Time")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            
                            DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .datePickerStyle(.compact)
                                .colorScheme(.dark)
                                .accentColor(teal)
                        }
                        
                        Spacer()
                        
                        // Time display pill
                        Text(reminderTime, style: .time)
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(teal)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        Capsule()
                                            .stroke(teal.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                }
                .padding(.top, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
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
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Previews with proper background
#Preview("Reminder Toggle - Disabled") {
    @Previewable @State var isEnabled = false
    @Previewable @State var reminderTime = Date()
    
    ZStack {
        // Dark gradient background matching HomeView
        LinearGradient(
            colors: [Color.black.opacity(0.8), Color(red: 0.1, green: 0.2, blue: 0.5)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        
        ReminderToggle(isEnabled: $isEnabled, reminderTime: $reminderTime)
            .padding()
    }
    .previewLayout(.sizeThatFits)
}

#Preview("Reminder Toggle - Enabled") {
    @Previewable @State var isEnabled = true
    @Previewable @State var reminderTime = {
        let date = Date()
        let calendar = Calendar.current
        return calendar.date(bySettingHour: 9, minute: 0, second: 0, of: date) ?? date
    }()
    
    ZStack {
        LinearGradient(
            colors: [Color.black.opacity(0.8), Color(red: 0.1, green: 0.2, blue: 0.5)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        
        ReminderToggle(isEnabled: $isEnabled, reminderTime: $reminderTime)
            .padding()
    }
    .previewLayout(.sizeThatFits)
}

#Preview("Reminder Toggle - With Callback") {
    @Previewable @State var isEnabled = false
    @Previewable @State var reminderTime = Date()
    
    ZStack {
        LinearGradient(
            colors: [Color.black.opacity(0.8), Color(red: 0.1, green: 0.2, blue: 0.5)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        
        ReminderToggle(
            isEnabled: $isEnabled,
            reminderTime: $reminderTime,
            onToggle: { newValue in
                print("Reminder toggled: \(newValue)")
            }
        )
        .padding()
    }
    .previewLayout(.sizeThatFits)
}

#Preview("Reminder Toggle - Multiple States") {
    ZStack {
        LinearGradient(
            colors: [Color.black.opacity(0.8), Color(red: 0.1, green: 0.2, blue: 0.5)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        
        VStack(spacing: 20) {
            ReminderToggle(isEnabled: .constant(false), reminderTime: .constant(Date()))
            ReminderToggle(isEnabled: .constant(true), reminderTime: .constant(Date()))
        }
        .padding()
    }
    .previewLayout(.sizeThatFits)
}

// MARK: - Dark Mode Preview
#Preview("Reminder Toggle - Dark Mode") {
    @Previewable @State var isEnabled = true
    @Previewable @State var reminderTime = Date()
    
    ZStack {
        LinearGradient(
            colors: [Color.black.opacity(0.8), Color(red: 0.1, green: 0.2, blue: 0.5)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        
        ReminderToggle(isEnabled: $isEnabled, reminderTime: $reminderTime)
            .padding()
    }
    .preferredColorScheme(.dark)
    .previewLayout(.sizeThatFits)
}
