//
//  DealComparisonView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/17.
//

import SwiftUI

/// Side-by-side comparison of up to 3 properties
struct DealComparisonView: View {
    @Bindable var viewModel: DealViewModel
    @State private var selectedDeals: Set<UUID> = []
    @State private var comparisonMetric: ComparisonMetric = .cashFlow
    
    enum ComparisonMetric: String, CaseIterable {
        case cashFlow = "Cash Flow"
        case cocReturn = "CoC Return"
        case capRate = "Cap Rate"
    }
    
    var dealsToCompare: [PropertyDeal] {
        viewModel.savedDeals.filter { selectedDeals.contains($0.id) }
    }
    
    var winnerDeal: PropertyDeal? {
        guard !dealsToCompare.isEmpty else { return nil }
        
        return dealsToCompare.max { deal1, deal2 in
            let results1 = CalculationService.calculateResults(for: deal1)
            let results2 = CalculationService.calculateResults(for: deal2)
            
            switch comparisonMetric {
            case .cashFlow:
                return results1.monthlyCashFlow < results2.monthlyCashFlow
            case .cocReturn:
                return results1.cashOnCashReturn < results2.cashOnCashReturn
            case .capRate:
                return results1.capRate < results2.capRate
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Deal Selection
                if viewModel.savedDeals.isEmpty {
                    EmptyComparisonView()
                } else if selectedDeals.count < 2 {
                    DealSelectionView(
                        savedDeals: viewModel.savedDeals,
                        selectedDeals: $selectedDeals
                    )
                } else {
                    // Comparison View
                    VStack(spacing: 16) {
                        // Metric Selector
                        HStack(spacing: 0) {
                            ForEach(ComparisonMetric.allCases, id: \.self) { metric in
                                Button(action: { comparisonMetric = metric }) {
                                    Text(metric.rawValue)
                                        .font(AppFonts.caption)
                                        .foregroundColor(comparisonMetric == metric ? .white : AppColors.textSecondary)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(comparisonMetric == metric ? AppColors.primaryTeal : Color.clear)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(4)
                        .background(AppColors.cardBackground)
                        .cornerRadius(12)
                        
                        // Comparison Grid
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(dealsToCompare) { deal in
                                    ComparisonDealColumn(
                                        deal: deal,
                                        isWinner: deal.id == winnerDeal?.id,
                                        comparisonMetric: comparisonMetric
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Edit Selection Button
                        Button(action: {
                            selectedDeals.removeAll()
                        }) {
                            Label("Change Selection", systemImage: "arrow.left.arrow.right")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.primaryTeal)
                        }
                        .padding(.bottom)
                    }
                    .padding(.top)
                }
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Compare Deals")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Deal Selection View

struct DealSelectionView: View {
    let savedDeals: [PropertyDeal]
    @Binding var selectedDeals: Set<UUID>
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Select 2-3 deals to compare")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
            
            Text("\(selectedDeals.count)/3 selected")
                .font(AppFonts.bodyBold)
                .foregroundColor(AppColors.primaryTeal)
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(savedDeals) { deal in
                        SelectableDealCard(
                            deal: deal,
                            isSelected: selectedDeals.contains(deal.id)
                        ) {
                            if selectedDeals.contains(deal.id) {
                                selectedDeals.remove(deal.id)
                            } else if selectedDeals.count < 3 {
                                selectedDeals.insert(deal.id)
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
}

struct SelectableDealCard: View {
    let deal: PropertyDeal
    let isSelected: Bool
    let action: () -> Void
    
    var results: CalculationResults {
        CalculationService.calculateResults(for: deal)
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? AppColors.primaryTeal : AppColors.textMuted)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(deal.name.isEmpty ? "Untitled Deal" : deal.name)
                        .font(AppFonts.bodyBold)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(formatCurrency(deal.purchasePrice))
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(formatCurrency(results.monthlyCashFlow, showSign: true))
                        .font(AppFonts.bodyBold)
                        .foregroundColor(results.monthlyCashFlow >= 0 ? AppColors.successGreen : AppColors.dangerRed)
                    
                    Text("/month")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textMuted)
                }
            }
            .padding(16)
            .background(isSelected ? AppColors.primaryTeal.opacity(0.1) : AppColors.cardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? AppColors.primaryTeal : AppColors.border, lineWidth: isSelected ? 2 : 1)
            )
        }
    }
    
    private func formatCurrency(_ value: Double, showSign: Bool = false) -> String {
        let prefix = showSign && value > 0 ? "+" : ""
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return prefix + (formatter.string(from: NSNumber(value: value)) ?? "$0")
    }
}

// MARK: - Comparison Column

struct ComparisonDealColumn: View {
    let deal: PropertyDeal
    let isWinner: Bool
    let comparisonMetric: DealComparisonView.ComparisonMetric
    
    var results: CalculationResults {
        CalculationService.calculateResults(for: deal)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Winner Badge
            if isWinner {
                HStack(spacing: 4) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 12))
                    Text("BEST")
                        .font(AppFonts.caption2)
                        .fontWeight(.bold)
                }
                .foregroundColor(AppColors.warningAmber)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(AppColors.warningAmber.opacity(0.2))
                .cornerRadius(20)
            }
            
            // Deal Name
            Text(deal.name.isEmpty ? "Untitled" : deal.name)
                .font(AppFonts.bodyBold)
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(1)
            
            // Primary Metric (highlighted)
            VStack(spacing: 4) {
                Text(primaryMetricValue)
                    .font(AppFonts.metricValue)
                    .foregroundColor(primaryMetricColor)
                
                Text(comparisonMetric.rawValue)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(isWinner ? AppColors.primaryTeal.opacity(0.15) : AppColors.inputBackground)
            .cornerRadius(12)
            
            Divider()
                .background(AppColors.divider)
            
            // All Metrics
            VStack(spacing: 8) {
                ComparisonMetricRow(label: "Purchase Price", value: formatCurrency(deal.purchasePrice))
                ComparisonMetricRow(label: "Monthly Rent", value: formatCurrency(deal.monthlyRent))
                ComparisonMetricRow(label: "Cash Flow", value: formatCurrency(results.monthlyCashFlow, showSign: true), 
                                   valueColor: results.monthlyCashFlow >= 0 ? AppColors.successGreen : AppColors.dangerRed)
                ComparisonMetricRow(label: "CoC Return", value: String(format: "%.1f%%", results.cashOnCashReturn))
                ComparisonMetricRow(label: "Cap Rate", value: String(format: "%.1f%%", results.capRate))
                ComparisonMetricRow(label: "Cash Needed", value: formatCurrency(results.totalCashNeeded))
            }
        }
        .padding(16)
        .frame(width: 180)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isWinner ? AppColors.primaryTeal : AppColors.border, lineWidth: isWinner ? 2 : 1)
        )
    }
    
