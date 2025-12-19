//
//  ScenarioTestingView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/18.
//

import SwiftUI

/// "What If" mode for testing different scenarios
struct ScenarioTestingView: View {
    @Bindable var viewModel: DealViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Scenario adjustments
    @State private var rentAdjustment: Double = 0
    @State private var interestRateAdjustment: Double = 0
    @State private var downPaymentAdjustment: Double = 0
    @State private var vacancyAdjustment: Double = 0
    
    // Original values (stored when view appears)
    @State private var originalRent: Double = 0
    @State private var originalRate: Double = 0
    @State private var originalDownPayment: Double = 0
    @State private var originalVacancy: Double = 0
    
    var scenarioDeal: PropertyDeal {
        var deal = viewModel.deal
        deal.monthlyRent = originalRent + rentAdjustment
        deal.interestRate = max(0.1, originalRate + interestRateAdjustment)
        deal.downPaymentPercent = min(100, max(0, originalDownPayment + downPaymentAdjustment))
        deal.vacancyRatePercent = min(30, max(0, originalVacancy + vacancyAdjustment))
        return deal
    }
    
    var originalResults: CalculationResults {
        CalculationService.calculateResults(for: viewModel.deal)
    }
    
    var scenarioResults: CalculationResults {
        CalculationService.calculateResults(for: scenarioDeal)
    }
    
    var cashFlowDifference: Double {
        scenarioResults.monthlyCashFlow - originalResults.monthlyCashFlow
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Comparison Header
                    HStack(spacing: 16) {
                        ComparisonColumn(
                            title: "Original",
                            cashFlow: originalResults.monthlyCashFlow,
                            cocReturn: originalResults.cashOnCashReturn
                        )
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.textMuted)
                        
                        ComparisonColumn(
                            title: "Scenario",
                            cashFlow: scenarioResults.monthlyCashFlow,
                            cocReturn: scenarioResults.cashOnCashReturn,
                            isScenario: true
                        )
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Difference Badge
                    if rentAdjustment != 0 || interestRateAdjustment != 0 || 
                       downPaymentAdjustment != 0 || vacancyAdjustment != 0 {
                        DifferenceBadge(difference: cashFlowDifference)
                    }
                    
                    // Adjustment Sliders
                    VStack(spacing: 16) {
                        Text("ADJUST SCENARIO")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Rent Adjustment
                        AdjustmentSlider(
                            title: "Rent Adjustment",
                            value: $rentAdjustment,
                            range: -500...500,
                            step: 25,
                            format: .currency,
                            subtitle: "What if rent is \(formatCurrency(originalRent + rentAdjustment))?"
                        )
                        
                        // Interest Rate Adjustment
                        AdjustmentSlider(
                            title: "Interest Rate",
                            value: $interestRateAdjustment,
                            range: -3...3,
                            step: 0.25,
                            format: .percentage,
                            subtitle: "What if rate is \(String(format: "%.2f", originalRate + interestRateAdjustment))%?"
                        )
                        
                        // Down Payment Adjustment
                        AdjustmentSlider(
                            title: "Down Payment",
                            value: $downPaymentAdjustment,
                            range: -20...30,
                            step: 5,
                            format: .percentage,
                            subtitle: "What if down payment is \(Int(originalDownPayment + downPaymentAdjustment))%?"
                        )
                        
                        // Vacancy Adjustment
                        AdjustmentSlider(
                            title: "Vacancy Rate",
                            value: $vacancyAdjustment,
                            range: -8...12,
                            step: 1,
                            format: .percentage,
                            subtitle: "What if vacancy is \(Int(originalVacancy + vacancyAdjustment))%?"
                        )
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Quick Scenarios
                    VStack(alignment: .leading, spacing: 12) {
                        Text("QUICK SCENARIOS")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        HStack(spacing: 12) {
                            QuickScenarioButton(title: "Rates Drop 1%") {
                                withAnimation { interestRateAdjustment = -1 }
                            }
                            
                            QuickScenarioButton(title: "+$200 Rent") {
                                withAnimation { rentAdjustment = 200 }
                            }
                        }
                        
                        HStack(spacing: 12) {
                            QuickScenarioButton(title: "25% Down") {
                                withAnimation { downPaymentAdjustment = 5 }
                            }
                            
                            QuickScenarioButton(title: "Reset All") {
                                withAnimation {
                                    rentAdjustment = 0
                                    interestRateAdjustment = 0
                                    downPaymentAdjustment = 0
                                    vacancyAdjustment = 0
                                }
                            }
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Apply Button
                    Button(action: applyScenario) {
                        Text("Apply This Scenario")
                            .font(AppFonts.button)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppColors.primaryGradient)
                            .cornerRadius(14)
                    }
                }
                .padding()
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("What If?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .onAppear {
                // Store original values
                originalRent = viewModel.deal.monthlyRent
                originalRate = viewModel.deal.interestRate
                originalDownPayment = viewModel.deal.downPaymentPercent
                originalVacancy = viewModel.deal.vacancyRatePercent
            }
        }
    }
    
