//
//  QuickEntryView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/17.
//

import SwiftUI

/// Quick Entry mode - only 6 essential fields for fast analysis
struct QuickEntryView: View {
    @Bindable var viewModel: DealViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(AppColors.primaryTeal)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Quick Analysis")
                        .font(AppFonts.sectionHeader)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Enter 6 key numbers for instant results")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textMuted)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            
            // Quick Entry Fields
            VStack(spacing: 16) {
                // Row 1: Price & Rent
                HStack(spacing: 12) {
                    CompactCurrencyField(
                        title: "Purchase Price",
                        value: $viewModel.deal.purchasePrice
                    )
                    
                    CompactCurrencyField(
                        title: "Monthly Rent",
                        value: $viewModel.deal.monthlyRent
                    )
                }
                
                // Row 2: Down Payment & Interest Rate
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Down Payment")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                        
                        HStack {
                            TextField("20", value: $viewModel.deal.downPaymentPercent, format: .number)
                                .font(AppFonts.bodyBold)
                                .foregroundColor(AppColors.textPrimary)
                                .keyboardType(.decimalPad)
                            
                            Text("%")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(AppColors.inputBackground)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Interest Rate")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                        
                        HStack {
                            TextField("7.5", value: $viewModel.deal.interestRate, format: .number.precision(.fractionLength(2)))
                                .font(AppFonts.bodyBold)
                                .foregroundColor(AppColors.textPrimary)
                                .keyboardType(.decimalPad)
                            
                            Text("%")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(AppColors.inputBackground)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                    }
                }
                
                // Row 3: Property Tax & Insurance
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Annual Taxes")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                        
                        HStack(spacing: 4) {
                            Text("$")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textSecondary)
                            
                            TextField("0", value: $viewModel.deal.annualPropertyTax, format: .number)
                                .font(AppFonts.bodyBold)
                                .foregroundColor(AppColors.textPrimary)
                                .keyboardType(.decimalPad)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(AppColors.inputBackground)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                    }
                    
                    CompactCurrencyField(
                        title: "Monthly Insurance",
                        value: $viewModel.deal.monthlyInsurance
                    )
                }
                
                // Use Last Deal Button
                if !viewModel.savedDeals.isEmpty {
                    Button(action: {
                        viewModel.useLastExpenses()
                    }) {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                            Text("Use Last Deal's Expenses")
                        }
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.primaryTeal)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppColors.primaryTeal.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(16)
            .padding(.horizontal)
            
            // Quick Summary
            if viewModel.deal.purchasePrice > 0 && viewModel.deal.monthlyRent > 0 {
                QuickResultsSummary(viewModel: viewModel)
                    .padding(.horizontal)
            }
        }
    }
}

/// Compact results summary for quick entry mode
struct QuickResultsSummary: View {
    @Bindable var viewModel: DealViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            // Main Cash Flow
            HStack {
                Text("Monthly Cash Flow")
                    .font(AppFonts.bodyBold)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Text(formatCurrency(viewModel.results.monthlyCashFlow))
                    .font(AppFonts.title)
                    .foregroundColor(viewModel.results.monthlyCashFlow >= 0 ? AppColors.successGreen : AppColors.dangerRed)
            }
            
            Divider()
                .background(AppColors.divider)
            
            // Key Metrics Row
            HStack {
                QuickMetric(
                    label: "CoC",
                    value: String(format: "%.1f%%", viewModel.results.cashOnCashReturn)
                )
                
                Divider()
                    .frame(height: 30)
                    .background(AppColors.divider)
                
                QuickMetric(
                    label: "Cap Rate",
                    value: String(format: "%.1f%%", viewModel.results.capRate)
                )
                
                Divider()
                    .frame(height: 30)
                    .background(AppColors.divider)
                
                QuickMetric(
                    label: "Cash Needed",
                    value: formatCompactCurrency(viewModel.results.totalCashNeeded)
                )
            }
        }
        .padding(16)
        .background(
            viewModel.results.monthlyCashFlow >= 0
                ? AppColors.successGreen.opacity(0.1)
                : AppColors.dangerRed.opacity(0.1)
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    viewModel.results.monthlyCashFlow >= 0
                        ? AppColors.successGreen.opacity(0.3)
                        : AppColors.dangerRed.opacity(0.3),
                    lineWidth: 1
                )
        )
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let prefix = value >= 0 ? "+" : ""
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return prefix + (formatter.string(from: NSNumber(value: value)) ?? "$0")
    }
    
    private func formatCompactCurrency(_ value: Double) -> String {
        if value >= 1000000 {
            return String(format: "$%.1fM", value / 1000000)
        } else if value >= 1000 {
            return String(format: "$%.0fK", value / 1000)
        } else {
            return String(format: "$%.0f", value)
        }
    }
}

struct QuickMetric: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textMuted)
            
            Text(value)
                .font(AppFonts.bodyBold)
                .foregroundColor(AppColors.textPrimary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        ScrollView {
            QuickEntryView(viewModel: {
                let vm = DealViewModel()
                vm.deal.purchasePrice = 250000
                vm.deal.monthlyRent = 1800
                vm.deal.annualPropertyTax = 2400
                vm.deal.monthlyInsurance = 150
                return vm
            }())
        }
    }
}
