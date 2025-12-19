//
//  AmortizationView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/18.
//

import SwiftUI

/// Loan amortization schedule viewer
struct AmortizationView: View {
    @Bindable var viewModel: DealViewModel
    @Environment(\.dismiss) private var dismiss
    
    var schedule: [AmortizationEntry] {
        CalculationService.generateAmortizationSchedule(for: viewModel.deal)
    }
    
    var totalInterestPaid: Double {
        schedule.last?.totalInterestPaid ?? 0
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Summary Header
                    VStack(spacing: 16) {
                        HStack {
                            SummaryBox(
                                title: "Monthly Payment",
                                value: formatCurrency(viewModel.results.monthlyMortgagePayment),
                                color: AppColors.primaryTeal
                            )
                            
                            SummaryBox(
                                title: "Loan Amount",
                                value: formatCurrency(viewModel.deal.loanAmount),
                                color: AppColors.textSecondary
                            )
                        }
                        
                        HStack {
                            SummaryBox(
                                title: "Total Interest",
                                value: formatCurrency(totalInterestPaid),
                                color: AppColors.dangerRed
                            )
                            
                            SummaryBox(
                                title: "Loan Term",
                                value: "\(viewModel.deal.loanTermYears) Years",
                                color: AppColors.textSecondary
                            )
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Payoff Progress
                    PayoffProgressCard(
                        loanAmount: viewModel.deal.loanAmount,
                        monthlyPayment: viewModel.results.monthlyMortgagePayment,
                        interestRate: viewModel.deal.interestRate
                    )
                    
                    // Schedule Table
                    VStack(alignment: .leading, spacing: 12) {
                        Text("YEARLY BREAKDOWN")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        // Table Header
                        HStack {
                            Text("Year")
                                .frame(width: 50, alignment: .leading)
                            Text("Principal")
                                .frame(maxWidth: .infinity)
                            Text("Interest")
                                .frame(maxWidth: .infinity)
                            Text("Balance")
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .font(AppFonts.caption2)
                        .foregroundColor(AppColors.textMuted)
                        .padding(.horizontal, 12)
                        
                        Divider().background(AppColors.divider)
                        
                        ForEach(schedule.prefix(30)) { entry in
                            AmortizationRow(entry: entry)
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                }
                .padding()
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Amortization")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AppColors.primaryTeal)
                }
            }
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

// MARK: - Summary Box

struct SummaryBox: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textMuted)
            
            Text(value)
                .font(AppFonts.bodyBold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.inputBackground)
        .cornerRadius(12)
    }
}

// MARK: - Payoff Progress Card

struct PayoffProgressCard: View {
    let loanAmount: Double
    let monthlyPayment: Double
    let interestRate: Double
    
    var yearsToPayoff: Int {
        guard monthlyPayment > 0 else { return 0 }
        return Int(ceil(log(monthlyPayment / (monthlyPayment - loanAmount * interestRate / 100 / 12)) / log(1 + interestRate / 100 / 12) / 12))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("LOAN PAYOFF TIMELINE")
                .font(AppFonts.metricLabel)
                .foregroundColor(AppColors.textSecondary)
            
            // Timeline visualization
            HStack(spacing: 8) {
                ForEach([5, 10, 15, 20, 25, 30], id: \.self) { year in
                    VStack(spacing: 4) {
                        Circle()
                            .fill(year <= yearsToPayoff ? AppColors.primaryTeal : AppColors.inputBackground)
                            .frame(width: 12, height: 12)
                        
                        Text("Y\(year)")
                            .font(AppFonts.caption2)
                            .foregroundColor(AppColors.textMuted)
                    }
                    
                    if year < 30 {
                        Rectangle()
                            .fill(year < yearsToPayoff ? AppColors.primaryTeal : AppColors.inputBackground)
                            .frame(height: 2)
                    }
                }
            }
            .padding(.vertical, 8)
            
            Text("Loan paid off in \(yearsToPayoff) years")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textMuted)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
}

// MARK: - Amortization Row

struct AmortizationRow: View {
    let entry: AmortizationEntry
    
    var body: some View {
        HStack {
            Text("\(entry.year)")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textPrimary)
                .frame(width: 50, alignment: .leading)
            
            Text(formatCurrency(entry.totalPrincipalPaid))
                .font(AppFonts.caption)
                .foregroundColor(AppColors.successGreen)
                .frame(maxWidth: .infinity)
            
            Text(formatCurrency(entry.totalInterestPaid))
                .font(AppFonts.caption)
                .foregroundColor(AppColors.dangerRed)
                .frame(maxWidth: .infinity)
            
            Text(formatCurrency(entry.remainingBalance))
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(entry.year % 5 == 0 ? AppColors.inputBackground : Color.clear)
        .cornerRadius(8)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        if value >= 1000 {
            return String(format: "$%.0fK", value / 1000)
        }
        return String(format: "$%.0f", value)
    }
}

#Preview {
    AmortizationView(viewModel: {
        let vm = DealViewModel()
        vm.deal = .sampleDeal
        return vm
    }())
}
