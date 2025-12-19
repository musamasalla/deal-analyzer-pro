//
//  RefinanceAnalyzerView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/18.
//

import SwiftUI

/// Refinance analyzer to compare current vs new loan terms
struct RefinanceAnalyzerView: View {
    @Bindable var viewModel: DealViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Current loan
    @State private var currentBalance: Double = 180000
    @State private var currentRate: Double = 7.5
    @State private var currentMonthsRemaining: Int = 324
    @State private var currentPayment: Double = 1398
    
    // New loan
    @State private var newRate: Double = 6.5
    @State private var newTermYears: Int = 30
    @State private var closingCosts: Double = 5000
    @State private var cashOut: Double = 0
    
    var newLoanAmount: Double {
        currentBalance + closingCosts + cashOut
    }
    
    var newMonthlyPayment: Double {
        let principal = newLoanAmount
        let monthlyRate = (newRate / 100) / 12
        let numberOfPayments = Double(newTermYears * 12)
        
        guard monthlyRate > 0, numberOfPayments > 0 else { return 0 }
        
        return principal * (monthlyRate * pow(1 + monthlyRate, numberOfPayments)) /
               (pow(1 + monthlyRate, numberOfPayments) - 1)
    }
    
    var monthlySavings: Double {
        currentPayment - newMonthlyPayment
    }
    
    var breakEvenMonths: Int {
        guard monthlySavings > 0 else { return 0 }
        return Int(ceil(closingCosts / monthlySavings))
    }
    
    var currentTotalRemaining: Double {
        currentPayment * Double(currentMonthsRemaining)
    }
    
    var newTotalPayments: Double {
        newMonthlyPayment * Double(newTermYears * 12)
    }
    
