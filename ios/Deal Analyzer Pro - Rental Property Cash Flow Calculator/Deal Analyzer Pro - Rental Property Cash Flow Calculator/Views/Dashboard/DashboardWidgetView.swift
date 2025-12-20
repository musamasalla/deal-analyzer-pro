//
//  DashboardWidgetView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/18.
//

import SwiftUI

/// Quick stats widget for iPad sidebar or dashboard
struct DashboardWidgetView: View {
    @Bindable var viewModel: DealViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Quick Stats Header
            HStack {
                Text("QUICK STATS")
                    .font(AppFonts.metricLabel)
                    .foregroundColor(AppColors.textSecondary)
                
                Spacer()
                
                PulsingDot(color: AppColors.successGreen)
                Text("Live")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)
            }
            
            // Main Cash Flow
            VStack(spacing: 4) {
                Text(formatCurrency(viewModel.results.monthlyCashFlow))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(viewModel.results.monthlyCashFlow >= 0 ? AppColors.successGreen : AppColors.dangerRed)
                
                Text("Monthly Cash Flow")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            
            Divider().background(AppColors.divider)
            
            // Quick Metrics Row
            HStack(spacing: 0) {
                WidgetMetric(
                    label: "CoC",
                    value: String(format: "%.1f%%", viewModel.results.cashOnCashReturn),
                    color: metricColor(viewModel.results.cashOnCashReturn, threshold: 8)
                )
                
                Divider()
                    .frame(height: 40)
                    .background(AppColors.divider)
                
                WidgetMetric(
                    label: "Cap",
                    value: String(format: "%.1f%%", viewModel.results.capRate),
                    color: metricColor(viewModel.results.capRate, threshold: 6)
                )
                
                Divider()
                    .frame(height: 40)
                    .background(AppColors.divider)
                
                WidgetMetric(
                    label: "DSCR",
                    value: String(format: "%.2f", viewModel.results.debtServiceCoverageRatio),
                    color: viewModel.results.debtServiceCoverageRatio >= 1.25 ? AppColors.successGreen : AppColors.warningAmber
                )
            }
            
            // Saved Deals Count
            if !viewModel.savedDeals.isEmpty {
                Divider().background(AppColors.divider)
                
                HStack {
                    Image(systemName: "folder.fill")
                        .foregroundColor(AppColors.primaryTeal)
                    
                    Text("\(viewModel.savedDeals.count) saved deals")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Spacer()
                }
                .padding(.top, 4)
            }
        }
        .padding(16)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        return CurrencyFormatter.format(value, showSign: true)
    }
    
    private func metricColor(_ value: Double, threshold: Double) -> Color {
        if value >= threshold { return AppColors.successGreen }
        if value >= threshold * 0.8 { return AppColors.primaryTeal }
        if value > 0 { return AppColors.warningAmber }
        return AppColors.dangerRed
    }
}

struct WidgetMetric: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(AppFonts.bodyBold)
                .foregroundColor(color)
            
            Text(label)
                .font(AppFonts.caption2)
                .foregroundColor(AppColors.textMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    DashboardWidgetView(viewModel: {
        let vm = DealViewModel()
        vm.deal = .sampleDeal
        return vm
    }())
    .padding()
    .background(AppColors.background)
}
