//
//  FinancingSection.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/17.
//

import SwiftUI

/// Financing input section with down payment, rate, and term
struct FinancingSection: View {
    @Bindable var viewModel: DealViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                title: "Financing",
                icon: "banknote.fill",
                subtitle: "Loan details and down payment"
            )
            
            // Cash Purchase Toggle
            Toggle(isOn: $viewModel.deal.isCashPurchase) {
                HStack {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(AppColors.primaryTeal)
                    
                    VStack(alignment: .leading) {
                        Text("Cash Purchase")
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("No financing needed")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textMuted)
                    }
                }
            }
            .tint(AppColors.primaryTeal)
            .padding(16)
            .background(AppColors.inputBackground)
            .cornerRadius(12)
            
            if !viewModel.deal.isCashPurchase {
                // Down Payment Slider
                PercentageWithValueSlider(
                    title: "Down Payment",
                    percentage: $viewModel.deal.downPaymentPercent,
                    baseValue: viewModel.deal.purchasePrice,
                    range: 0...100,
                    step: 5
                )
                
                // Interest Rate
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Interest Rate")
                            .font(AppFonts.fieldLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Spacer()
                        
                        Text("\(String(format: "%.2f", viewModel.deal.interestRate))%")
                            .font(AppFonts.bodyBold)
                            .foregroundColor(AppColors.textAccent)
                    }
                    
                    Slider(value: $viewModel.deal.interestRate, in: 2...15, step: 0.125)
                        .tint(AppColors.primaryTeal)
                    
                    HStack {
                        Text("2%")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textMuted)
                        
                        Spacer()
                        
                        Text("15%")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textMuted)
                    }
                }
                .padding(16)
                .background(AppColors.inputBackground)
                .cornerRadius(12)
                
                // Loan Term
                VStack(alignment: .leading, spacing: 8) {
                    Text("Loan Term")
                        .font(AppFonts.fieldLabel)
                        .foregroundColor(AppColors.textSecondary)
                    
                    HStack(spacing: 12) {
                        ForEach(LoanTerm.allCases) { term in
                            Button(action: { viewModel.deal.loanTermYears = term.rawValue }) {
                                Text(term.displayName)
                                    .font(AppFonts.body)
                                    .foregroundColor(
                                        viewModel.deal.loanTermYears == term.rawValue
                                            ? .white
                                            : AppColors.textSecondary
                                    )
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        viewModel.deal.loanTermYears == term.rawValue
                                            ? AppColors.primaryTeal
                                            : AppColors.inputBackground
                                    )
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(
                                                viewModel.deal.loanTermYears == term.rawValue
                                                    ? AppColors.primaryTeal
                                                    : AppColors.border,
                                                lineWidth: 1
                                            )
                                    )
                            }
                        }
                    }
                }
                .padding(16)
                .background(AppColors.inputBackground)
                .cornerRadius(12)
                
                // Closing Costs
                PercentageWithValueSlider(
                    title: "Closing Costs",
                    percentage: $viewModel.deal.closingCostPercent,
                    baseValue: viewModel.deal.purchasePrice,
                    range: 0...10,
                    step: 0.5
                )
                
                // Monthly P&I Display
                if viewModel.deal.purchasePrice > 0 {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("MONTHLY P&I PAYMENT")
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.textMuted)
                            
                            Text(formatCurrency(viewModel.results.monthlyMortgagePayment))
                                .font(AppFonts.title)
                                .foregroundColor(AppColors.textAccent)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("LOAN AMOUNT")
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.textMuted)
                            
                            Text(formatCurrency(viewModel.deal.loanAmount))
                                .font(AppFonts.bodyBold)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    .padding(16)
                    .background(
                        LinearGradient(
                            colors: [AppColors.primaryTeal.opacity(0.1), AppColors.primaryTeal.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.primaryTeal.opacity(0.3), lineWidth: 1)
                    )
                }
            }
        }
        .padding(16)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        ScrollView {
            FinancingSection(viewModel: {
                let vm = DealViewModel()
                vm.deal.purchasePrice = 250000
                return vm
            }())
            .padding()
        }
    }
}
