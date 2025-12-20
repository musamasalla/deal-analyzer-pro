//
//  ResultsDashboardView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/17.
//

import SwiftUI

/// Results dashboard showing all calculated metrics
struct ResultsDashboardView: View {
    @Bindable var viewModel: DealViewModel
    @State private var showingProjection: Bool = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Agent Mode Blur Overlay
            if viewModel.isAgentMode {
                AgentModeOverlay()
            } else {
                // Warnings Banner
                if viewModel.results.monthlyCashFlow < 0 {
                    NegativeCashFlowBanner()
                }
                
                // Main Cash Flow Card
                CashFlowCard(
                    monthlyCashFlow: viewModel.results.monthlyCashFlow,
                    annualCashFlow: viewModel.results.annualCashFlow
                )
                
                // Cash Flow Per Door (for multi-unit)
                if viewModel.deal.doorCount > 1 {
                    CashFlowPerDoorBadge(
                        cashFlowPerDoor: viewModel.results.cashFlowPerDoor,
                        doorCount: viewModel.deal.doorCount
                    )
                }
                
                // Key Metrics Grid
                VStack(alignment: .leading, spacing: 12) {
                    Text("KEY METRICS")
                        .font(AppFonts.metricLabel)
                        .foregroundColor(AppColors.textSecondary)
                        .tracking(0.5)
                    
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ],
                        spacing: 12
                    ) {
                        MetricCard(
                            title: "Cash-on-Cash",
                            value: formatPercent(viewModel.results.cashOnCashReturn),
                            subtitle: "Annual return on cash",
                            icon: "percent",
                            valueColor: metricColor(for: viewModel.results.cashOnCashReturn, goodThreshold: 8, greatThreshold: 12)
                        )
                        
                        MetricCard(
                            title: "Cap Rate",
                            value: formatPercent(viewModel.results.capRate),
                            subtitle: "Net operating margin",
                            icon: "chart.pie.fill",
                            valueColor: metricColor(for: viewModel.results.capRate, goodThreshold: 6, greatThreshold: 8)
                        )
                        
                        MetricCard(
                            title: "GRM",
                            value: String(format: "%.1f", viewModel.results.grossRentMultiplier),
                            subtitle: "Gross rent multiplier",
                            icon: "multiply"
                        )
                        
                        MetricCard(
                            title: "DSCR",
                            value: viewModel.deal.isCashPurchase ? "∞" : String(format: "%.2f", viewModel.results.debtServiceCoverageRatio),
                            subtitle: "Debt service coverage",
                            icon: "shield.fill",
                            valueColor: viewModel.results.debtServiceCoverageRatio >= 1.25 ? AppColors.successGreen : AppColors.warningAmber
                        )
                    }
                }
                .padding(16)
                .background(AppColors.cardBackground)
                .cornerRadius(16)
                
                // Purchase Summary
                PurchaseSummaryCard(viewModel: viewModel)
                
                // 5-Year Projection Button
                Button(action: { showingProjection = true }) {
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 20))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("5-Year Projection")
                                .font(AppFonts.bodyBold)
                            
                            Text("Total return: \(CurrencyFormatter.format(viewModel.results.fiveYearProjection.totalReturn))")
                                .font(AppFonts.caption)
                                .opacity(0.8)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.white)
                    .padding(16)
                    .background(AppColors.primaryGradient)
                    .cornerRadius(12)
                }
                
                // Action Buttons Row
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ],
                    spacing: 12
                ) {
                    ActionButton(icon: "slider.horizontal.3", title: "What If") {
                        viewModel.showingScenarioTesting = true
                    }
                    
                    ActionButton(icon: "calendar", title: "Amort.") {
                        viewModel.showingAmortization = true
                    }
                    
                    ActionButton(icon: "note.text", title: "Notes") {
                        viewModel.showingNotes = true
                    }
                    
                    ActionButton(icon: "doc.fill", title: "PDF") {
                        viewModel.showingPDFPreview = true
                    }
                }
                
                // Warnings Section
                if !viewModel.warnings.isEmpty {
                    WarningsSection(warnings: viewModel.warnings)
                }
            }
        }
        .sheet(isPresented: $showingProjection) {
            FiveYearProjectionView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showingScenarioTesting) {
            ScenarioTestingView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showingAmortization) {
            AmortizationView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showingNotes) {
            DealNotesView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showingPDFPreview) {
            PDFPreviewSheet(viewModel: viewModel)
        }
    }
    
    private func formatPercent(_ value: Double) -> String {
        return String(format: "%.1f%%", value)
    }
    
    private func metricColor(for value: Double, goodThreshold: Double, greatThreshold: Double) -> Color {
        if value >= greatThreshold {
            return AppColors.successGreen
        } else if value >= goodThreshold {
            return AppColors.primaryTeal
        } else if value > 0 {
            return AppColors.warningAmber
        } else {
            return AppColors.dangerRed
        }
    }
}

