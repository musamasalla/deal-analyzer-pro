//
//  OfferCalculatorView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/19.
//

import SwiftUI

/// Calculate maximum purchase price based on desired returns
struct OfferCalculatorView: View {
    @Bindable var viewModel: DealViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Target metrics
    @State private var targetCashFlow: Double = 200
    @State private var targetCoCReturn: Double = 10
    @State private var targetCapRate: Double = 8
    
    // Property details
    @State private var monthlyRent: Double = 1500
    @State private var annualExpenses: Double = 6000
    @State private var downPaymentPercent: Double = 20
    @State private var interestRate: Double = 7.0
    @State private var loanTermYears: Int = 30
    
    var maxPriceByCashFlow: Double {
        // Calculate max price that yields target cash flow
        let annualNOI = (monthlyRent * 12) - annualExpenses
        let targetAnnualCashFlow = targetCashFlow * 12
        let annualDebtService = annualNOI - targetAnnualCashFlow
        
        guard annualDebtService > 0 else { return 0 }
        
        // Reverse engineer loan amount from debt service
        let monthlyPayment = annualDebtService / 12
        let monthlyRate = (interestRate / 100) / 12
        let numberOfPayments = Double(loanTermYears * 12)
        
        guard monthlyRate > 0 else { return 0 }
        
        let loanAmount = monthlyPayment * (pow(1 + monthlyRate, numberOfPayments) - 1) /
                        (monthlyRate * pow(1 + monthlyRate, numberOfPayments))
        
        return loanAmount / (1 - downPaymentPercent / 100)
    }
    
    var maxPriceByCoC: Double {
        // Calculate max price that yields target CoC return
        let annualNOI = (monthlyRent * 12) - annualExpenses
        let monthlyRate = (interestRate / 100) / 12
        let numberOfPayments = Double(loanTermYears * 12)
        
        // Iterative approach - start from rent multiplier
        var testPrice = monthlyRent * 12 * 10  // Start at 10 GRM
        
        for _ in 0..<20 {
            let downPayment = testPrice * (downPaymentPercent / 100)
            let loanAmount = testPrice - downPayment
            
            let monthlyPayment = loanAmount * (monthlyRate * pow(1 + monthlyRate, numberOfPayments)) /
                                (pow(1 + monthlyRate, numberOfPayments) - 1)
            let annualDebtService = monthlyPayment * 12
            let annualCashFlow = annualNOI - annualDebtService
            
            let cashOnCash = (annualCashFlow / downPayment) * 100
            
            if abs(cashOnCash - targetCoCReturn) < 0.1 {
                break
            }
            
            // Adjust price based on how far we are
            if cashOnCash < targetCoCReturn {
                testPrice *= 0.95
            } else {
                testPrice *= 1.02
            }
        }
        
        return max(0, testPrice)
    }
    
    var maxPriceByCapRate: Double {
        // Calculate max price that yields target cap rate
        let annualNOI = (monthlyRent * 12) - annualExpenses
        guard targetCapRate > 0 else { return 0 }
        return annualNOI / (targetCapRate / 100)
    }
    
