//
//  ToolsMenuView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/18.
//

import SwiftUI

/// Tools menu accessible from deal entry
struct ToolsMenuView: View {
    @Bindable var viewModel: DealViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingClosingCosts: Bool = false
    @State private var showingRentEstimator: Bool = false
    @State private var showingMarketResearch: Bool = false
    @State private var showingDealRating: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Calculator Tools
                    VStack(alignment: .leading, spacing: 12) {
                        Text("CALCULATORS")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        ToolMenuItem(
                            icon: "doc.text.fill",
                            title: "Closing Cost Estimator",
                            subtitle: "Detailed breakdown of buyer closing costs",
                            color: .blue
                        ) {
                            showingClosingCosts = true
                        }
                        
                        ToolMenuItem(
                            icon: "dollarsign.square.fill",
                            title: "Rent Estimator",
                            subtitle: "Calculate expected rent based on property",
                            color: .green
                        ) {
                            showingRentEstimator = true
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Analysis Tools
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ANALYSIS")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        ToolMenuItem(
                            icon: "star.fill",
                            title: "Deal Score",
                            subtitle: "Get an overall rating for this deal",
                            color: .orange
                        ) {
                            showingDealRating = true
                        }
                        
                        ToolMenuItem(
                            icon: "map.fill",
                            title: "Market Research",
                            subtitle: "View market data and comparables",
                            color: .purple,
                            isPremium: true
                        ) {
                            showingMarketResearch = true
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Quick Actions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("QUICK ACTIONS")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        ToolMenuItem(
                            icon: "arrow.triangle.2.circlepath",
                            title: "Use Last Deal Values",
                            subtitle: "Copy expenses from your last analysis",
                            color: .teal
                        ) {
                            viewModel.useLastExpenses()
                            dismiss()
                        }
                        
                        ToolMenuItem(
                            icon: "doc.on.doc.fill",
                            title: "Duplicate Deal",
                            subtitle: "Create a copy to test variations",
                            color: .indigo
                        ) {
                            // Already a copy since we're editing in-memory
                            dismiss()
                        }
                        
                        ToolMenuItem(
                            icon: "arrow.clockwise",
                            title: "Reset All Fields",
                            subtitle: "Clear and start fresh",
                            color: .red
                        ) {
                            viewModel.resetDeal()
                            dismiss()
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                }
                .padding()
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Tools")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .sheet(isPresented: $showingClosingCosts) {
                ClosingCostEstimatorView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingRentEstimator) {
                RentEstimatorView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingMarketResearch) {
                MarketResearchView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingDealRating) {
                DealRatingView(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Tool Menu Item

struct ToolMenuItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    var isPremium: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(color)
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(AppFonts.bodyBold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        if isPremium {
                            PremiumBadge()
                        }
                    }
                    
                    Text(subtitle)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textMuted)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textMuted)
            }
            .padding(12)
            .background(AppColors.inputBackground)
            .cornerRadius(12)
        }
    }
}

#Preview {
    ToolsMenuView(viewModel: {
        let vm = DealViewModel()
        vm.deal = .sampleDeal
        return vm
    }())
}