    private var primaryMetricValue: String {
        switch comparisonMetric {
        case .cashFlow:
            return formatCurrency(results.monthlyCashFlow, showSign: true)
        case .cocReturn:
            return String(format: "%.1f%%", results.cashOnCashReturn)
        case .capRate:
            return String(format: "%.1f%%", results.capRate)
        }
    }
    
    private var primaryMetricColor: Color {
        switch comparisonMetric {
        case .cashFlow:
            return results.monthlyCashFlow >= 0 ? AppColors.successGreen : AppColors.dangerRed
        case .cocReturn, .capRate:
            return AppColors.textAccent
        }
    }
    
    private func formatCurrency(_ value: Double, showSign: Bool = false) -> String {
        let prefix = showSign && value > 0 ? "+" : ""
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return prefix + (formatter.string(from: NSNumber(value: value)) ?? "$0")
    }
}

struct ComparisonMetricRow: View {
    let label: String
    let value: String
    var valueColor: Color = AppColors.textPrimary
    
    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(AppFonts.caption2)
                .foregroundColor(AppColors.textMuted)
            
            Text(value)
                .font(AppFonts.caption)
                .fontWeight(.semibold)
                .foregroundColor(valueColor)
        }
    }
}

// MARK: - Empty State

struct EmptyComparisonView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.stack.3d.up")
                .font(.system(size: 56))
                .foregroundColor(AppColors.primaryTeal.opacity(0.5))
            
            Text("No Deals to Compare")
                .font(AppFonts.title)
                .foregroundColor(AppColors.textPrimary)
            
            Text("Save at least 2 deals to compare them side-by-side")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

#Preview {
    DealComparisonView(viewModel: {
        let vm = DealViewModel()
        var deal1 = PropertyDeal.sampleDeal
        deal1.name = "123 Oak Street"
        
        var deal2 = PropertyDeal.sampleDeal
        deal2.id = UUID()
        deal2.name = "456 Pine Avenue"
        deal2.purchasePrice = 275000
        deal2.monthlyRent = 2000
        
        vm.savedDeals = [deal1, deal2]
        return vm
    }())
}
