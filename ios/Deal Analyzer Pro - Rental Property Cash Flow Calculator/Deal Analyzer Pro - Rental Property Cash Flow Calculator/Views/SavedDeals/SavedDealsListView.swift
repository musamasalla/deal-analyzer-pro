//
//  SavedDealsListView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/17.
//

import SwiftUI

/// List of saved deals with sorting options
struct SavedDealsListView: View {
    @Bindable var viewModel: DealViewModel
    @State private var sortOption: DealSortOption = .dateNewest
    @State private var showingSortMenu: Bool = false
    @State private var selectedDeal: PropertyDeal?
    
    var sortedDeals: [PropertyDeal] {
        switch sortOption {
        case .dateNewest:
            return viewModel.savedDeals.sorted { $0.updatedAt > $1.updatedAt }
        case .dateOldest:
            return viewModel.savedDeals.sorted { $0.updatedAt < $1.updatedAt }
        case .cashFlowHighest:
            return viewModel.savedDeals.sorted { dealCashFlow($0) > dealCashFlow($1) }
        case .cashFlowLowest:
            return viewModel.savedDeals.sorted { dealCashFlow($0) < dealCashFlow($1) }
        case .cocReturnHighest:
            return viewModel.savedDeals.sorted { dealCoC($0) > dealCoC($1) }
        case .capRateHighest:
            return viewModel.savedDeals.sorted { dealCapRate($0) > dealCapRate($1) }
        case .priceLowest:
            return viewModel.savedDeals.sorted { $0.purchasePrice < $1.purchasePrice }
        case .priceHighest:
            return viewModel.savedDeals.sorted { $0.purchasePrice > $1.purchasePrice }
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.savedDeals.isEmpty {
                    EmptySavedDealsView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(sortedDeals) { deal in
                                SavedDealCard(deal: deal, viewModel: viewModel)
                                    .onTapGesture {
                                        selectedDeal = deal
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Saved Deals")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        ForEach(DealSortOption.allCases, id: \.self) { option in
                            Button(action: { sortOption = option }) {
                                HStack {
                                    Text(option.rawValue)
                                    if sortOption == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .foregroundColor(AppColors.primaryTeal)
                    }
                }
            }
            .sheet(item: $selectedDeal) { deal in
                DealDetailSheet(deal: deal, viewModel: viewModel)
            }
        }
    }
    
    private func dealCashFlow(_ deal: PropertyDeal) -> Double {
        CalculationService.calculateResults(for: deal).monthlyCashFlow
    }
    
    private func dealCoC(_ deal: PropertyDeal) -> Double {
        CalculationService.calculateResults(for: deal).cashOnCashReturn
    }
    
    private func dealCapRate(_ deal: PropertyDeal) -> Double {
        CalculationService.calculateResults(for: deal).capRate
    }
}

// MARK: - Saved Deal Card

struct SavedDealCard: View {
    let deal: PropertyDeal
    @Bindable var viewModel: DealViewModel
    
    var results: CalculationResults {
        CalculationService.calculateResults(for: deal)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(deal.name.isEmpty ? "Untitled Deal" : deal.name)
                        .font(AppFonts.bodyBold)
                        .foregroundColor(AppColors.textPrimary)
                    
                    if !deal.address.isEmpty {
                        Text(deal.address)
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textMuted)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Rating Stars
                if deal.rating > 0 {
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= deal.rating ? "star.fill" : "star")
                                .font(.system(size: 10))
                                .foregroundColor(star <= deal.rating ? AppColors.warningAmber : AppColors.textMuted)
                        }
                    }
                }
            }
            
            // Property Info
            HStack(spacing: 16) {
                Label(CurrencyFormatter.format(deal.purchasePrice), systemImage: "dollarsign.circle")
                Label("\(deal.bedrooms)bd/\(String(format: "%.0f", deal.bathrooms))ba", systemImage: "bed.double")
                Label(deal.propertyType.rawValue, systemImage: deal.propertyType.iconName)
            }
            .font(AppFonts.caption)
            .foregroundColor(AppColors.textSecondary)
            
            Divider()
                .background(AppColors.divider)
            
            // Key Metrics
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Cash Flow")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textMuted)
                    
                    Text(CurrencyFormatter.format(results.monthlyCashFlow, showSign: true))
                        .font(AppFonts.bodyBold)
                        .foregroundColor(results.monthlyCashFlow >= 0 ? AppColors.successGreen : AppColors.dangerRed)
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: 2) {
                    Text("CoC Return")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textMuted)
                    
                    Text(String(format: "%.1f%%", results.cashOnCashReturn))
                        .font(AppFonts.bodyBold)
                        .foregroundColor(AppColors.textPrimary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Cap Rate")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textMuted)
                    
                    Text(String(format: "%.1f%%", results.capRate))
                        .font(AppFonts.bodyBold)
                        .foregroundColor(AppColors.textPrimary)
                }
            }
            
            // Date
            Text("Saved \(deal.updatedAt.formatted(date: .abbreviated, time: .omitted))")
                .font(AppFonts.caption2)
                .foregroundColor(AppColors.textMuted)
        }
        .padding(16)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.border, lineWidth: 1)
        )
        .contextMenu {
            Button(action: { viewModel.loadDeal(deal) }) {
                Label("Edit Deal", systemImage: "pencil")
            }
            
            Button(role: .destructive, action: {
                if let index = viewModel.savedDeals.firstIndex(where: { $0.id == deal.id }) {
                    viewModel.savedDeals.remove(at: index)
                }
            }) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - Empty State

struct EmptySavedDealsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 56))
                .foregroundColor(AppColors.primaryTeal.opacity(0.5))
            
            Text("No Saved Deals")
                .font(AppFonts.title)
                .foregroundColor(AppColors.textPrimary)
            
            Text("Analyze a property and save it to compare deals side-by-side")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }
}

