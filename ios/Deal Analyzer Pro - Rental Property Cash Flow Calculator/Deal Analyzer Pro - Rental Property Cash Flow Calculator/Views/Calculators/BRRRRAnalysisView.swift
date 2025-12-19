//
//  BRRRRAnalysisView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/18.
//

import SwiftUI

/// BRRRR (Buy, Rehab, Rent, Refinance, Repeat) Strategy Analyzer
struct BRRRRAnalysisView: View {
    @Bindable var viewModel: DealViewModel
    @Environment(\.dismiss) private var dismiss
    
    // BRRRR-specific inputs
    @State private var purchasePrice: Double = 150000
    @State private var rehabCost: Double = 30000
    @State private var afterRepairValue: Double = 220000
    @State private var monthsToRehab: Int = 3
    @State private var holdingCostPerMonth: Double = 1500
    @State private var refinanceLTV: Double = 75
    @State private var refinanceRate: Double = 7.5
    @State private var monthlyRent: Double = 1800
    @State private var monthlyExpenses: Double = 600
    
    // Computed properties
    var totalInvestment: Double {
        purchasePrice + rehabCost + (Double(monthsToRehab) * holdingCostPerMonth)
    }
    
    var refinanceAmount: Double {
        afterRepairValue * (refinanceLTV / 100)
    }
    
    var cashOutAtRefinance: Double {
        refinanceAmount - purchasePrice // Assuming cash purchase for rehab
    }
    
    var cashLeftInDeal: Double {
        max(0, totalInvestment - refinanceAmount)
    }
    
    var monthlyMortgage: Double {
        let principal = refinanceAmount
        let monthlyRate = (refinanceRate / 100) / 12
        let numberOfPayments: Double = 360 // 30 years
        
        guard monthlyRate > 0 else { return 0 }
        
        return principal * (monthlyRate * pow(1 + monthlyRate, numberOfPayments)) /
               (pow(1 + monthlyRate, numberOfPayments) - 1)
    }
    
    var monthlyCashFlow: Double {
        monthlyRent - monthlyExpenses - monthlyMortgage
    }
    
    var annualCashFlow: Double {
        monthlyCashFlow * 12
    }
    
    var cashOnCashReturn: Double {
        guard cashLeftInDeal > 0 else { return .infinity }
        return (annualCashFlow / cashLeftInDeal) * 100
    }
    
