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
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Tips
                    VStack(alignment: .leading, spacing: 12) {
                        Text("💡 PRO TIP")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.primaryTeal)
                        
                        Text("Use the BRRRR analysis for fix-and-flip or value-add investments. The goal is to refinance out all your initial capital so you can repeat the process indefinitely!")
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