// MARK: - Purchase Summary Card

struct PurchaseSummaryCard: View {
    @Bindable var viewModel: DealViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PURCHASE SUMMARY")
                .font(AppFonts.metricLabel)
                .foregroundColor(AppColors.textSecondary)
                .tracking(0.5)
            
            VStack(spacing: 8) {
                SummaryRow(
                    label: "Purchase Price",
                    value: CurrencyFormatter.format(viewModel.deal.purchasePrice)
                )
                
                if !viewModel.deal.isCashPurchase {
                    SummaryRow(
                        label: "Down Payment (\(Int(viewModel.deal.downPaymentPercent))%)",
                        value: CurrencyFormatter.format(viewModel.deal.downPaymentAmount)
                    )
                }
                
                SummaryRow(
                    label: "Closing Costs (\(Int(viewModel.deal.closingCostPercent))%)",
                    value: CurrencyFormatter.format(viewModel.deal.closingCosts)
                )
                
                Divider()
                    .background(AppColors.divider)
                
                SummaryRow(
                    label: "Total Cash Needed",
                    value: CurrencyFormatter.format(viewModel.results.totalCashNeeded),
                    isHighlighted: true
                )
                
                if !viewModel.deal.isCashPurchase {
                    Divider()
                        .background(AppColors.divider)
                    
                    SummaryRow(
                        label: "Monthly Mortgage (P&I)",
                        value: CurrencyFormatter.format(viewModel.results.monthlyMortgagePayment)
                    )
                }
                
                SummaryRow(
                    label: "Monthly Operating Expenses",
                    value: CurrencyFormatter.format(viewModel.deal.monthlyOperatingExpenses)
                )
                
                Divider()
                    .background(AppColors.divider)
                
                SummaryRow(
                    label: "Break-Even Rent",
                    value: CurrencyFormatter.format(viewModel.results.breakEvenRent),
                    subtitle: "Minimum rent to cover costs"
                )
            }
        }
        .padding(16)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
}

struct SummaryRow: View {
    let label: String
    let value: String
    var subtitle: String? = nil
    var isHighlighted: Bool = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(isHighlighted ? AppFonts.bodyBold : AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textMuted)
                }
            }
            
            Spacer()
            
            Text(value)
                .font(isHighlighted ? AppFonts.title2 : AppFonts.bodyBold)
                .foregroundColor(isHighlighted ? AppColors.textAccent : AppColors.textPrimary)
        }
    }
}

// MARK: - Agent Mode Overlay

struct AgentModeOverlay: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "eye.slash.fill")
                .font(.system(size: 48))
                .foregroundColor(AppColors.textSecondary)
            
            Text("Agent Mode Active")
                .font(AppFonts.title)
                .foregroundColor(AppColors.textPrimary)
            
            Text("Your analysis is hidden.\nTap to reveal.")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(AppColors.cardBackground)
        .cornerRadius(20)
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        ScrollView {
            ResultsDashboardView(viewModel: {
                let vm = DealViewModel()
                vm.deal = .sampleDeal
                return vm
            }())
            .padding()
        }
    }
}
