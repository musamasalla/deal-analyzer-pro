//
//  RentEstimatorView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/18.
//

import SwiftUI

/// Rent estimation calculator based on property details
struct RentEstimatorView: View {
    @Bindable var viewModel: DealViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Estimation parameters
    @State private var pricePerSqftRent: Double = 1.25  // $/sqft/month
    @State private var bedroomValue: Double = 200      // $/bedroom/month
    @State private var bathroomValue: Double = 50      // $/bathroom/month
    @State private var locationAdjustment: Double = 0  // -20% to +20%
    @State private var conditionAdjustment: Double = 0 // -15% to +15%
    
    var baseRentBySqft: Double {
        Double(viewModel.deal.squareFootage) * pricePerSqftRent
    }
    
    var bedroomAdjustment: Double {
        Double(viewModel.deal.bedrooms) * bedroomValue
    }
    
    var bathroomAdjustment: Double {
        viewModel.deal.bathrooms * bathroomValue
    }
    
    var subtotalRent: Double {
        baseRentBySqft + bedroomAdjustment + bathroomAdjustment
    }
    
    var totalAdjustmentPercent: Double {
        locationAdjustment + conditionAdjustment
    }
    
    var adjustmentAmount: Double {
        subtotalRent * (totalAdjustmentPercent / 100)
    }
    
    var estimatedRent: Double {
        subtotalRent + adjustmentAmount
    }
    
    var onePercentRule: Double {
        viewModel.deal.purchasePrice * 0.01
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Estimated Rent Summary
                    VStack(spacing: 12) {
                        Text("ESTIMATED MONTHLY RENT")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text(formatCurrency(estimatedRent))
                            .font(AppFonts.metricValueLarge)
                            .foregroundColor(AppColors.successGreen)
                        
                        // 1% Rule comparison
                        HStack(spacing: 8) {
                            Text("1% Rule:")
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.textMuted)
                            
                            Text(formatCurrency(onePercentRule))
                                .font(AppFonts.caption)
                                .foregroundColor(estimatedRent >= onePercentRule ? AppColors.successGreen : AppColors.warningAmber)
                            
                            if estimatedRent >= onePercentRule {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(AppColors.successGreen)
                                    .font(.system(size: 12))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(20)
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Property Details
                    VStack(alignment: .leading, spacing: 12) {
                        Text("PROPERTY DETAILS")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        HStack(spacing: 16) {
                            PropertyDetailChip(icon: "square.fill", value: "\(viewModel.deal.squareFootage)", label: "sqft")
                            PropertyDetailChip(icon: "bed.double.fill", value: "\(viewModel.deal.bedrooms)", label: "beds")
                            PropertyDetailChip(icon: "shower.fill", value: String(format: "%.1f", viewModel.deal.bathrooms), label: "baths")
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Calculation Breakdown
                    VStack(alignment: .leading, spacing: 12) {
                        Text("RENT CALCULATION")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        RentCalculationRow(
                            label: "Base (\(viewModel.deal.squareFootage) sqft × $\(String(format: "%.2f", pricePerSqftRent)))",
                            value: baseRentBySqft
                        )
                        
                        RentCalculationRow(
                            label: "Bedrooms (\(viewModel.deal.bedrooms) × $\(Int(bedroomValue)))",
                            value: bedroomAdjustment
                        )
                        
                        RentCalculationRow(
                            label: "Bathrooms (\(String(format: "%.1f", viewModel.deal.bathrooms)) × $\(Int(bathroomValue)))",
                            value: bathroomAdjustment
                        )
                        
                        Divider().background(AppColors.divider)
                        
                        RentCalculationRow(label: "Subtotal", value: subtotalRent, isBold: true)
                        
                        if totalAdjustmentPercent != 0 {
                            RentCalculationRow(
                                label: "Adjustment (\(String(format: "%+.0f", totalAdjustmentPercent))%)",
                                value: adjustmentAmount,
                                isNegative: adjustmentAmount < 0
                            )
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Adjustments
                    VStack(alignment: .leading, spacing: 16) {
                        Text("ADJUSTMENTS")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Location Quality")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.textPrimary)
                                
                                Spacer()
                                
                                Text(String(format: "%+.0f%%", locationAdjustment))
                                    .font(AppFonts.bodyBold)
                                    .foregroundColor(locationAdjustment != 0 ? AppColors.textAccent : AppColors.textMuted)
                            }
                            
                            Slider(value: $locationAdjustment, in: -20...20, step: 5)
                                .tint(AppColors.primaryTeal)
                            
                            HStack {
                                Text("Poor").font(AppFonts.caption).foregroundColor(AppColors.textMuted)
                                Spacer()
                                Text("Excellent").font(AppFonts.caption).foregroundColor(AppColors.textMuted)
                            }
                        }
                        .padding()
                        .background(AppColors.inputBackground)
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Property Condition")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.textPrimary)
                                
                                Spacer()
                                
                                Text(String(format: "%+.0f%%", conditionAdjustment))
                                    .font(AppFonts.bodyBold)
                                    .foregroundColor(conditionAdjustment != 0 ? AppColors.textAccent : AppColors.textMuted)
                            }
                            
                            Slider(value: $conditionAdjustment, in: -15...15, step: 5)
                                .tint(AppColors.primaryTeal)
                            
                            HStack {
                                Text("Needs Work").font(AppFonts.caption).foregroundColor(AppColors.textMuted)
                                Spacer()
                                Text("Renovated").font(AppFonts.caption).foregroundColor(AppColors.textMuted)
                            }
                        }
                        .padding()
                        .background(AppColors.inputBackground)
                        .cornerRadius(12)
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Apply Button
                    Button(action: applyEstimate) {
                        Text("Apply Rent Estimate")
                            .font(AppFonts.button)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppColors.primaryGradient)
                            .cornerRadius(14)
                    }
                }
                .padding()
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Rent Estimator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }
    
    private func applyEstimate() {
        viewModel.deal.monthlyRent = estimatedRent
        dismiss()
    }
    
    private func formatCurrency(_ value: Double) -> String {
        return CurrencyFormatter.format(value)
    }
}

// MARK: - Property Detail Chip

struct PropertyDetailChip: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(AppColors.primaryTeal)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(AppFonts.bodyBold)
                    .foregroundColor(AppColors.textPrimary)
                Text(label)
                    .font(AppFonts.caption2)
                    .foregroundColor(AppColors.textMuted)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(AppColors.inputBackground)
        .cornerRadius(10)
    }
}

// MARK: - Rent Calculation Row

struct RentCalculationRow: View {
    let label: String
    let value: Double
    var isBold: Bool = false
    var isNegative: Bool = false
    
    var body: some View {
        HStack {
            Text(label)
                .font(isBold ? AppFonts.bodyBold : AppFonts.body)
                .foregroundColor(isBold ? AppColors.textPrimary : AppColors.textSecondary)
            
            Spacer()
            
            Text((isNegative ? "" : "+") + formatCurrency(value))
                .font(isBold ? AppFonts.bodyBold : AppFonts.body)
                .foregroundColor(isBold ? AppColors.textAccent : (isNegative ? AppColors.dangerRed : AppColors.successGreen))
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        return CurrencyFormatter.format(value)
    }
}

#Preview {
    RentEstimatorView(viewModel: {
        let vm = DealViewModel()
        vm.deal = .sampleDeal
        return vm
    }())
}
