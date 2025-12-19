//
//  CashBuyerModeView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/19.
//

import SwiftUI

/// Cash buyer analysis mode - simpler view without financing
struct CashBuyerModeView: View {
    @Bindable var viewModel: DealViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Cash buyer specific inputs
    @State private var purchasePrice: Double = 0
    @State private var closingCosts: Double = 0
    @State private var rehabCosts: Double = 0
    @State private var monthlyRent: Double = 0
    @State private var monthlyExpenses: Double = 0
    @State private var annualPropertyTax: Double = 0
    @State private var monthlyInsurance: Double = 0
    
    var totalInvestment: Double {
        purchasePrice + closingCosts + rehabCosts
    }
    
    var totalMonthlyExpenses: Double {
        monthlyExpenses + (annualPropertyTax / 12) + monthlyInsurance
    }
    
    var monthlyCashFlow: Double {
        monthlyRent - totalMonthlyExpenses
    }
    
    var annualCashFlow: Double {
        monthlyCashFlow * 12
    }
    
    var cashOnCashReturn: Double {
        guard totalInvestment > 0 else { return 0 }
        return (annualCashFlow / totalInvestment) * 100
    }
    
    var capRate: Double {
        guard purchasePrice > 0 else { return 0 }
        let noi = (monthlyRent * 12) - (totalMonthlyExpenses * 12)
        return (noi / purchasePrice) * 100
    }
    
    var grossRentMultiplier: Double {
        guard monthlyRent > 0 else { return 0 }
        return purchasePrice / (monthlyRent * 12)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Hero Results
                    VStack(spacing: 16) {
                        Text("MONTHLY CASH FLOW")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text(formatCurrency(monthlyCashFlow))
                            .font(AppFonts.cashFlowDisplay)
                            .foregroundColor(monthlyCashFlow >= 0 ? AppColors.successGreen : AppColors.dangerRed)
                        
                        HStack(spacing: 20) {
                            VStack {
                                Text(String(format: "%.1f%%", cashOnCashReturn))
                                    .font(AppFonts.title2)
                                    .foregroundColor(AppColors.primaryTeal)
                                Text("Cash-on-Cash")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.textMuted)
                            }
                            
                            VStack {
                                Text(String(format: "%.1f%%", capRate))
                                    .font(AppFonts.title2)
                                    .foregroundColor(AppColors.primaryTeal)
                                Text("Cap Rate")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.textMuted)
                            }
                            
                            VStack {
                                Text(String(format: "%.1f", grossRentMultiplier))
                                    .font(AppFonts.title2)
                                    .foregroundColor(AppColors.primaryTeal)
                                Text("GRM")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.textMuted)
                            }
                        }
                    }
                    .padding(24)
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Purchase Details
                    VStack(alignment: .leading, spacing: 12) {
                        Text("PURCHASE")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        CurrencyTextField(
                            title: "Purchase Price",
                            value: $purchasePrice,
                            placeholder: "0"
                        )
                        
                        CurrencyTextField(
                            title: "Closing Costs",
                            value: $closingCosts,
                            placeholder: "0"
                        )
                        
                        CurrencyTextField(
                            title: "Rehab/Repair Costs",
                            value: $rehabCosts,
                            placeholder: "0"
                        )
                        
                        Divider().background(AppColors.divider)
                        
                        HStack {
                            Text("Total Investment")
                                .font(AppFonts.bodyBold)
                                .foregroundColor(AppColors.textPrimary)
                            Spacer()
                            Text(formatCurrency(totalInvestment))
                                .font(AppFonts.bodyBold)
                                .foregroundColor(AppColors.primaryTeal)
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Income
                    VStack(alignment: .leading, spacing: 12) {
                        Text("INCOME")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        CurrencyTextField(
                            title: "Monthly Rent",
                            value: $monthlyRent,
                            placeholder: "0"
                        )
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Expenses
                    VStack(alignment: .leading, spacing: 12) {
                        Text("EXPENSES")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        CurrencyTextField(
                            title: "Annual Property Tax",
                            value: $annualPropertyTax,
                            placeholder: "0"
                        )
                        
                        CurrencyTextField(
                            title: "Monthly Insurance",
                            value: $monthlyInsurance,
                            placeholder: "0"
                        )
                        
                        CurrencyTextField(
                            title: "Other Monthly Expenses",
                            value: $monthlyExpenses,
                            placeholder: "0"
                        )
                        
                        Divider().background(AppColors.divider)
                        
                        HStack {
                            Text("Total Monthly Expenses")
                                .font(AppFonts.bodyBold)
                                .foregroundColor(AppColors.textPrimary)
                            Spacer()
                            Text(formatCurrency(totalMonthlyExpenses))
                                .font(AppFonts.bodyBold)
                                .foregroundColor(AppColors.warningAmber)
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Summary
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ANALYSIS")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        SummaryRow(label: "Monthly Rent", value: formatCurrency(monthlyRent))
                        SummaryRow(label: "Monthly Expenses", value: "-" + formatCurrency(totalMonthlyExpenses))
                        
                        Divider().background(AppColors.divider)
                        
                        SummaryRow(label: "Monthly Cash Flow", value: formatCurrency(monthlyCashFlow), isHighlighted: true)
                        SummaryRow(label: "Annual Cash Flow", value: formatCurrency(annualCashFlow))
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Apply to main deal
                    Button(action: applyToMainDeal) {
                        Text("Apply to Main Analysis")
                            .font(AppFonts.bodyBold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.primaryTeal)
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Cash Buyer Mode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }
    
    private func applyToMainDeal() {
        viewModel.deal.purchasePrice = purchasePrice
        viewModel.deal.downPaymentPercent = 100 // Cash buyer = 100% down
        viewModel.deal.monthlyRent = monthlyRent
        viewModel.deal.annualPropertyTax = annualPropertyTax
        viewModel.deal.monthlyInsurance = monthlyInsurance
        viewModel.deal.otherMonthlyExpenses = monthlyExpenses
        dismiss()
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

#Preview {
    CashBuyerModeView(viewModel: DealViewModel())
}
