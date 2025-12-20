//
//  CashFlowCard.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/17.
//

import SwiftUI

/// Large, prominent cash flow display card
/// Green for positive, red for negative - THE most important number
struct CashFlowCard: View {
    let monthlyCashFlow: Double
    let annualCashFlow: Double
    var showAnnual: Bool = true
    
    var isPositive: Bool {
        monthlyCashFlow >= 0
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: isPositive ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                    .font(.system(size: 24))
                
                Text("MONTHLY CASH FLOW")
                    .font(AppFonts.metricLabel)
                    .tracking(1)
                
                Spacer()
                
                if !isPositive {
                    Text("NEGATIVE")
                        .font(AppFonts.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            .foregroundColor(.white.opacity(0.9))
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(isPositive ? "+" : "-")
                    .font(AppFonts.metricValue)
                
                Text("$")
                    .font(AppFonts.metricValue)
                
                Text(formatNumber(abs(monthlyCashFlow)))
                    .font(AppFonts.cashFlowDisplay)
            }
            .foregroundColor(.white)
            
            Text("After ALL expenses including reserves")
                .font(AppFonts.caption)
                .foregroundColor(.white.opacity(0.7))
            
            if showAnnual {
                Divider()
                    .background(Color.white.opacity(0.3))
                    .padding(.vertical, 4)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("ANNUAL CASH FLOW")
                            .font(AppFonts.caption2)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text(CurrencyFormatter.format(annualCashFlow, showSign: true))
                            .font(AppFonts.title2)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "calendar")
                        .font(.system(size: 28))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isPositive ? AppColors.positiveGradient : AppColors.negativeGradient)
        )
        .shadow(color: (isPositive ? AppColors.successGreen : AppColors.dangerRed).opacity(0.4), radius: 12, x: 0, y: 6)
    }
    
    private func formatNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
}

/// Compact cash flow indicator for list views
struct CompactCashFlowBadge: View {
    let monthlyCashFlow: Double
    
    var isPositive: Bool {
        monthlyCashFlow >= 0
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: isPositive ? "arrow.up" : "arrow.down")
                .font(.system(size: 10, weight: .bold))
            
            Text(CurrencyFormatter.format(monthlyCashFlow, showSign: true))
                .font(AppFonts.bodyBold)
        }
        .foregroundColor(isPositive ? AppColors.successGreen : AppColors.dangerRed)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            (isPositive ? AppColors.successGreen : AppColors.dangerRed)
                .opacity(0.15)
        )
        .cornerRadius(8)
    }
}

/// Cash flow per door display
struct CashFlowPerDoorBadge: View {
    let cashFlowPerDoor: Double
    let doorCount: Int
    
    var isGood: Bool {
        cashFlowPerDoor >= 200
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "door.left.hand.closed")
                .font(.system(size: 16))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(CurrencyFormatter.format(cashFlowPerDoor))/door")
                    .font(AppFonts.bodyBold)
                    .foregroundColor(isGood ? AppColors.successGreen : AppColors.warningAmber)
                
                Text("\(doorCount) \(doorCount == 1 ? "unit" : "units")")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)
            }
        }
        .padding(12)
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isGood ? AppColors.successGreen.opacity(0.3) : AppColors.warningAmber.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        ScrollView {
            VStack(spacing: 20) {
                CashFlowCard(
                    monthlyCashFlow: 385,
                    annualCashFlow: 4620
                )
                
                CashFlowCard(
                    monthlyCashFlow: -150,
                    annualCashFlow: -1800
                )
                
                HStack(spacing: 12) {
                    CompactCashFlowBadge(monthlyCashFlow: 385)
                    CompactCashFlowBadge(monthlyCashFlow: -150)
                }
                
                CashFlowPerDoorBadge(
                    cashFlowPerDoor: 192.50,
                    doorCount: 2
                )
            }
            .padding()
        }
    }
}
