//
//  CalculatorsTabView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/18.
//

import SwiftUI

/// Calculators hub for all standalone calculators
struct CalculatorsTabView: View {
    @Bindable var viewModel: DealViewModel
    
    @State private var showingMortgageCalc: Bool = false
    @State private var showingROICalc: Bool = false
    @State private var showingBRRRR: Bool = false
    @State private var showingRefinance: Bool = false
    @State private var showingClosingCosts: Bool = false
    @State private var showingRentEstimator: Bool = false
    @State private var showingOfferCalc: Bool = false
    @State private var showingCashBuyer: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Investment Calculators
                    VStack(alignment: .leading, spacing: 12) {
                        Text("INVESTMENT CALCULATORS")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        CalculatorCard(
                            icon: "percent",
                            title: "Mortgage Calculator",
                            subtitle: "Monthly payment & extra payment analysis",
                            color: .blue
                        ) {
                            showingMortgageCalc = true
                        }
                        
                        CalculatorCard(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "ROI Calculator",
                            subtitle: "Return on investment & benchmarks",
                            color: .green
                        ) {
                            showingROICalc = true
                        }
                        
                        CalculatorCard(
                            icon: "arrow.triangle.2.circlepath.circle",
                            title: "BRRRR Analysis",
                            subtitle: "Buy, Rehab, Rent, Refinance, Repeat",
                            color: .purple,
                            isPremium: true
                        ) {
                            showingBRRRR = true
                        }
                        
                        CalculatorCard(
                            icon: "arrow.left.arrow.right",
                            title: "Refinance Analyzer",
                            subtitle: "Compare current vs new loan terms",
                            color: .orange
                        ) {
                            showingRefinance = true
                        }
                        
                        CalculatorCard(
                            icon: "tag.fill",
                            title: "Offer Calculator",
                            subtitle: "Calculate max offer based on target returns",
                            color: .cyan,
                            isPremium: true
                        ) {
                            showingOfferCalc = true
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Quick Estimators
                    VStack(alignment: .leading, spacing: 12) {
                        Text("QUICK ESTIMATORS")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        CalculatorCard(
                            icon: "doc.text.fill",
                            title: "Closing Cost Estimator",
                            subtitle: "Estimate buyer closing costs",
                            color: .red
                        ) {
                            showingClosingCosts = true
                        }
                        
                        CalculatorCard(
                            icon: "dollarsign.square.fill",
                            title: "Rent Estimator",
                            subtitle: "Estimate market rent",
                            color: .teal
                        ) {
                            showingRentEstimator = true
                        }
                        
                        CalculatorCard(
                            icon: "banknote.fill",
                            title: "Cash Buyer Mode",
                            subtitle: "Simplified analysis without financing",
                            color: .indigo
                        ) {
                            showingCashBuyer = true
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Tips
                    VStack(alignment: .leading, spacing: 12) {
                        Text("💡 PRO TIP")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.primaryTeal)
                        
                        Text("Use the Offer Calculator to work backwards from your target returns. It tells you the maximum you should pay to hit your cash flow, CoC, and cap rate goals!")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding()
                    .background(AppColors.primaryTeal.opacity(0.1))
                    .cornerRadius(16)
                }
                .padding()
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Calculators")
            .sheet(isPresented: $showingMortgageCalc) {
                MortgageCalculatorView()
            }
            .sheet(isPresented: $showingROICalc) {
                ROICalculatorView()
            }
            .sheet(isPresented: $showingBRRRR) {
                BRRRRAnalysisView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingRefinance) {
                RefinanceAnalyzerView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingClosingCosts) {
                ClosingCostEstimatorView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingRentEstimator) {
                RentEstimatorView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingOfferCalc) {
                OfferCalculatorView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingCashBuyer) {
                CashBuyerModeView(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Calculator Card

struct CalculatorCard: View {
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
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
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
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textMuted)
            }
            .padding()
            .background(AppColors.inputBackground)
            .cornerRadius(12)
        }
    }
}

#Preview {
    CalculatorsTabView(viewModel: DealViewModel())
}
