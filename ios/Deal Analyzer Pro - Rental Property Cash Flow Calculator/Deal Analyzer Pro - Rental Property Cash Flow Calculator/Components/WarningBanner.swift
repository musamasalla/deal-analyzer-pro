//
//  WarningBanner.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/17.
//

import SwiftUI

/// Warning banner for deal issues
struct WarningBanner: View {
    let warning: DealWarning
    var isExpanded: Bool = false
    
    var backgroundColor: Color {
        switch warning.type {
        case .info:
            return AppColors.primaryTeal.opacity(0.15)
        case .warning:
            return AppColors.warningAmber.opacity(0.15)
        case .critical:
            return AppColors.dangerRed.opacity(0.15)
        }
    }
    
    var borderColor: Color {
        switch warning.type {
        case .info:
            return AppColors.primaryTeal.opacity(0.3)
        case .warning:
            return AppColors.warningAmber.opacity(0.3)
        case .critical:
            return AppColors.dangerRed.opacity(0.3)
        }
    }
    
    var iconColor: Color {
        switch warning.type {
        case .info:
            return AppColors.primaryTeal
        case .warning:
            return AppColors.warningAmber
        case .critical:
            return AppColors.dangerRed
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: warning.type.iconName)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(warning.title)
                    .font(AppFonts.bodyBold)
                    .foregroundColor(AppColors.textPrimary)
                
                if isExpanded {
                    Text(warning.message)
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(backgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: 1)
        )
    }
}

/// Prominent "This deal may not cash flow" banner
struct NegativeCashFlowBanner: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.octagon.fill")
                .font(.system(size: 28))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("This Deal May Not Cash Flow")
                    .font(AppFonts.title2)
                    .fontWeight(.bold)
                
                Text("The property shows negative returns after expenses")
                    .font(AppFonts.subheadline)
                    .opacity(0.9)
            }
            
            Spacer()
        }
        .foregroundColor(.white)
        .padding(16)
        .background(
            LinearGradient(
                colors: [AppColors.dangerRed, AppColors.dangerRed.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
}

/// Collapsible warnings section
struct WarningsSection: View {
    let warnings: [DealWarning]
    @State private var isExpanded: Bool = true
    
    var body: some View {
        if !warnings.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Button(action: { withAnimation { isExpanded.toggle() } }) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(AppColors.warningAmber)
                        
                        Text("\(warnings.count) \(warnings.count == 1 ? "Warning" : "Warnings")")
                            .font(AppFonts.sectionHeader)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Spacer()
                        
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                if isExpanded {
                    ForEach(warnings) { warning in
                        WarningBanner(warning: warning, isExpanded: true)
                    }
                }
            }
        }
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        ScrollView {
            VStack(spacing: 16) {
                NegativeCashFlowBanner()
                
                WarningBanner(
                    warning: DealWarning(
                        type: .critical,
                        title: "Negative Cash Flow",
                        message: "This property loses $150/month after all expenses."
                    ),
                    isExpanded: true
                )
                
                WarningBanner(
                    warning: DealWarning(
                        type: .warning,
                        title: "Low Cash-on-Cash Return",
                        message: "CoC return of 4.2% is below the 8% target."
                    ),
                    isExpanded: true
                )
                
                WarningBanner(
                    warning: DealWarning(
                        type: .info,
                        title: "Rent May Be Low",
                        message: "Consider verifying market rents."
                    ),
                    isExpanded: false
                )
                
                WarningsSection(warnings: [
                    DealWarning(type: .warning, title: "High Expense Ratio", message: "Expenses consume 55% of gross rent."),
                    DealWarning(type: .info, title: "Low Cash Flow Per Door", message: "$150/door is below the $200/door target.")
                ])
            }
            .padding()
        }
    }
}
