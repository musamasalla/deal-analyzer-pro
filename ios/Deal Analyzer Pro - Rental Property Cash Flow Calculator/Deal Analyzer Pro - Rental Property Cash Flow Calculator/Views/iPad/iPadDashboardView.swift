//
//  iPadDashboardView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/18.
//

import SwiftUI

/// iPad-optimized dashboard with split view layout
struct iPadDashboardView: View {
    @Bindable var viewModel: DealViewModel
    @State private var selectedSection: DashboardSection? = .entry
    
    enum DashboardSection: String, CaseIterable, Hashable {
        case entry = "Entry"
        case results = "Results"
        case saved = "Saved"
        case tools = "Tools"
        
        var icon: String {
            switch self {
            case .entry: return "square.and.pencil"
            case .results: return "chart.bar.fill"
            case .saved: return "folder.fill"
            case .tools: return "wrench.and.screwdriver"
            }
        }
    }
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            List {
                ForEach(DashboardSection.allCases, id: \.self) { section in
                    Button(action: { selectedSection = section }) {
                        HStack {
                            Label(section.rawValue, systemImage: section.icon)
                            Spacer()
                            if selectedSection == section {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppColors.primaryTeal)
                            }
                        }
                    }
                    .foregroundColor(selectedSection == section ? AppColors.primaryTeal : AppColors.textPrimary)
                }
            }
            .navigationTitle("Deal Analyzer")
            .listStyle(.sidebar)
        } detail: {
            // Main content based on selection
            switch selectedSection {
            case .entry:
                iPadEntryContent(viewModel: viewModel)
            case .results:
                iPadResultsContent(viewModel: viewModel)
            case .saved:
                SavedDealsListView(viewModel: viewModel)
            case .tools:
                ToolsListView(viewModel: viewModel)
            case .none:
                Text("Select a section")
            }
        }
        .tint(AppColors.primaryTeal)
    }
}

// MARK: - iPad Entry Content

struct iPadEntryContent: View {
    @Bindable var viewModel: DealViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Quick stats widget at top
                DashboardWidgetView(viewModel: viewModel)
                
                // Entry sections in grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    PropertyDetailsSection(viewModel: viewModel)
                    FinancingSection(viewModel: viewModel)
                    IncomeSection(viewModel: viewModel)
                    ExpensesSection(viewModel: viewModel)
                }
            }
            .padding()
        }
        .background(AppColors.background)
        .navigationTitle("Property Entry")
    }
}

// MARK: - iPad Results Content

struct iPadResultsContent: View {
    @Bindable var viewModel: DealViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if viewModel.deal.purchasePrice > 0 {
                    ResultsDashboardView(viewModel: viewModel)
                    
                    // Additional charts placeholder
                    VStack(alignment: .leading, spacing: 12) {
                        Text("5-YEAR PROJECTION")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        FiveYearProjectionView(viewModel: viewModel)
                    }
                } else {
                    ContentUnavailableView(
                        "No Data",
                        systemImage: "chart.bar.xaxis",
                        description: Text("Enter property details to see analysis results")
                    )
                }
            }
            .padding()
        }
        .background(AppColors.background)
        .navigationTitle("Analysis")
    }
}

// MARK: - Tools List View

struct ToolsListView: View {
    @Bindable var viewModel: DealViewModel
    
    @State private var showingClosingCosts: Bool = false
    @State private var showingRentEstimator: Bool = false
    @State private var showingDealRating: Bool = false
    @State private var showingMarketResearch: Bool = false
    
    var body: some View {
        List {
            Section("Calculators") {
                Button(action: { showingClosingCosts = true }) {
                    Label("Closing Cost Estimator", systemImage: "doc.text.fill")
                }
                
                Button(action: { showingRentEstimator = true }) {
                    Label("Rent Estimator", systemImage: "dollarsign.square.fill")
                }
            }
            
            Section("Analysis") {
                Button(action: { showingDealRating = true }) {
                    Label("Deal Score", systemImage: "star.fill")
                }
                
                Button(action: { showingMarketResearch = true }) {
                    Label {
                        HStack {
                            Text("Market Research")
                            PremiumBadge()
                        }
                    } icon: {
                        Image(systemName: "map.fill")
                    }
                }
            }
            
            Section("Quick Actions") {
                Button(action: { viewModel.useLastExpenses() }) {
                    Label("Use Last Deal Values", systemImage: "arrow.triangle.2.circlepath")
                }
                
                Button(action: { viewModel.resetDeal() }) {
                    Label("Reset All Fields", systemImage: "arrow.clockwise")
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Tools")
        .sheet(isPresented: $showingClosingCosts) {
            ClosingCostEstimatorView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingRentEstimator) {
            RentEstimatorView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingDealRating) {
            DealRatingView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingMarketResearch) {
            MarketResearchView(viewModel: viewModel)
        }
    }
}

#Preview {
    iPadDashboardView(viewModel: {
        let vm = DealViewModel()
        vm.deal = .sampleDeal
        return vm
    }())
}
