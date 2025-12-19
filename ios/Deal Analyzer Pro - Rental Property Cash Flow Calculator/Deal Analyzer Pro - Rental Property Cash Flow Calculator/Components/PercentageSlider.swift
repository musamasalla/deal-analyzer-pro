//
//  PercentageSlider.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/17.
//

import SwiftUI

/// Custom percentage slider with value display
struct PercentageSlider: View {
    let title: String
    @Binding var value: Double
    var range: ClosedRange<Double> = 0...100
    var step: Double = 1
    var suffix: String = "%"
    var showDecimal: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(AppFonts.fieldLabel)
                    .foregroundColor(AppColors.textSecondary)
                
                Spacer()
                
                Text(formattedValue)
                    .font(AppFonts.bodyBold)
                    .foregroundColor(AppColors.textAccent)
            }
            
            Slider(value: $value, in: range, step: step)
                .tint(AppColors.primaryTeal)
            
            HStack {
                Text(formatNumber(range.lowerBound) + suffix)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)
                
                Spacer()
                
                Text(formatNumber(range.upperBound) + suffix)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)
            }
        }
        .padding(16)
        .background(AppColors.inputBackground)
        .cornerRadius(12)
    }
    
    private var formattedValue: String {
        formatNumber(value) + suffix
    }
    
    private func formatNumber(_ num: Double) -> String {
        if showDecimal {
            return String(format: "%.1f", num)
        } else {
            return String(format: "%.0f", num)
        }
    }
}

/// Compact slider for inline use
struct CompactPercentageSlider: View {
    let title: String
    @Binding var value: Double
    var range: ClosedRange<Double> = 0...100
    var step: Double = 1
    
    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
                .frame(width: 100, alignment: .leading)
            
            Slider(value: $value, in: range, step: step)
                .tint(AppColors.primaryTeal)
            
            Text("\(Int(value))%")
                .font(AppFonts.bodyBold)
                .foregroundColor(AppColors.textAccent)
                .frame(width: 50, alignment: .trailing)
        }
    }
}

/// Slider that shows both percentage and calculated dollar amount
struct PercentageWithValueSlider: View {
    let title: String
    @Binding var percentage: Double
    let baseValue: Double
    var range: ClosedRange<Double> = 0...100
    var step: Double = 1
    
    var calculatedValue: Double {
        baseValue * (percentage / 100)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(AppFonts.fieldLabel)
                    .foregroundColor(AppColors.textSecondary)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(percentage))%")
                        .font(AppFonts.bodyBold)
                        .foregroundColor(AppColors.textAccent)
                    
                    Text(formatCurrency(calculatedValue))
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textMuted)
                }
            }
            
            Slider(value: $percentage, in: range, step: step)
                .tint(AppColors.primaryTeal)
        }
        .padding(16)
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

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        VStack(spacing: 20) {
            PercentageSlider(
                title: "Down Payment",
                value: .constant(20),
                range: 0...100
            )
            
            PercentageWithValueSlider(
                title: "Down Payment",
                percentage: .constant(20),
                baseValue: 250000
            )
            
            CompactPercentageSlider(
                title: "Vacancy",
                value: .constant(8),
                range: 0...20
            )
        }
        .padding()
    }
}
