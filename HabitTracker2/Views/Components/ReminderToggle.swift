//
//  ReminderToggle.swift
//  HabitTracker2
//
import SwiftUI

struct ReminderToggle: View {
    @Binding var isEnabled: Bool
    @Binding var reminderTime: Date
    var onToggle: ((Bool) -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: $isEnabled) {
                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.blue)
                    Text("Enable Reminder")
                        .font(.headline)
                }
            }
            .onChange(of: isEnabled) { newValue in
                onToggle?(newValue)
            }
            
            if isEnabled {
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(.compact)
                    
                    Spacer()
                }
                .padding(.leading, 4)
                .transition(.opacity.combined(with: .slide))
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview("Reminder Toggle - Disabled") {
    @Previewable @State var isEnabled = false
    @Previewable @State var reminderTime = Date()
    
    return ReminderToggle(isEnabled: $isEnabled, reminderTime: $reminderTime)
        .padding()
        .previewLayout(.sizeThatFits)
}

#Preview("Reminder Toggle - Enabled") {
    @Previewable @State var isEnabled = true
    @Previewable @State var reminderTime = Date()
    
    return ReminderToggle(isEnabled: $isEnabled, reminderTime: $reminderTime)
        .padding()
        .previewLayout(.sizeThatFits)
}

#Preview("Reminder Toggle - With Callback") {
    @Previewable @State var isEnabled = false
    @Previewable @State var reminderTime = Date()
    
    return ReminderToggle(
        isEnabled: $isEnabled,
        reminderTime: $reminderTime,
        onToggle: { newValue in
            print("Reminder toggled: \(newValue)")
        }
    )
    .padding()
    .previewLayout(.sizeThatFits)
}

#Preview("Reminder Toggle - Multiple States") {
    VStack(spacing: 20) {
        ReminderToggle(isEnabled: .constant(false), reminderTime: .constant(Date()))
        ReminderToggle(isEnabled: .constant(true), reminderTime: .constant(Date()))
    }
    .padding()
    .previewLayout(.sizeThatFits)
}
