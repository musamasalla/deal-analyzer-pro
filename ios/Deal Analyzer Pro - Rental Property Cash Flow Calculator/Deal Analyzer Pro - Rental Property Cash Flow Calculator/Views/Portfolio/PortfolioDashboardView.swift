//
//  PortfolioDashboardView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/19.
//

import SwiftUI

/// Investment portfolio dashboard to track all properties
struct PortfolioDashboardView: View {
    @Bindable var viewModel: DealViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Portfolio metrics
    var totalProperties: Int {
        viewModel.savedDeals.count
    }
    
    var totalInvested: Double {
        viewModel.savedDeals.reduce(0) { sum, deal in
            let downPayment = deal.purchasePrice * (deal.downPaymentPercent / 100)
            let closingCosts = deal.purchasePrice * (deal.closingCostPercent / 100)
            return sum + downPayment + closingCosts
        }
    }
    
    var totalEquity: Double {
        viewModel.savedDeals.reduce(0) { sum, deal in
            // Simple equity = down payment + estimated appreciation
            let downPayment = deal.purchasePrice * (deal.downPaymentPercent / 100)
            return sum + downPayment * 1.15 // Estimate 15% equity growth
        }
    }
    
    var totalMonthlyCashFlow: Double {
        viewModel.savedDeals.reduce(0) { sum, deal in
            // Simple cash flow estimate
            let rent = deal.monthlyRent
            let expenses = deal.monthlyInsurance + (deal.annualPropertyTax / 12) + deal.monthlyHOA
            let mortgagePayment = calculateMortgage(deal)
            return sum + (rent - expenses - mortgagePayment)
        }
    }
    
    var totalAnnualCashFlow: Double {
        totalMonthlyCashFlow * 12
    }
    
    var averageCoC: Double {
        guard totalInvested > 0 else { return 0 }
        return (totalAnnualCashFlow / totalInvested) * 100
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Portfolio Summary
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("TOTAL PORTFOLIO VALUE")
                                    .font(AppFonts.metricLabel)
                                    .foregroundColor(AppColors.textSecondary)
                                
                                Text(formatCurrency(totalEquity))
                                    .font(AppFonts.cashFlowDisplay)
                                    .foregroundColor(AppColors.successGreen)
                            }
                            
                            Spacer()
                            
                            VStack {
                                Text("\(totalProperties)")
                                    .font(AppFonts.title)
                                    .foregroundColor(AppColors.primaryTeal)
                                Text("Properties")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.textMuted)
                            }
                        }
                    }
                    .padding(20)
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Key Metrics Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 12) {
                        PortfolioMetricCard(
                            title: "Total Invested",
                            value: formatCurrency(totalInvested),
                            icon: "dollarsign.circle.fill",
                            color: .blue
                        )
                        
                        PortfolioMetricCard(
                            title: "Monthly Cash Flow",
                            value: formatCurrency(totalMonthlyCashFlow),
                            icon: "arrow.up.circle.fill",
                            color: totalMonthlyCashFlow >= 0 ? .green : .red
                        )
                        
                        PortfolioMetricCard(
                            title: "Annual Cash Flow",
                            value: formatCurrency(totalAnnualCashFlow),
                            icon: "calendar.circle.fill",
                            color: .purple
                        )
                        
                        PortfolioMetricCard(
                            title: "Avg CoC Return",
                            value: String(format: "%.1f%%", averageCoC),
                            icon: "percent",
                            color: .orange
                        )
                    }
                    
                    // Properties List
                    VStack(alignment: .leading, spacing: 12) {
                        Text("YOUR PROPERTIES")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        if viewModel.savedDeals.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "building.2")
                                    .font(.system(size: 40))
                                    .foregroundColor(AppColors.textMuted)
                                
                                Text("No properties in portfolio")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.textSecondary)
                                
                                Text("Save deals to add them to your portfolio")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.textMuted)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(40)
                        } else {
                            ForEach(viewModel.savedDeals) { deal in
                                PortfolioPropertyRow(deal: deal)
                            }
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Portfolio Goals
                    VStack(alignment: .leading, spacing: 12) {
                        Text("GOALS TRACKER")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        PortfolioGoalRow(
                            title: "Properties Owned",
                            current: totalProperties,
                            goal: 10,
                            icon: "building.2.fill"
                        )
                        
                        PortfolioGoalRow(
                            title: "Monthly Cash Flow",
                            current: Int(totalMonthlyCashFlow),
                            goal: 5000,
                            icon: "banknote.fill",
                            isCurrency: true
                        )
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                }
                .padding()
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Portfolio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AppColors.primaryTeal)
                }
            }
        }
    }
    
    private func calculateMortgage(_ deal: PropertyDeal) -> Double {
        let loanAmount = deal.purchasePrice * (1 - deal.downPaymentPercent / 100)
        let monthlyRate = (deal.interestRate / 100) / 12
        let payments = Double(deal.loanTermYears * 12)
        
        guard monthlyRate > 0, payments > 0 else { return 0 }
        
        return loanAmount * (monthlyRate * pow(1 + monthlyRate, payments)) /
               (pow(1 + monthlyRate, payments) - 1)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

// MARK: - Portfolio Metric Card

struct PortfolioMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(AppFonts.title2)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(title)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Portfolio Property Row

struct PortfolioPropertyRow: View {
    let deal: PropertyDeal
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: deal.propertyType.icon)
                .font(.system(size: 24))
                .foregroundColor(AppColors.primaryTeal)
                .frame(width: 44, height: 44)
                .background(AppColors.primaryTeal.opacity(0.15))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(deal.name.isEmpty ? "Unnamed Property" : deal.name)
                    .font(AppFonts.bodyBold)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(deal.address.isEmpty ? deal.propertyType.displayName : deal.address)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(formatCurrency(deal.purchasePrice))
                    .font(AppFonts.bodyBold)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("\(formatCurrency(deal.monthlyRent))/mo")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.successGreen)
            }
        }
        .padding()
        .background(AppColors.inputBackground)
        .cornerRadius(12)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

// MARK: - Portfolio Goal Row

struct PortfolioGoalRow: View {
    let title: String
    let current: Int
    let goal: Int
    let icon: String
    var isCurrency: Bool = false
    
    var progress: Double {
        guard goal > 0 else { return 0 }
        return min(Double(current) / Double(goal), 1.0)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(AppColors.primaryTeal)
                
                Text(title)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
                
                Spacer()
                
                if isCurrency {
                    Text("\(formatCurrency(Double(current))) / \(formatCurrency(Double(goal)))")
                        .font(AppFonts.bodyBold)
                        .foregroundColor(AppColors.textPrimary)
                } else {
                    Text("\(current) / \(goal)")
                        .font(AppFonts.bodyBold)
                        .foregroundColor(AppColors.textPrimary)
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(AppColors.inputBackground)
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.primaryTeal, AppColors.successGreen],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 8)
            .cornerRadius(4)
        }
        .padding(.vertical, 4)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

#Preview {
    PortfolioDashboardView(viewModel: DealViewModel())
}
