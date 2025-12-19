//
//  DealEntryView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/17.
//

import SwiftUI

/// Main deal entry view with live-updating results
struct DealEntryView: View {
    @Bindable var viewModel: DealViewModel
    @State private var showingQuickEntry: Bool = false
    @State private var showingSaveSheet: Bool = false
    @State private var dealName: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Mode Toggle
                    HStack(spacing: 12) {
                        ModeButton(
                            title: "Full Analysis",
                            icon: "doc.text.fill",
                            isSelected: !showingQuickEntry
                        ) {
                            withAnimation { showingQuickEntry = false }
                        }
                        
                        ModeButton(
                            title: "Quick Entry",
                            icon: "bolt.fill",
                            isSelected: showingQuickEntry
                        ) {
                            withAnimation { showingQuickEntry = true }
                        }
                    }
                    .padding(.horizontal)
                    
                    if showingQuickEntry {
                        QuickEntryView(viewModel: viewModel)
                    } else {
                        // Full Entry Form
                        VStack(spacing: 16) {
                            PropertyDetailsSection(viewModel: viewModel)
                            FinancingSection(viewModel: viewModel)
                            IncomeSection(viewModel: viewModel)
                            ExpensesSection(viewModel: viewModel)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Results Dashboard (always visible)
                    if viewModel.deal.purchasePrice > 0 || viewModel.deal.monthlyRent > 0 {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("ANALYSIS RESULTS")
                                    .font(AppFonts.metricLabel)
                                    .foregroundColor(AppColors.textSecondary)
                                    .tracking(0.5)
                                
                                Spacer()
                                
                                // Agent Mode Toggle
                                Button(action: {
                                    withAnimation { viewModel.isAgentMode.toggle() }
                                }) {
                                    Image(systemName: viewModel.isAgentMode ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(viewModel.isAgentMode ? AppColors.warningAmber : AppColors.textSecondary)
                                }
                            }
                            .padding(.horizontal)
                            
                            ResultsDashboardView(viewModel: viewModel)
                                .padding(.horizontal)
                        }
                    }
                    
                    // Empty State
                    if viewModel.deal.purchasePrice == 0 && viewModel.deal.monthlyRent == 0 {
                        EmptyAnalysisState()
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.vertical)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Analyze Deal")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        viewModel.resetDeal()
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: { viewModel.showingToolsMenu = true }) {
                            Image(systemName: "wrench.and.screwdriver")
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        Button(action: { showingSaveSheet = true }) {
                            Image(systemName: "square.and.arrow.down")
                                .foregroundColor(AppColors.primaryTeal)
                        }
                        .disabled(viewModel.deal.purchasePrice == 0)
                    }
                }
            }
            .sheet(isPresented: $showingSaveSheet) {
                SaveDealSheet(
                    viewModel: viewModel,
                    dealName: $dealName,
                    isPresented: $showingSaveSheet
                )
            }
            .sheet(isPresented: $viewModel.showingToolsMenu) {
                ToolsMenuView(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Mode Button

struct ModeButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                
                Text(title)
                    .font(AppFonts.bodyBold)
            }
            .foregroundColor(isSelected ? .white : AppColors.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? AppColors.primaryTeal : AppColors.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? AppColors.primaryTeal : AppColors.border, lineWidth: 1)
            )
        }
    }
}

// MARK: - Empty State

struct EmptyAnalysisState: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "house.and.flag.fill")
                .font(.system(size: 48))
                .foregroundColor(AppColors.primaryTeal.opacity(0.5))
            
            Text("Start Your Analysis")
                .font(AppFonts.title)
                .foregroundColor(AppColors.textPrimary)
            
            Text("Enter a purchase price and rent to see live cash flow calculations")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
        .background(AppColors.cardBackground)
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

// MARK: - Save Deal Sheet

struct SaveDealSheet: View {
    @Bindable var viewModel: DealViewModel
    @Binding var dealName: String
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Deal Name")
                        .font(AppFonts.fieldLabel)
                        .foregroundColor(AppColors.textSecondary)
                    
                    TextField("e.g., 123 Main Street", text: $dealName)
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textPrimary)
                        .padding()
                        .background(AppColors.inputBackground)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                }
                
                // Quick Summary
                VStack(alignment: .leading, spacing: 12) {
                    Text("Summary")
                        .font(AppFonts.sectionHeader)
                        .foregroundColor(AppColors.textPrimary)
                    
                    HStack {
                        Text("Cash Flow")
                            .foregroundColor(AppColors.textSecondary)
                        Spacer()
                        CompactCashFlowBadge(monthlyCashFlow: viewModel.results.monthlyCashFlow)
                    }
                    
                    HStack {
                        Text("CoC Return")
                            .foregroundColor(AppColors.textSecondary)
                        Spacer()
                        Text(String(format: "%.1f%%", viewModel.results.cashOnCashReturn))
                            .font(AppFonts.bodyBold)
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(16)
                
                Spacer()
                
                Button(action: {
                    viewModel.saveDeal(name: dealName.isEmpty ? "Untitled Deal" : dealName)
                    dealName = ""
                    isPresented = false
                }) {
                    Text("Save Deal")
                        .font(AppFonts.button)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppColors.primaryGradient)
                        .cornerRadius(14)
                }
            }
            .padding()
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Save Deal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    DealEntryView(viewModel: DealViewModel())
}
