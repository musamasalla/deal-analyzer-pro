//
//  FiveYearProjectionView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/17.
//

import SwiftUI

/// 5-Year Projection detailed view
struct FiveYearProjectionView: View {
    @Bindable var viewModel: DealViewModel
    @Environment(\.dismiss) private var dismiss
    
    var projection: FiveYearProjection {
        viewModel.results.fiveYearProjection
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Card
                    VStack(spacing: 16) {
                        Text("5-YEAR TOTAL RETURN")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                            .tracking(0.5)
                        
                        Text(formatCurrency(projection.totalReturn))
                            .font(AppFonts.cashFlowDisplay)
                            .foregroundColor(projection.totalReturn >= 0 ? AppColors.successGreen : AppColors.dangerRed)
                        
                        if viewModel.results.totalCashNeeded > 0 {
                            Text("\(formatPercent(projection.returnOnInvestment)) Total ROI")
                                .font(AppFonts.title2)
                                .foregroundColor(AppColors.textAccent)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .background(
                        LinearGradient(
                            colors: [AppColors.cardBackground, AppColors.elevatedBackground],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(20)
                    
                    // Breakdown Cards
                    VStack(spacing: 12) {
                        ProjectionCard(
                            title: "Cash Flow",
                            value: projection.totalCashFlow,
                            icon: "dollarsign.circle.fill",
                            description: "Total rental profit over 5 years"
                        )
                        
                        ProjectionCard(
                            title: "Equity Buildup",
                            value: projection.totalEquityBuildup,
                            icon: "chart.bar.fill",
                            description: "Principal paid down from mortgage"
                        )
                        
                        ProjectionCard(
                            title: "Appreciation",
                            value: projection.totalAppreciation,
                            icon: "arrow.up.right",
                            description: "At \(String(format: "%.1f", viewModel.deal.appreciationRatePercent))% annual appreciation"
                        )
                    }
                    
                    // Property Value Projection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("PROPERTY VALUE")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                            .tracking(0.5)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Today")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.textMuted)
                                
                                Text(formatCurrency(viewModel.deal.purchasePrice))
                                    .font(AppFonts.bodyBold)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.right")
                                .foregroundColor(AppColors.primaryTeal)
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Year 5")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.textMuted)
                                
                                Text(formatCurrency(projection.projectedPropertyValue))
                                    .font(AppFonts.bodyBold)
                                    .foregroundColor(AppColors.successGreen)
                            }
                        }
                        
                        // Appreciation Rate Slider
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Appreciation Rate")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.textMuted)
                                
                                Spacer()
                                
                                Text("\(String(format: "%.1f", viewModel.deal.appreciationRatePercent))%/year")
                                    .font(AppFonts.bodyBold)
                                    .foregroundColor(AppColors.textAccent)
                            }
                            
                            Slider(value: $viewModel.deal.appreciationRatePercent, in: 0...10, step: 0.5)
                                .tint(AppColors.primaryTeal)
                        }
                    }
                    .padding(16)
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Loan Payoff
                    if !viewModel.deal.isCashPurchase {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("LOAN STATUS AT YEAR 5")
                                .font(AppFonts.metricLabel)
                                .foregroundColor(AppColors.textSecondary)
                                .tracking(0.5)
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Original Loan")
                                        .font(AppFonts.caption)
                                        .foregroundColor(AppColors.textMuted)
                                    
                                    Text(formatCurrency(viewModel.deal.loanAmount))
                                        .font(AppFonts.bodyBold)
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Remaining Balance")
                                        .font(AppFonts.caption)
                                        .foregroundColor(AppColors.textMuted)
                                    
                                    Text(formatCurrency(projection.remainingLoanBalance))
                                        .font(AppFonts.bodyBold)
                                        .foregroundColor(AppColors.textPrimary)
                                }
                            }
                            
                            // Progress Bar
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(AppColors.inputBackground)
                                    
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(AppColors.primaryTeal)
                                        .frame(width: geo.size.width * paidOffPercent)
                                }
                            }
                            .frame(height: 8)
                            
                            Text("\(String(format: "%.1f", paidOffPercent * 100))% paid off in 5 years")
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.textMuted)
                        }
                        .padding(16)
                        .background(AppColors.cardBackground)
                        .cornerRadius(16)
                    }
                }
                .padding()
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("5-Year Projection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AppColors.primaryTeal)
                }
            }
        }
    }
    
    private var paidOffPercent: Double {
        guard viewModel.deal.loanAmount > 0 else { return 0 }
        return (viewModel.deal.loanAmount - projection.remainingLoanBalance) / viewModel.deal.loanAmount
    }
    
    private func formatCurrency(_ value: Double) -> String {
        return CurrencyFormatter.format(value)
    }
    
    private func formatPercent(_ value: Double) -> String {
        return String(format: "%.1f%%", value)
    }
}

struct ProjectionCard: View {
    let title: String
    let value: Double
    let icon: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(AppColors.primaryTeal)
                .frame(width: 44, height: 44)
                .background(AppColors.primaryTeal.opacity(0.15))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppFonts.bodyBold)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(description)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)
            }
            
            Spacer()
            
            Text(formatCurrency(value))
                .font(AppFonts.title2)
                .foregroundColor(value >= 0 ? AppColors.successGreen : AppColors.dangerRed)
        }
        .padding(16)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        return CurrencyFormatter.format(value, showSign: true)
    }
}

#Preview {
    FiveYearProjectionView(viewModel: {
        let vm = DealViewModel()
        vm.deal = .sampleDeal
        return vm
    }())
}