    private func applyScenario() {
        viewModel.deal.monthlyRent = originalRent + rentAdjustment
        viewModel.deal.interestRate = max(0.1, originalRate + interestRateAdjustment)
        viewModel.deal.downPaymentPercent = min(100, max(0, originalDownPayment + downPaymentAdjustment))
        viewModel.deal.vacancyRatePercent = min(30, max(0, originalVacancy + vacancyAdjustment))
        dismiss()
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

// MARK: - Comparison Column

struct ComparisonColumn: View {
    let title: String
    let cashFlow: Double
    let cocReturn: Double
    var isScenario: Bool = false
    
    var body: some View {
        VStack(spacing: 12) {
            Text(title.uppercased())
                .font(AppFonts.caption2)
                .foregroundColor(AppColors.textMuted)
            
            Text(formatCurrency(cashFlow))
                .font(AppFonts.metricValueMedium)
                .foregroundColor(cashFlow >= 0 ? AppColors.successGreen : AppColors.dangerRed)
            
            Text("Cash Flow/mo")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textMuted)
            
            Text(String(format: "%.1f%%", cocReturn))
                .font(AppFonts.bodyBold)
                .foregroundColor(AppColors.textPrimary)
            
            Text("CoC Return")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(isScenario ? AppColors.primaryTeal.opacity(0.1) : AppColors.inputBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isScenario ? AppColors.primaryTeal.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let prefix = value >= 0 ? "+" : ""
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return prefix + (formatter.string(from: NSNumber(value: value)) ?? "$0")
    }
}

// MARK: - Difference Badge

struct DifferenceBadge: View {
    let difference: Double
    
    var isPositive: Bool { difference >= 0 }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isPositive ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                .font(.system(size: 20))
            
            Text("\(isPositive ? "+" : "")\(formatCurrency(difference))/month")
                .font(AppFonts.bodyBold)
        }
        .foregroundColor(isPositive ? AppColors.successGreen : AppColors.dangerRed)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            (isPositive ? AppColors.successGreen : AppColors.dangerRed).opacity(0.15)
        )
        .cornerRadius(12)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

// MARK: - Adjustment Slider

struct AdjustmentSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let format: AdjustmentFormat
    let subtitle: String
    
    enum AdjustmentFormat {
        case currency
        case percentage
    }
    
    var formattedValue: String {
        let prefix = value >= 0 ? "+" : ""
        switch format {
        case .currency:
            return prefix + "$\(Int(value))"
        case .percentage:
            return prefix + String(format: "%.2f%%", value)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Text(formattedValue)
                    .font(AppFonts.bodyBold)
                    .foregroundColor(value != 0 ? AppColors.textAccent : AppColors.textMuted)
            }
            
            Slider(value: $value, in: range, step: step)
                .tint(AppColors.primaryTeal)
            
            Text(subtitle)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textMuted)
        }
        .padding()
        .background(AppColors.inputBackground)
        .cornerRadius(12)
    }
}

// MARK: - Quick Scenario Button

struct QuickScenarioButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.primaryTeal)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(AppColors.primaryTeal.opacity(0.1))
                .cornerRadius(8)
        }
    }
}

#Preview {
    ScenarioTestingView(viewModel: {
        let vm = DealViewModel()
        vm.deal = .sampleDeal
        return vm
    }())
}
