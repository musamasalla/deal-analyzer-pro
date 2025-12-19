//
//  RecentDealsWidget.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/18.
//

import SwiftUI

/// Recent deals quick access widget
struct RecentDealsWidget: View {
    @Bindable var viewModel: DealViewModel
    let onDealSelected: (PropertyDeal) -> Void
    
    var recentDeals: [PropertyDeal] {
        Array(viewModel.savedDeals.prefix(5))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("RECENT DEALS")
                    .font(AppFonts.metricLabel)
                    .foregroundColor(AppColors.textSecondary)
                
                Spacer()
                
                if !recentDeals.isEmpty {
                    NavigationLink(destination: SavedDealsListView(viewModel: viewModel)) {
                        Text("View All")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.primaryTeal)
                    }
                }
            }
            
            if recentDeals.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 32))
                        .foregroundColor(AppColors.textMuted)
                    
                    Text("No saved deals yet")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textMuted)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                ForEach(recentDeals) { deal in
                    RecentDealRow(deal: deal) {
                        onDealSelected(deal)
                    }
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
}

struct RecentDealRow: View {
    let deal: PropertyDeal
    let action: () -> Void
    
    var cashFlow: Double {
        CalculationService.calculateResults(for: deal).monthlyCashFlow
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Property type icon
                Image(systemName: deal.propertyType.icon)
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.primaryTeal)
                    .frame(width: 36, height: 36)
                    .background(AppColors.primaryTeal.opacity(0.1))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(deal.name.isEmpty ? "Untitled Deal" : deal.name)
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)
                    
                    Text(formatCurrency(deal.purchasePrice))
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textMuted)
                }
                
                Spacer()
                
                // Cash flow badge
                Text(formatCashFlow(cashFlow))
                    .font(AppFonts.caption)
                    .foregroundColor(cashFlow >= 0 ? AppColors.successGreen : AppColors.dangerRed)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background((cashFlow >= 0 ? AppColors.successGreen : AppColors.dangerRed).opacity(0.1))
                    .cornerRadius(6)
            }
            .padding(.vertical, 4)
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
    
    private func formatCashFlow(_ value: Double) -> String {
        let prefix = value >= 0 ? "+" : ""
        return prefix + formatCurrency(value) + "/mo"
    }
}

// Note: PropertyType.icon is defined in PropertyType.swift

#Preview {
    VStack {
        RecentDealsWidget(viewModel: {
            let vm = DealViewModel()
            vm.savedDeals = [.sampleDeal]
            return vm
        }()) { deal in
            print("Selected: \(deal.name)")
        }
    }
    .padding()
    .background(AppColors.background)
}
