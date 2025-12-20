//
//  ROICalculatorView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/18.
//

import SwiftUI

/// Return on Investment Calculator for different investment strategies
struct ROICalculatorView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var initialInvestment: Double = 50000
    @State private var projectedReturn: Double = 65000
    @State private var holdingPeriodMonths: Int = 12
    @State private var additionalCosts: Double = 5000
    
    var totalInvested: Double {
        initialInvestment + additionalCosts
    }
    
    var profit: Double {
        projectedReturn - totalInvested
    }
    
    var roi: Double {
        guard totalInvested > 0 else { return 0 }
        return (profit / totalInvested) * 100
    }
    
    var annualizedROI: Double {
        guard holdingPeriodMonths > 0, totalInvested > 0 else { return 0 }
        let years = Double(holdingPeriodMonths) / 12.0
        // Annualized return = ((1 + ROI)^(1/years) - 1) * 100
        let totalReturn = projectedReturn / totalInvested
        guard totalReturn > 0, years > 0 else { return 0 }
        return (pow(totalReturn, 1/years) - 1) * 100
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Results Display
                    VStack(spacing: 20) {
                        HStack(spacing: 20) {
                            ROIMetric(
                                title: "Total ROI",
                                value: String(format: "%.1f%%", roi),
                                color: roi >= 0 ? AppColors.successGreen : AppColors.dangerRed
                            )
                            
                            ROIMetric(
                                title: "Annualized",
                                value: String(format: "%.1f%%", annualizedROI),
                                color: annualizedROI >= 10 ? AppColors.successGreen : AppColors.primaryTeal
                            )
                        }
                        
                        VStack(spacing: 8) {
                            Text("Net Profit")
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.textMuted)
                            
                            Text(formatCurrency(profit))
                                .font(AppFonts.cashFlowDisplay)
                                .foregroundColor(profit >= 0 ? AppColors.successGreen : AppColors.dangerRed)
                        }
                    }
                    .padding(24)
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Inputs
                    VStack(alignment: .leading, spacing: 16) {
                        Text("INVESTMENT DETAILS")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        CurrencyTextField(
                            title: "Initial Investment",
                            value: $initialInvestment,
                            placeholder: "50000"
                        )
                        
                        CurrencyTextField(
                            title: "Additional Costs",
                            value: $additionalCosts,
                            placeholder: "5000"
                        )
                        
                        CurrencyTextField(
                            title: "Projected Return/Sale Price",
                            value: $projectedReturn,
                            placeholder: "65000"
                        )
                        
                        HStack {
                            Text("Holding Period")
                                .font(AppFonts.fieldLabel)
                                .foregroundColor(AppColors.textSecondary)
                            
                            Spacer()
                            
                            Stepper("\(holdingPeriodMonths) months", value: $holdingPeriodMonths, in: 1...120)
                                .frame(width: 180)
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Summary
                    VStack(alignment: .leading, spacing: 12) {
                        Text("INVESTMENT SUMMARY")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        SummaryRow(label: "Initial Investment", value: formatCurrency(initialInvestment))
                        SummaryRow(label: "Additional Costs", value: formatCurrency(additionalCosts))
                        
                        Divider().background(AppColors.divider)
                        
                        SummaryRow(label: "Total Invested", value: formatCurrency(totalInvested), isHighlighted: true)
                        SummaryRow(label: "Projected Return", value: formatCurrency(projectedReturn))
                        
                        Divider().background(AppColors.divider)
                        
                        SummaryRow(label: "Net Profit", value: formatCurrency(profit), isHighlighted: true)
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Benchmark comparison
                    VStack(alignment: .leading, spacing: 12) {
                        Text("BENCHMARK COMPARISON")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        BenchmarkRow(name: "S&P 500 Avg", value: 10, yourValue: annualizedROI)
                        BenchmarkRow(name: "Real Estate Avg", value: 8, yourValue: annualizedROI)
                        BenchmarkRow(name: "Bonds Avg", value: 5, yourValue: annualizedROI)
                        BenchmarkRow(name: "Savings Account", value: 4, yourValue: annualizedROI)
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                }
                .padding()
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("ROI Calculator")
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

// MARK: - ROI Metric

struct ROIMetric: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(AppFonts.metricValue)
                .foregroundColor(color)
            
            Text(title)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.inputBackground)
        .cornerRadius(12)
    }
}

// MARK: - Benchmark Row

struct BenchmarkRow: View {
    let name: String
    let value: Double
    let yourValue: Double
    
    var isBetter: Bool {
        yourValue > value
    }
    
    var body: some View {
        HStack {
            Text(name)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
            
            Spacer()
            
            Text(String(format: "%.1f%%", value))
                .font(AppFonts.body)
                .foregroundColor(AppColors.textMuted)
            
            Image(systemName: isBetter ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                .foregroundColor(isBetter ? AppColors.successGreen : AppColors.dangerRed)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ROICalculatorView()
}
