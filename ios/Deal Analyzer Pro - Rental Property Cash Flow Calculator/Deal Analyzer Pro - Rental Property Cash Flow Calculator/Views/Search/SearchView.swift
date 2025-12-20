//
//  SearchView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/18.
//

import SwiftUI

/// Search across all saved deals
struct SearchView: View {
    @Bindable var viewModel: DealViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText: String = ""
    @State private var filterType: PropertyType? = nil
    @State private var sortBy: SearchSortOption = .dateNewest
    
    enum SearchSortOption: String, CaseIterable {
        case dateNewest = "Newest"
        case dateOldest = "Oldest"
        case cashFlowHighest = "Best Cash Flow"
        case priceLowest = "Lowest Price"
    }
    
    var filteredDeals: [PropertyDeal] {
        var deals = viewModel.savedDeals
        
        // Filter by search text
        if !searchText.isEmpty {
            deals = deals.filter { deal in
                deal.name.localizedCaseInsensitiveContains(searchText) ||
                deal.address.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by property type
        if let filterType = filterType {
            deals = deals.filter { $0.propertyType == filterType }
        }
        
        // Sort
        switch sortBy {
        case .dateNewest:
            deals.sort { $0.createdAt > $1.createdAt }
        case .dateOldest:
            deals.sort { $0.createdAt < $1.createdAt }
        case .cashFlowHighest:
            deals.sort { 
                CalculationService.calculateResults(for: $0).monthlyCashFlow >
                CalculationService.calculateResults(for: $1).monthlyCashFlow
            }
        case .priceLowest:
            deals.sort { $0.purchasePrice < $1.purchasePrice }
        }
        
        return deals
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppColors.textMuted)
                    
                    TextField("Search deals...", text: $searchText)
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textPrimary)
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(AppColors.textMuted)
                        }
                    }
                }
                .padding(12)
                .background(AppColors.inputBackground)
                .cornerRadius(12)
                .padding()
                
                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        // Property Type Filter
                        Menu {
                            Button("All Types") { filterType = nil }
                            Divider()
                            ForEach(PropertyType.allCases, id: \.self) { type in
                                Button(type.displayName) { filterType = type }
                            }
                        } label: {
                            FilterChip(
                                title: filterType?.displayName ?? "Type",
                                isActive: filterType != nil
                            )
                        }
                        
                        // Sort
                        Menu {
                            ForEach(SearchSortOption.allCases, id: \.self) { option in
                                Button(option.rawValue) { sortBy = option }
                            }
                        } label: {
                            FilterChip(
                                title: "Sort: \(sortBy.rawValue)",
                                isActive: true
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 8)
                
                // Results
                if filteredDeals.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: searchText.isEmpty ? "folder.badge.questionmark" : "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(AppColors.textMuted)
                        
                        Text(searchText.isEmpty ? "No saved deals" : "No deals match your search")
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textMuted)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredDeals) { deal in
                            SearchResultRow(deal: deal) {
                                viewModel.loadDeal(deal)
                                dismiss()
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Search Deals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .font(AppFonts.caption)
            
            Image(systemName: "chevron.down")
                .font(.system(size: 10))
        }
        .foregroundColor(isActive ? AppColors.primaryTeal : AppColors.textSecondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isActive ? AppColors.primaryTeal.opacity(0.1) : AppColors.cardBackground)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isActive ? AppColors.primaryTeal : AppColors.border, lineWidth: 1)
        )
    }
}

// MARK: - Search Result Row

struct SearchResultRow: View {
    let deal: PropertyDeal
    let action: () -> Void
    
    var results: CalculationResults {
        CalculationService.calculateResults(for: deal)
    }
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(deal.name.isEmpty ? "Untitled Deal" : deal.name)
                        .font(AppFonts.bodyBold)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Text(formatCurrency(deal.purchasePrice))
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                HStack {
                    Label(deal.propertyType.displayName, systemImage: deal.propertyType.icon)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textMuted)
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Text("CF: \(formatCashFlow(results.monthlyCashFlow))")
                            .foregroundColor(results.monthlyCashFlow >= 0 ? AppColors.successGreen : AppColors.dangerRed)
                        
                        Text("CoC: \(String(format: "%.1f%%", results.cashOnCashReturn))")
                            .foregroundColor(AppColors.primaryTeal)
                    }
                    .font(AppFonts.caption)
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        return CurrencyFormatter.format(value)
    }
    
    private func formatCashFlow(_ value: Double) -> String {
        return CurrencyFormatter.format(value, showSign: true)
    }
}

#Preview {
    SearchView(viewModel: {
        let vm = DealViewModel()
        vm.savedDeals = [.sampleDeal]
        return vm
    }())
}