    var lifetimeSavings: Double {
        currentTotalRemaining - newTotalPayments - closingCosts
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Summary Card
                    VStack(spacing: 16) {
                        HStack(spacing: 20) {
                            VStack(spacing: 4) {
                                Text("CURRENT")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.textMuted)
                                
                                Text(formatCurrency(currentPayment))
                                    .font(AppFonts.title)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 24))
                                .foregroundColor(AppColors.primaryTeal)
                            
                            VStack(spacing: 4) {
                                Text("NEW")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.textMuted)
                                
                                Text(formatCurrency(newMonthlyPayment))
                                    .font(AppFonts.title)
                                    .foregroundColor(AppColors.successGreen)
                            }
                        }
                        
                        Divider().background(AppColors.divider)
                        
                        HStack {
                            VStack(spacing: 4) {
                                Text(formatCurrency(abs(monthlySavings)) + "/mo")
                                    .font(AppFonts.title2)
                                    .foregroundColor(monthlySavings > 0 ? AppColors.successGreen : AppColors.dangerRed)
                                
                                Text(monthlySavings >= 0 ? "Monthly Savings" : "Monthly Increase")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.textMuted)
                            }
                            
                            Spacer()
                            
                            VStack(spacing: 4) {
                                Text("\(breakEvenMonths) months")
                                    .font(AppFonts.title2)
                                    .foregroundColor(AppColors.primaryTeal)
                                
                                Text("Break-Even")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.textMuted)
                            }
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Current Loan
                    VStack(alignment: .leading, spacing: 12) {
                        Text("CURRENT LOAN")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        CurrencyInputRow(label: "Current Balance", value: $currentBalance)
                        
                        HStack {
                            Text("Current Rate")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textSecondary)
                            Spacer()
                            Text(String(format: "%.2f%%", currentRate))
                                .font(AppFonts.bodyBold)
                                .foregroundColor(AppColors.textPrimary)
                        }
                        
                        Slider(value: $currentRate, in: 2...12, step: 0.125)
                            .tint(AppColors.warningAmber)
                        
                        HStack {
                            Text("Months Remaining")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textSecondary)
                            
                            Spacer()
                            
                            Stepper("\(currentMonthsRemaining / 12)y \(currentMonthsRemaining % 12)m", value: $currentMonthsRemaining, in: 12...360, step: 12)
                                .frame(width: 180)
                        }
                        
                        CurrencyInputRow(label: "Current Payment", value: $currentPayment)
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // New Loan
                    VStack(alignment: .leading, spacing: 12) {
                        Text("NEW LOAN")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        HStack {
                            Text("New Rate")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textSecondary)
                            Spacer()
                            Text(String(format: "%.2f%%", newRate))
                                .font(AppFonts.bodyBold)
                                .foregroundColor(AppColors.successGreen)
                        }
                        
                        Slider(value: $newRate, in: 2...12, step: 0.125)
                            .tint(AppColors.successGreen)
                        
                        HStack {
                            Text("New Term")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textSecondary)
                            Spacer()
                        }
                        
                        Picker("Term", selection: $newTermYears) {
                            Text("15 Years").tag(15)
                            Text("20 Years").tag(20)
                            Text("30 Years").tag(30)
                        }
                        .pickerStyle(.segmented)
                        
                        CurrencyInputRow(label: "Closing Costs", value: $closingCosts)
                        CurrencyInputRow(label: "Cash Out", value: $cashOut)
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Analysis
                    VStack(alignment: .leading, spacing: 12) {
                        Text("REFINANCE ANALYSIS")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        SummaryRow(label: "New Loan Amount", value: formatCurrency(newLoanAmount))
                        SummaryRow(label: "New Monthly Payment", value: formatCurrency(newMonthlyPayment))
                        
                        Divider().background(AppColors.divider)
                        
                        SummaryRow(label: "Current Total Remaining", value: formatCurrency(currentTotalRemaining))
                        SummaryRow(label: "New Total Payments", value: formatCurrency(newTotalPayments))
                        
                        Divider().background(AppColors.divider)
                        
                        HStack {
                            Text("Lifetime Savings")
                                .font(AppFonts.bodyBold)
                                .foregroundColor(AppColors.textPrimary)
                            
                            Spacer()
                            
                            Text(lifetimeSavings >= 0 ? "+" : "") +
                            Text(formatCurrency(lifetimeSavings))
                                .font(AppFonts.title2)
                                .foregroundColor(lifetimeSavings >= 0 ? AppColors.successGreen : AppColors.dangerRed)
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Recommendation
                    RefinanceRecommendation(
                        shouldRefinance: monthlySavings > 0 && breakEvenMonths < 36,
                        breakEvenMonths: breakEvenMonths,
                        monthlySavings: monthlySavings
                    )
                }
                .padding()
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Refinance Analysis")
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

// MARK: - Refinance Recommendation

struct RefinanceRecommendation: View {
    let shouldRefinance: Bool
    let breakEvenMonths: Int
    let monthlySavings: Double
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: shouldRefinance ? "checkmark.seal.fill" : "xmark.seal.fill")
                .font(.system(size: 40))
                .foregroundColor(shouldRefinance ? AppColors.successGreen : AppColors.dangerRed)
            
            Text(shouldRefinance ? "Refinancing Makes Sense" : "May Not Be Worth It")
                .font(AppFonts.title2)
                .foregroundColor(AppColors.textPrimary)
            
            Text(recommendationText)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(shouldRefinance ? AppColors.successGreen.opacity(0.1) : AppColors.dangerRed.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(shouldRefinance ? AppColors.successGreen : AppColors.dangerRed, lineWidth: 1)
        )
    }
    
    var recommendationText: String {
        if shouldRefinance {
            return "You'll break even in \(breakEvenMonths) months and save \(formatCurrency(monthlySavings))/month. Consider refinancing if you plan to stay in the property."
        } else if monthlySavings <= 0 {
            return "The new rate doesn't improve your monthly payment. Wait for better rates."
        } else {
            return "Break-even point is \(breakEvenMonths) months. Consider if you'll stay that long."
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

#Preview {
    RefinanceAnalyzerView(viewModel: DealViewModel())
}
