//
//  RemindersView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/19.
//

import SwiftUI

/// Reminders and notifications management view
struct RemindersView: View {
    @Bindable var viewModel: DealViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var reminders: [PropertyReminder] = []
    @State private var showingAddReminder: Bool = false
    @State private var notificationsEnabled: Bool = false
    
    var upcomingReminders: [PropertyReminder] {
        reminders
            .filter { $0.date > Date() && !$0.isCompleted }
            .sorted { $0.date < $1.date }
    }
    
    var completedReminders: [PropertyReminder] {
        reminders.filter { $0.isCompleted }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Notification Permission
                    if !notificationsEnabled {
                        notificationPermissionCard
                    }
                    
                    // Quick Add
                    VStack(alignment: .leading, spacing: 12) {
                        Text("QUICK ADD")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(ReminderType.allCases.prefix(4), id: \.self) { type in
                                QuickReminderButton(type: type) {
                                    addQuickReminder(type)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Upcoming
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("UPCOMING")
                                .font(AppFonts.metricLabel)
                                .foregroundColor(AppColors.textSecondary)
                            
                            Spacer()
                            
                            Button(action: { showingAddReminder = true }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(AppColors.primaryTeal)
                            }
                        }
                        
                        if upcomingReminders.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "bell.badge")
                                    .font(.system(size: 40))
                                    .foregroundColor(AppColors.textMuted)
                                
                                Text("No upcoming reminders")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(30)
                        } else {
                            ForEach(upcomingReminders) { reminder in
                                ReminderRow(reminder: reminder) {
                                    toggleComplete(reminder)
                                } onDelete: {
                                    deleteReminder(reminder)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Completed
                    if !completedReminders.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("COMPLETED")
                                .font(AppFonts.metricLabel)
                                .foregroundColor(AppColors.textSecondary)
                            
                            ForEach(completedReminders.prefix(5)) { reminder in
                                ReminderRow(reminder: reminder) {
                                    toggleComplete(reminder)
                                } onDelete: {
                                    deleteReminder(reminder)
                                }
                            }
                        }
                        .padding()
                        .background(AppColors.cardBackground)
                        .cornerRadius(16)
                    }
                }
                .padding()
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Reminders")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AppColors.primaryTeal)
                }
            }
            .sheet(isPresented: $showingAddReminder) {
                AddReminderSheet(reminders: $reminders, dealName: viewModel.deal.name)
            }
            .onAppear {
                checkNotificationPermission()
            }
        }
    }
    
    private var notificationPermissionCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 40))
                .foregroundColor(AppColors.warningAmber)
            
            Text("Enable Notifications")
                .font(AppFonts.title2)
                .foregroundColor(AppColors.textPrimary)
            
            Text("Get reminders for due diligence, rent collection, and more")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
            
            Button(action: requestNotifications) {
                Text("Enable")
                    .font(AppFonts.bodyBold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(AppColors.primaryTeal)
                    .cornerRadius(25)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
    
    private func checkNotificationPermission() {
        NotificationManager.shared.checkAuthorizationStatus()
        notificationsEnabled = NotificationManager.shared.isAuthorized
    }
    
    private func requestNotifications() {
        Task {
            let granted = await NotificationManager.shared.requestAuthorization()
            await MainActor.run {
                notificationsEnabled = granted
            }
        }
    }
    
    private func addQuickReminder(_ type: ReminderType) {
        let reminder = PropertyReminder(
            title: type.rawValue,
            type: type,
            date: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
            dealName: viewModel.deal.name
        )
        reminders.append(reminder)
    }
    
    private func toggleComplete(_ reminder: PropertyReminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index].isCompleted.toggle()
        }
    }
    
    private func deleteReminder(_ reminder: PropertyReminder) {
        reminders.removeAll { $0.id == reminder.id }
    }
}

// MARK: - Property Reminder Model

struct PropertyReminder: Identifiable, Codable {
    let id: UUID
    var title: String
    var type: ReminderType
    var date: Date
    var dealName: String
    var isCompleted: Bool
    var notes: String
    
    init(title: String, type: ReminderType, date: Date, dealName: String = "", notes: String = "") {
        self.id = UUID()
        self.title = title
        self.type = type
        self.date = date
        self.dealName = dealName
        self.isCompleted = false
        self.notes = notes
    }
}

// MARK: - Quick Reminder Button

struct QuickReminderButton: View {
    let type: ReminderType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.system(size: 24))
                    .foregroundColor(type.color)
                
                Text(type.rawValue)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(type.color.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

// MARK: - Reminder Row

struct ReminderRow: View {
    let reminder: PropertyReminder
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    var daysUntil: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: reminder.date).day ?? 0
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(reminder.isCompleted ? AppColors.successGreen : AppColors.textMuted)
            }
            
            Image(systemName: reminder.type.icon)
                .foregroundColor(reminder.type.color)
                .frame(width: 32, height: 32)
                .background(reminder.type.color.opacity(0.15))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(reminder.title)
                    .font(AppFonts.body)
                    .foregroundColor(reminder.isCompleted ? AppColors.textMuted : AppColors.textPrimary)
                    .strikethrough(reminder.isCompleted)
                
                Text(formatDate(reminder.date))
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)
            }
            
            Spacer()
            
            if !reminder.isCompleted {
                Text(daysUntilText)
                    .font(AppFonts.caption)
                    .foregroundColor(daysUntil <= 1 ? AppColors.dangerRed : AppColors.textMuted)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(daysUntil <= 1 ? AppColors.dangerRed.opacity(0.1) : AppColors.inputBackground)
                    .cornerRadius(6)
            }
            
            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textMuted)
            }
        }
        .padding()
        .background(AppColors.inputBackground)
        .cornerRadius(12)
    }
    
    private var daysUntilText: String {
        if daysUntil < 0 { return "Overdue" }
        if daysUntil == 0 { return "Today" }
        if daysUntil == 1 { return "Tomorrow" }
        return "\(daysUntil) days"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Add Reminder Sheet

struct AddReminderSheet: View {
    @Binding var reminders: [PropertyReminder]
    let dealName: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var type: ReminderType = .dueDiligence
    @State private var date: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
    @State private var notes: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Reminder") {
                    TextField("Title", text: $title)
                    
                    Picker("Type", selection: $type) {
                        ForEach(ReminderType.allCases, id: \.self) { t in
                            Label(t.rawValue, systemImage: t.icon)
                                .tag(t)
                        }
                    }
                    
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppColors.background)
            .navigationTitle("Add Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { addReminder() }
                        .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func addReminder() {
        let reminder = PropertyReminder(
            title: title,
            type: type,
            date: date,
            dealName: dealName,
            notes: notes
        )
        reminders.append(reminder)
        
        // Schedule notification
        NotificationManager.shared.scheduleDueDiligenceReminder(
            dealName: dealName.isEmpty ? "Property" : dealName,
            task: title,
            dueDate: date,
            identifier: reminder.id.uuidString
        )
        
        dismiss()
    }
}

#Preview {
    RemindersView(viewModel: DealViewModel())
}