// MARK: - Deal Detail Sheet

struct DealDetailSheet: View {
    let deal: PropertyDeal
    @Bindable var viewModel: DealViewModel
    @Environment(\.dismiss) private var dismiss
    
    var results: CalculationResults {
        CalculationService.calculateResults(for: deal)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Cash Flow Card
                    CashFlowCard(
                        monthlyCashFlow: results.monthlyCashFlow,
                        annualCashFlow: results.annualCashFlow
                    )
                    
                    // Property Summary
                    VStack(alignment: .leading, spacing: 12) {
                        Text("PROPERTY DETAILS")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        VStack(spacing: 8) {
                            SummaryRow(label: "Purchase Price", value: CurrencyFormatter.format(deal.purchasePrice))
                            SummaryRow(label: "Monthly Rent", value: CurrencyFormatter.format(deal.monthlyRent))
                            SummaryRow(label: "Property Type", value: deal.propertyType.rawValue)
                            SummaryRow(label: "Beds/Baths", value: "\(deal.bedrooms) / \(String(format: "%.1f", deal.bathrooms))")
                        }
                    }
                    .padding(16)
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Actions
                    VStack(spacing: 12) {
                        Button(action: {
                            viewModel.loadDeal(deal)
                            dismiss()
                        }) {
                            Label("Edit This Deal", systemImage: "pencil")
                                .font(AppFonts.button)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppColors.primaryGradient)
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            viewModel.loadDeal(deal)
                            viewModel.startScenario()
                            dismiss()
                        }) {
                            Label("Create Scenario", systemImage: "slider.horizontal.3")
                                .font(AppFonts.button)
                                .foregroundColor(AppColors.primaryTeal)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppColors.primaryTeal.opacity(0.15))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle(deal.name.isEmpty ? "Deal Details" : deal.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AppColors.primaryTeal)
                }
            }
        }
    }
}

#Preview {
    SavedDealsListView(viewModel: {
        let vm = DealViewModel()
        vm.savedDeals = [.sampleDeal]
        return vm
    }())
}