    var equityCreated: Double {
        afterRepairValue - refinanceAmount
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // BRRRR Header
                    HStack(spacing: 4) {
                        ForEach(["Buy", "Rehab", "Rent", "Refinance", "Repeat"], id: \.self) { step in
                            Text(String(step.prefix(1)))
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppColors.primaryTeal)
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(12)
                    
                    // Key Results
                    VStack(spacing: 12) {
                        Text("DEAL SUMMARY")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            BRRRRMetricCard(
                                title: "Cash Left In Deal",
                                value: formatCurrency(cashLeftInDeal),
                                color: cashLeftInDeal <= 0 ? AppColors.successGreen : AppColors.warningAmber
                            )
                            
                            BRRRRMetricCard(
                                title: "Cash-on-Cash",
                                value: cashOnCashReturn.isInfinite ? "∞ %" : String(format: "%.1f%%", cashOnCashReturn),
                                color: cashOnCashReturn >= 20 || cashOnCashReturn.isInfinite ? AppColors.successGreen : AppColors.primaryTeal
                            )
                            
                            BRRRRMetricCard(
                                title: "Monthly Cash Flow",
                                value: formatCurrency(monthlyCashFlow),
                                color: monthlyCashFlow >= 0 ? AppColors.successGreen : AppColors.dangerRed
                            )
                            
                            BRRRRMetricCard(
                                title: "Equity Created",
                                value: formatCurrency(equityCreated),
                                color: AppColors.primaryTeal
                            )
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Phase 1: Buy
                    BRRRRPhaseSection(phase: "BUY", icon: "house.fill", color: .blue) {
                        CurrencyInputRow(label: "Purchase Price", value: $purchasePrice)
                    }
                    
                    // Phase 2: Rehab
                    BRRRRPhaseSection(phase: "REHAB", icon: "hammer.fill", color: .orange) {
                        CurrencyInputRow(label: "Rehab Cost", value: $rehabCost)
                        
                        HStack {
                            Text("Months to Complete")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textSecondary)
                            Spacer()
                            Stepper("\(monthsToRehab)", value: $monthsToRehab, in: 1...12)
                                .frame(width: 120)
                        }
                        
                        CurrencyInputRow(label: "Holding Cost/Month", value: $holdingCostPerMonth)
                        CurrencyInputRow(label: "After Repair Value", value: $afterRepairValue)
                    }
                    
                    // Phase 3: Rent
                    BRRRRPhaseSection(phase: "RENT", icon: "key.fill", color: .green) {
                        CurrencyInputRow(label: "Monthly Rent", value: $monthlyRent)
                        CurrencyInputRow(label: "Monthly Expenses", value: $monthlyExpenses)
                    }
                    
                    // Phase 4: Refinance
                    BRRRRPhaseSection(phase: "REFINANCE", icon: "arrow.triangle.2.circlepath", color: .purple) {
                        HStack {
                            Text("Refinance LTV")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textSecondary)
                            Spacer()
                            Text(String(format: "%.0f%%", refinanceLTV))
                                .font(AppFonts.bodyBold)
                                .foregroundColor(AppColors.textPrimary)
                        }
                        
                        Slider(value: $refinanceLTV, in: 50...80, step: 5)
                            .tint(AppColors.primaryTeal)
                        
                        HStack {
                            Text("Refinance Rate")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textSecondary)
                            Spacer()
                            Text(String(format: "%.2f%%", refinanceRate))
                                .font(AppFonts.bodyBold)
                                .foregroundColor(AppColors.textPrimary)
                        }
                        
                        Slider(value: $refinanceRate, in: 4...12, step: 0.125)
                            .tint(AppColors.primaryTeal)
                    }
                    
                    // Detailed Breakdown
                    VStack(alignment: .leading, spacing: 12) {
                        Text("CASH FLOW BREAKDOWN")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        SummaryRow(label: "Total Investment", value: formatCurrency(totalInvestment))
                        SummaryRow(label: "Refinance Amount", value: formatCurrency(refinanceAmount))
                        
                        Divider().background(AppColors.divider)
                        
                        SummaryRow(label: "Monthly Rent", value: formatCurrency(monthlyRent))
                        SummaryRow(label: "Monthly Expenses", value: "-" + formatCurrency(monthlyExpenses))
                        SummaryRow(label: "Monthly Mortgage", value: "-" + formatCurrency(monthlyMortgage))
                        
                        Divider().background(AppColors.divider)
                        
                        SummaryRow(label: "Net Monthly", value: formatCurrency(monthlyCashFlow), isHighlighted: true)
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                }
                .padding()
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("BRRRR Analysis")
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

// MARK: - BRRRR Phase Section

struct BRRRRPhaseSection<Content: View>: View {
    let phase: String
    let icon: String
    let color: Color
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(color)
                    .cornerRadius(6)
                
                Text(phase)
                    .font(AppFonts.metricLabel)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            content
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
}

// MARK: - BRRRR Metric Card

struct BRRRRMetricCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(AppFonts.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.inputBackground)
        .cornerRadius(12)
    }
}

// MARK: - Currency Input Row

struct CurrencyInputRow: View {
    let label: String
    @Binding var value: Double
    
    var body: some View {
        HStack {
            Text(label)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
            
            Spacer()
            
            TextField("$0", value: $value, format: .currency(code: "USD").precision(.fractionLength(0)))
                .font(AppFonts.bodyBold)
                .foregroundColor(AppColors.textPrimary)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 120)
        }
    }
}

#Preview {
    BRRRRAnalysisView(viewModel: DealViewModel())
}
