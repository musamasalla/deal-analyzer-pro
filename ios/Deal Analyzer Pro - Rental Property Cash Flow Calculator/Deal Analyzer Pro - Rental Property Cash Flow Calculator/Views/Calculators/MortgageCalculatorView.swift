//
//  MortgageCalculatorView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/18.
//

import SwiftUI

/// Standalone mortgage calculator
struct MortgageCalculatorView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var loanAmount: Double = 200000
    @State private var interestRate: Double = 7.0
    @State private var loanTermYears: Int = 30
    @State private var extraPayment: Double = 0
    
    var monthlyPayment: Double {
        let principal = loanAmount
        let monthlyRate = (interestRate / 100) / 12
        let numberOfPayments = Double(loanTermYears * 12)
        
        guard monthlyRate > 0, numberOfPayments > 0 else { return 0 }
        
        let payment = principal * (monthlyRate * pow(1 + monthlyRate, numberOfPayments)) /
                     (pow(1 + monthlyRate, numberOfPayments) - 1)
        return payment
    }
    
    var totalPayment: Double {
        monthlyPayment * Double(loanTermYears * 12)
    }
    
    var totalInterest: Double {
        totalPayment - loanAmount
    }
    
    var payoffWithExtra: (months: Int, interestSaved: Double) {
        guard extraPayment > 0  else { return (loanTermYears * 12, 0) }
        
        var balance = loanAmount
        let monthlyRate = (interestRate / 100) / 12
        var months = 0
        var totalInterestWithExtra: Double = 0
        
        while balance > 0 && months < loanTermYears * 12 * 2 {
            let interestPayment = balance * monthlyRate
            let principalPayment = min(monthlyPayment - interestPayment + extraPayment, balance)
            balance -= principalPayment
            totalInterestWithExtra += interestPayment
            months += 1
        }
        
        return (months, totalInterest - totalInterestWithExtra)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Payment Display
                    VStack(spacing: 12) {
                        Text("MONTHLY PAYMENT")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text(formatCurrency(monthlyPayment))
                            .font(AppFonts.cashFlowDisplay)
                            .foregroundColor(AppColors.primaryTeal)
                        
                        if extraPayment > 0 {
                            Text("+ \(formatCurrency(extraPayment)) extra = \(formatCurrency(monthlyPayment + extraPayment))")
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.successGreen)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Inputs
                    VStack(alignment: .leading, spacing: 16) {
                        Text("LOAN DETAILS")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        CurrencyTextField(
                            title: "Loan Amount",
                            value: $loanAmount,
                            placeholder: "200000"
                        )
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Interest Rate")
                                    .font(AppFonts.fieldLabel)
                                    .foregroundColor(AppColors.textSecondary)
                                
                                Spacer()
                                
                                Text(String(format: "%.2f%%", interestRate))
                                    .font(AppFonts.bodyBold)
                                    .foregroundColor(AppColors.textPrimary)
                            }
                            
                            Slider(value: $interestRate, in: 1...15, step: 0.125)
                                .tint(AppColors.primaryTeal)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Loan Term")
                                .font(AppFonts.fieldLabel)
                                .foregroundColor(AppColors.textSecondary)
                            
                            Picker("Term", selection: $loanTermYears) {
                                Text("15 Years").tag(15)
                                Text("20 Years").tag(20)
                                Text("30 Years").tag(30)
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        CurrencyTextField(
                            title: "Extra Monthly Payment (optional)",
                            value: $extraPayment,
                            placeholder: "0"
                        )
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Summary
                    VStack(alignment: .leading, spacing: 12) {
                        Text("LOAN SUMMARY")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        SummaryRow(label: "Total Amount Paid", value: formatCurrency(totalPayment))
                        SummaryRow(label: "Total Interest", value: formatCurrency(totalInterest))
                        
                        Divider().background(AppColors.divider)
                        
                        if extraPayment > 0 {
                            let result = payoffWithExtra
                            SummaryRow(
                                label: "Payoff Time",
                                value: "\(result.months / 12)y \(result.months % 12)m",
                                subtitle: "vs \(loanTermYears) years"
                            )
                            
                            HStack {
                                Text("Interest Saved")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.textSecondary)
                                
                                Spacer()
                                
                                Text(formatCurrency(result.interestSaved))
                                    .font(AppFonts.bodyBold)
                                    .foregroundColor(AppColors.successGreen)
                            }
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Payment Breakdown
                    VStack(alignment: .leading, spacing: 12) {
                        Text("FIRST PAYMENT BREAKDOWN")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        let firstInterest = loanAmount * (interestRate / 100) / 12
                        let firstPrincipal = monthlyPayment - firstInterest
                        
                        PaymentBreakdownBar(
                            principal: firstPrincipal,
                            interest: firstInterest
                        )
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                }
                .padding()
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Mortgage Calculator")
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
        return CurrencyFormatter.format(value)
    }
}

// MARK: - Payment Breakdown Bar

struct PaymentBreakdownBar: View {
    let principal: Double
    let interest: Double
    
    var total: Double { principal + interest }
    var principalPercent: CGFloat { CGFloat(principal / total) }
    
    var body: some View {
        VStack(spacing: 12) {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(AppColors.successGreen)
                        .frame(width: geometry.size.width * principalPercent)
                    
                    Rectangle()
                        .fill(AppColors.warningAmber)
                }
            }
            .frame(height: 24)
            .cornerRadius(12)
            
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(AppColors.successGreen)
                        .frame(width: 12, height: 12)
                    Text("Principal: \(formatCurrency(principal))")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(AppColors.warningAmber)
                        .frame(width: 12, height: 12)
                    Text("Interest: \(formatCurrency(interest))")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        return CurrencyFormatter.format(value)
    }
}

#Preview {
    MortgageCalculatorView()
}
