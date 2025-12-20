//
//  ExpenseTrackerView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/19.
//

import SwiftUI

/// Monthly expense tracker for rental properties
struct ExpenseTrackerView: View {
    @Bindable var viewModel: DealViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var expenses: [TrackedExpense] = []
    @State private var showingAddExpense: Bool = false
    @State private var selectedMonth: Date = Date()
    
    var monthlyTotal: Double {
        expenses
            .filter { Calendar.current.isDate($0.date, equalTo: selectedMonth, toGranularity: .month) }
            .reduce(0) { $0 + $1.amount }
    }
    
    var expensesByCategory: [(category: ExpenseCategory, total: Double)] {
        let currentMonthExpenses = expenses.filter {
            Calendar.current.isDate($0.date, equalTo: selectedMonth, toGranularity: .month)
        }
        
        return ExpenseCategory.allCases.compactMap { category in
            let total = currentMonthExpenses.filter { $0.category == category }.reduce(0) { $0 + $1.amount }
            return total > 0 ? (category, total) : nil
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Month Selector
                monthSelector
                
                // Total Display
                VStack(spacing: 8) {
                    Text("MONTHLY EXPENSES")
                        .font(AppFonts.metricLabel)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text(formatCurrency(monthlyTotal))
                        .font(AppFonts.cashFlowDisplay)
                        .foregroundColor(AppColors.dangerRed)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(AppColors.cardBackground)
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Category Breakdown
                        if !expensesByCategory.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("BY CATEGORY")
                                    .font(AppFonts.metricLabel)
                                    .foregroundColor(AppColors.textSecondary)
                                
                                ForEach(expensesByCategory, id: \.category) { item in
                                    ExpenseCategoryRow(
                                        category: item.category,
                                        amount: item.total,
                                        percentage: monthlyTotal > 0 ? item.total / monthlyTotal : 0
                                    )
                                }
                            }
                            .padding()
                            .background(AppColors.cardBackground)
                            .cornerRadius(16)
                        }
                        
                        // Expense List
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("TRANSACTIONS")
                                    .font(AppFonts.metricLabel)
                                    .foregroundColor(AppColors.textSecondary)
                                
                                Spacer()
                                
                                Button(action: { showingAddExpense = true }) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(AppColors.primaryTeal)
                                }
                            }
                            
                            let monthExpenses = expenses.filter {
                                Calendar.current.isDate($0.date, equalTo: selectedMonth, toGranularity: .month)
                            }.sorted { $0.date > $1.date }
                            
                            if monthExpenses.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "receipt")
                                        .font(.system(size: 40))
                                        .foregroundColor(AppColors.textMuted)
                                    
                                    Text("No expenses this month")
                                        .font(AppFonts.body)
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(30)
                            } else {
                                ForEach(monthExpenses) { expense in
                                    ExpenseRow(expense: expense) {
                                        if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
                                            expenses.remove(at: index)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(AppColors.cardBackground)
                        .cornerRadius(16)
                    }
                    .padding()
                }
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Expense Tracker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AppColors.primaryTeal)
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseSheet(expenses: $expenses)
            }
        }
    }
    
    private var monthSelector: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .foregroundColor(AppColors.primaryTeal)
            }
            
            Spacer()
            
            Text(monthYearFormatter.string(from: selectedMonth))
                .font(AppFonts.bodyBold)
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .foregroundColor(AppColors.primaryTeal)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
    }
    
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    
    private func previousMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) {
            selectedMonth = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) {
            selectedMonth = newDate
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        return CurrencyFormatter.format(value)
    }
}

// MARK: - Expense Models

struct TrackedExpense: Identifiable, Codable {
    let id: UUID
    var description: String
    var amount: Double
    var category: ExpenseCategory
    var date: Date
    var propertyId: UUID?
    
    init(description: String, amount: Double, category: ExpenseCategory, date: Date = Date(), propertyId: UUID? = nil) {
        self.id = UUID()
        self.description = description
        self.amount = amount
        self.category = category
        self.date = date
        self.propertyId = propertyId
    }
}

enum ExpenseCategory: String, CaseIterable, Codable {
    case mortgage = "Mortgage"
    case propertyTax = "Property Tax"
    case insurance = "Insurance"
    case utilities = "Utilities"
    case maintenance = "Maintenance"
    case repairs = "Repairs"
    case management = "Management"
    case hoa = "HOA"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .mortgage: return "house.fill"
        case .propertyTax: return "building.columns.fill"
        case .insurance: return "shield.fill"
        case .utilities: return "bolt.fill"
        case .maintenance: return "wrench.fill"
        case .repairs: return "hammer.fill"
        case .management: return "person.fill"
        case .hoa: return "building.2.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .mortgage: return .blue
        case .propertyTax: return .red
        case .insurance: return .orange
        case .utilities: return .yellow
        case .maintenance: return .green
        case .repairs: return .purple
        case .management: return .pink
        case .hoa: return .indigo
        case .other: return .gray
        }
    }
}

// MARK: - Expense Category Row

struct ExpenseCategoryRow: View {
    let category: ExpenseCategory
    let amount: Double
    let percentage: Double
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category.icon)
                .foregroundColor(category.color)
                .frame(width: 24)
            
            Text(category.rawValue)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            Text(formatCurrency(amount))
                .font(AppFonts.bodyBold)
                .foregroundColor(AppColors.textPrimary)
            
            Text(String(format: "%.0f%%", percentage * 100))
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textMuted)
                .frame(width: 40, alignment: .trailing)
        }
        .padding(.vertical, 4)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        return CurrencyFormatter.format(value)
    }
}

// MARK: - Expense Row

struct ExpenseRow: View {
    let expense: TrackedExpense
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: expense.category.icon)
                .foregroundColor(expense.category.color)
                .frame(width: 32, height: 32)
                .background(expense.category.color.opacity(0.15))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(expense.description)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(formatDate(expense.date))
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)
            }
            
            Spacer()
            
            Text(formatCurrency(expense.amount))
                .font(AppFonts.bodyBold)
                .foregroundColor(AppColors.dangerRed)
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(AppColors.textMuted)
            }
        }
        .padding()
        .background(AppColors.inputBackground)
        .cornerRadius(12)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        return CurrencyFormatter.format(value)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Add Expense Sheet

struct AddExpenseSheet: View {
    @Binding var expenses: [TrackedExpense]
    @Environment(\.dismiss) private var dismiss
    
    @State private var description: String = ""
    @State private var amount: Double = 0
    @State private var category: ExpenseCategory = .other
    @State private var date: Date = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Description", text: $description)
                    
                    CurrencyTextField(
                        title: "Amount",
                        value: $amount,
                        placeholder: "0"
                    )
                    
                    Picker("Category", selection: $category) {
                        ForEach(ExpenseCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon)
                                .tag(cat)
                        }
                    }
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppColors.background)
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { addExpense() }
                        .disabled(description.isEmpty || amount <= 0)
                }
            }
        }
    }
    
    private func addExpense() {
        let expense = TrackedExpense(
            description: description,
            amount: amount,
            category: category,
            date: date
        )
        expenses.append(expense)
        dismiss()
    }
}

#Preview {
    ExpenseTrackerView(viewModel: DealViewModel())
}
