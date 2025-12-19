//
//  AnalyticsChartsView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/19.
//

import SwiftUI
import Charts

/// Visual analytics and charts for deal analysis
struct AnalyticsChartsView: View {
    @Bindable var viewModel: DealViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedChart: ChartType = .cashFlow
    
    enum ChartType: String, CaseIterable {
        case cashFlow = "Cash Flow"
        case expenses = "Expenses"
        case equity = "Equity"
        case comparison = "Comparison"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Chart Picker
                    Picker("Chart", selection: $selectedChart) {
                        ForEach(ChartType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Chart Content
                    switch selectedChart {
                    case .cashFlow:
                        cashFlowChart
                    case .expenses:
                        expenseBreakdownChart
                    case .equity:
                        equityGrowthChart
                    case .comparison:
                        dealsComparisonChart
                    }
                }
                .padding()
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AppColors.primaryTeal)
                }
            }
        }
    }
    
    // MARK: - Cash Flow Chart
    
    private var cashFlowChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("MONTHLY CASH FLOW PROJECTION")
                .font(AppFonts.metricLabel)
                .foregroundColor(AppColors.textSecondary)
            
            let data = generateCashFlowData()
            
            Chart(data) { item in
                BarMark(
                    x: .value("Year", item.year),
                    y: .value("Cash Flow", item.value)
                )
                .foregroundStyle(item.value >= 0 ?
                    Color.green.gradient :
                    Color.red.gradient
                )
                .cornerRadius(4)
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let val = value.as(Double.self) {
                            Text(formatCompact(val))
                        }
                    }
                }
            }
            .frame(height: 250)
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(16)
            
            // Legend
            HStack(spacing: 20) {
                LegendItem(color: .green, label: "Positive")
                LegendItem(color: .red, label: "Negative")
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Expense Breakdown Chart
    
    private var expenseBreakdownChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("MONTHLY EXPENSE BREAKDOWN")
                .font(AppFonts.metricLabel)
                .foregroundColor(AppColors.textSecondary)
            
            let expenses = generateExpenseData()
            
            Chart(expenses) { item in
                SectorMark(
                    angle: .value("Amount", item.value),
                    innerRadius: .ratio(0.5),
                    angularInset: 1.5
                )
                .foregroundStyle(by: .value("Category", item.category))
                .cornerRadius(4)
            }
            .chartLegend(position: .bottom, spacing: 10)
            .frame(height: 300)
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(16)
            
            // Expense Details
            VStack(spacing: 8) {
                ForEach(expenses) { item in
                    HStack {
                        Circle()
                            .fill(item.color)
                            .frame(width: 12, height: 12)
                        
                        Text(item.category)
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Spacer()
                        
                        Text(formatCurrency(item.value))
                            .font(AppFonts.bodyBold)
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(16)
        }
    }
    
    // MARK: - Equity Growth Chart
    
    private var equityGrowthChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("5-YEAR EQUITY GROWTH")
                .font(AppFonts.metricLabel)
                .foregroundColor(AppColors.textSecondary)
            
            let data = generateEquityData()
            
            Chart(data) { item in
                LineMark(
                    x: .value("Year", item.year),
                    y: .value("Equity", item.equity)
                )
                .foregroundStyle(Color.green.gradient)
                .interpolationMethod(.catmullRom)
                
                AreaMark(
                    x: .value("Year", item.year),
                    y: .value("Equity", item.equity)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.green.opacity(0.3), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
                
                PointMark(
                    x: .value("Year", item.year),
                    y: .value("Equity", item.equity)
                )
                .foregroundStyle(Color.green)
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let val = value.as(Double.self) {
                            Text(formatCompact(val))
                        }
                    }
                }
            }
            .frame(height: 250)
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(16)
            
            // Summary
            let finalEquity = data.last?.equity ?? 0
            let initialEquity = data.first?.equity ?? 0
            let growth = finalEquity - initialEquity
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Equity Growth")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textMuted)
                    Text(formatCurrency(growth))
                        .font(AppFonts.title2)
                        .foregroundColor(AppColors.successGreen)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Year 5 Equity")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textMuted)
                    Text(formatCurrency(finalEquity))
                        .font(AppFonts.title2)
                        .foregroundColor(AppColors.primaryTeal)
                }
            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(16)
        }
    }
    
    // MARK: - Deals Comparison Chart
    
    private var dealsComparisonChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("DEAL COMPARISON")
                .font(AppFonts.metricLabel)
                .foregroundColor(AppColors.textSecondary)
            
            if viewModel.savedDeals.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 40))
                        .foregroundColor(AppColors.textMuted)
                    
                    Text("Save deals to compare them")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(40)
                .background(AppColors.cardBackground)
                .cornerRadius(16)
            } else {
                let comparisonData = generateComparisonData()
                
                Chart(comparisonData) { item in
                    BarMark(
                        x: .value("Deal", item.name),
                        y: .value("Value", item.cashOnCash)
                    )
                    .foregroundStyle(Color.blue.gradient)
                    .cornerRadius(4)
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let val = value.as(Double.self) {
                                Text(String(format: "%.0f%%", val))
                            }
                        }
                    }
                }
                .frame(height: 250)
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(16)
            }
        }
    }
    
    // MARK: - Data Generation
    
    private func generateCashFlowData() -> [ChartDataPoint] {
        let baseCashFlow = viewModel.deal.monthlyRent - 
            viewModel.deal.monthlyInsurance -
            (viewModel.deal.annualPropertyTax / 12) -
            viewModel.deal.monthlyHOA
        
        return (1...5).map { year in
            let adjustment = pow(1.03, Double(year - 1)) // 3% rent growth
            return ChartDataPoint(
                year: "Year \(year)",
                value: baseCashFlow * adjustment * 12
            )
        }
    }
    
    private func generateExpenseData() -> [ExpenseDataPoint] {
        let deal = viewModel.deal
        return [
            ExpenseDataPoint(category: "Mortgage", value: calculateMortgage(), color: .blue),
            ExpenseDataPoint(category: "Property Tax", value: deal.annualPropertyTax / 12, color: .red),
            ExpenseDataPoint(category: "Insurance", value: deal.monthlyInsurance, color: .orange),
            ExpenseDataPoint(category: "HOA", value: deal.monthlyHOA, color: .purple),
            ExpenseDataPoint(category: "Maintenance", value: deal.purchasePrice * (deal.maintenancePercent / 100) / 12, color: .green),
            ExpenseDataPoint(category: "Other", value: deal.otherMonthlyExpenses, color: .gray)
        ].filter { $0.value > 0 }
    }
    
    private func generateEquityData() -> [EquityDataPoint] {
        let downPayment = viewModel.deal.purchasePrice * (viewModel.deal.downPaymentPercent / 100)
        let appreciation = viewModel.deal.appreciationRatePercent / 100
        
        return (0...5).map { year in
            let propertyValue = viewModel.deal.purchasePrice * pow(1 + appreciation, Double(year))
            let loanBalance = calculateLoanBalance(year: year)
            let equity = propertyValue - loanBalance
            return EquityDataPoint(year: "Year \(year)", equity: max(equity, downPayment))
        }
    }
    
    private func generateComparisonData() -> [ComparisonDataPoint] {
        return Array(viewModel.savedDeals.prefix(5)).map { deal in
            let cashFlow = deal.monthlyRent - deal.monthlyInsurance - (deal.annualPropertyTax / 12)
            let invested = deal.purchasePrice * (deal.downPaymentPercent / 100)
            let coc = invested > 0 ? (cashFlow * 12 / invested) * 100 : 0
            return ComparisonDataPoint(
                name: deal.name.isEmpty ? "Deal" : String(deal.name.prefix(10)),
                cashOnCash: coc
            )
        }
    }
    
    private func calculateMortgage() -> Double {
        let deal = viewModel.deal
        let loanAmount = deal.purchasePrice * (1 - deal.downPaymentPercent / 100)
        let monthlyRate = (deal.interestRate / 100) / 12
        let payments = Double(deal.loanTermYears * 12)
        
        guard monthlyRate > 0, payments > 0 else { return 0 }
        
        return loanAmount * (monthlyRate * pow(1 + monthlyRate, payments)) /
               (pow(1 + monthlyRate, payments) - 1)
    }
    
    private func calculateLoanBalance(year: Int) -> Double {
        let deal = viewModel.deal
        let loanAmount = deal.purchasePrice * (1 - deal.downPaymentPercent / 100)
        let monthlyRate = (deal.interestRate / 100) / 12
        let totalPayments = Double(deal.loanTermYears * 12)
        let paymentsMade = Double(year * 12)
        
        guard monthlyRate > 0, totalPayments > 0 else { return loanAmount }
        
        let balance = loanAmount * (pow(1 + monthlyRate, totalPayments) - pow(1 + monthlyRate, paymentsMade)) /
                     (pow(1 + monthlyRate, totalPayments) - 1)
        return max(balance, 0)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
    
    private func formatCompact(_ value: Double) -> String {
        if abs(value) >= 1000 {
            return String(format: "$%.0fK", value / 1000)
        }
        return String(format: "$%.0f", value)
    }
}

// MARK: - Data Models

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let year: String
    let value: Double
}

struct ExpenseDataPoint: Identifiable {
    let id = UUID()
    let category: String
    let value: Double
    let color: Color
}

struct EquityDataPoint: Identifiable {
    let id = UUID()
    let year: String
    let equity: Double
}

struct ComparisonDataPoint: Identifiable {
    let id = UUID()
    let name: String
    let cashOnCash: Double
}

// MARK: - Legend Item

struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)
        }
    }
}

#Preview {
    AnalyticsChartsView(viewModel: {
        let vm = DealViewModel()
        vm.deal = .sampleDeal
        return vm
    }())
}