    var suggestedMaxPrice: Double {
        // Use the minimum of all calculated max prices
        let prices = [maxPriceByCashFlow, maxPriceByCoC, maxPriceByCapRate].filter { $0 > 0 }
        return prices.min() ?? 0
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Suggested Price Result
                    VStack(spacing: 12) {
                        Text("SUGGESTED MAX OFFER")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text(formatCurrency(suggestedMaxPrice))
                            .font(AppFonts.cashFlowDisplay)
                            .foregroundColor(AppColors.successGreen)
                        
                        Text("Based on your target returns")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textMuted)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Target Metrics
                    VStack(alignment: .leading, spacing: 16) {
                        Text("TARGET RETURNS")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Target Monthly Cash Flow")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.textSecondary)
                                Spacer()
                                Text(formatCurrency(targetCashFlow))
                                    .font(AppFonts.bodyBold)
                                    .foregroundColor(AppColors.textPrimary)
                            }
                            Slider(value: $targetCashFlow, in: 0...1000, step: 50)
                                .tint(AppColors.successGreen)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Target Cash-on-Cash Return")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.textSecondary)
                                Spacer()
                                Text(String(format: "%.1f%%", targetCoCReturn))
                                    .font(AppFonts.bodyBold)
                                    .foregroundColor(AppColors.textPrimary)
                            }
                            Slider(value: $targetCoCReturn, in: 4...20, step: 0.5)
                                .tint(AppColors.primaryTeal)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Target Cap Rate")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.textSecondary)
                                Spacer()
                                Text(String(format: "%.1f%%", targetCapRate))
                                    .font(AppFonts.bodyBold)
                                    .foregroundColor(AppColors.textPrimary)
                            }
                            Slider(value: $targetCapRate, in: 4...15, step: 0.5)
                                .tint(AppColors.warningAmber)
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Property Details
                    VStack(alignment: .leading, spacing: 12) {
                        Text("PROPERTY DETAILS")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        CurrencyTextField(
                            title: "Expected Monthly Rent",
                            value: $monthlyRent,
                            placeholder: "1500"
                        )
                        
                        CurrencyTextField(
                            title: "Annual Operating Expenses",
                            value: $annualExpenses,
                            placeholder: "6000"
                        )
                        
                        HStack {
                            Text("Down Payment")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textSecondary)
                            Spacer()
                            Text(String(format: "%.0f%%", downPaymentPercent))
                                .font(AppFonts.bodyBold)
                                .foregroundColor(AppColors.textPrimary)
                        }
                        
                        Slider(value: $downPaymentPercent, in: 5...100, step: 5)
                            .tint(AppColors.primaryTeal)
                        
                        HStack {
                            Text("Interest Rate")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textSecondary)
                            Spacer()
                            Text(String(format: "%.2f%%", interestRate))
                                .font(AppFonts.bodyBold)
                                .foregroundColor(AppColors.textPrimary)
                        }
                        
                        Slider(value: $interestRate, in: 3...12, step: 0.125)
                            .tint(AppColors.primaryTeal)
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Price Breakdown
                    VStack(alignment: .leading, spacing: 12) {
                        Text("MAX PRICE BY METRIC")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        MaxPriceRow(
                            metric: "By Cash Flow",
                            target: "\(formatCurrency(targetCashFlow))/mo",
                            maxPrice: maxPriceByCashFlow,
                            isLowest: maxPriceByCashFlow == suggestedMaxPrice
                        )
                        
                        MaxPriceRow(
                            metric: "By CoC Return",
                            target: String(format: "%.1f%%", targetCoCReturn),
                            maxPrice: maxPriceByCoC,
                            isLowest: maxPriceByCoC == suggestedMaxPrice
                        )
                        
                        MaxPriceRow(
                            metric: "By Cap Rate",
                            target: String(format: "%.1f%%", targetCapRate),
                            maxPrice: maxPriceByCapRate,
                            isLowest: maxPriceByCapRate == suggestedMaxPrice
                        )
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Apply Button
                    Button(action: applyToMainDeal) {
                        Text("Use This Price in Analysis")
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
            .navigationTitle("Offer Calculator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AppColors.primaryTeal)
                }
            }
        }
    }
    
    private func applyToMainDeal() {
        viewModel.deal.purchasePrice = suggestedMaxPrice
        viewModel.deal.monthlyRent = monthlyRent
        viewModel.deal.downPaymentPercent = downPaymentPercent
        viewModel.deal.interestRate = interestRate
        dismiss()
    }
    
    private func formatCurrency(_ value: Double) -> String {
        return CurrencyFormatter.format(value)
    }
}

// MARK: - Max Price Row

struct MaxPriceRow: View {
    let metric: String
    let target: String
    let maxPrice: Double
    let isLowest: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(metric)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textPrimary)
                Text("Target: \(target)")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Text(formatCurrency(maxPrice))
                    .font(AppFonts.bodyBold)
                    .foregroundColor(isLowest ? AppColors.successGreen : AppColors.textSecondary)
                
                if isLowest {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.successGreen)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        return CurrencyFormatter.format(value)
    }
}

#Preview {
    OfferCalculatorView(viewModel: DealViewModel())
}
