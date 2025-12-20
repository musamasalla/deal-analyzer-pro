//
//  TaxBenefitsView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/19.
//

import SwiftUI

/// Tax benefits calculator for rental property depreciation and deductions
struct TaxBenefitsView: View {
    @Bindable var viewModel: DealViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Tax inputs
    @State private var purchasePrice: Double = 250000
    @State private var landValue: Double = 50000
    @State private var closingCosts: Double = 8000
    @State private var marginalTaxRate: Double = 24
    @State private var useAcceleratedDepreciation: Bool = false
    
    // Deduction toggles
    @State private var includeMortgageInterest: Bool = true
    @State private var includePropertyTax: Bool = true
    @State private var includeInsurance: Bool = true
    @State private var includeRepairs: Bool = true
    @State private var includePropertyManagement: Bool = true
    @State private var includeUtilities: Bool = true
    @State private var includeTravel: Bool = false
    
    // Amounts from deal
    var annualMortgageInterest: Double {
        // Estimate first year interest (simplified)
        let loanAmount = viewModel.deal.purchasePrice * (1 - viewModel.deal.downPaymentPercent / 100)
        return loanAmount * (viewModel.deal.interestRate / 100) * 0.95 // Slightly less than full rate
    }
    
    var annualPropertyTax: Double {
        viewModel.deal.annualPropertyTax > 0 ? viewModel.deal.annualPropertyTax : purchasePrice * 0.012
    }
    
    var annualInsurance: Double {
        viewModel.deal.monthlyInsurance * 12
    }
    
    var annualRepairs: Double {
        let rent = viewModel.deal.monthlyRent * 12
        return rent * (viewModel.deal.maintenancePercent / 100)
    }
    
    var annualPropertyManagement: Double {
        let rent = viewModel.deal.monthlyRent * 12
        return rent * (viewModel.deal.propertyManagementPercent / 100)
    }
    
    // Depreciation
    var depreciableBasis: Double {
        purchasePrice - landValue + closingCosts
    }
    
    var annualDepreciation: Double {
        if useAcceleratedDepreciation {
            return depreciableBasis * 0.0545 // Cost segregation ~5.45% in year 1
        } else {
            return depreciableBasis / 27.5 // Straight-line residential
        }
    }
    
    // Total deductions
    var totalDeductions: Double {
        var total = annualDepreciation
        if includeMortgageInterest { total += annualMortgageInterest }
        if includePropertyTax { total += annualPropertyTax }
        if includeInsurance { total += annualInsurance }
        if includeRepairs { total += annualRepairs }
        if includePropertyManagement { total += annualPropertyManagement }
        if includeUtilities { total += viewModel.deal.monthlyUtilities * 12 }
        if includeTravel { total += 500 } // Estimated travel
        return total
    }
    
    var taxSavings: Double {
        totalDeductions * (marginalTaxRate / 100)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Tax Savings Display
                    VStack(spacing: 12) {
                        Text("ANNUAL TAX SAVINGS")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text(formatCurrency(taxSavings))
                            .font(AppFonts.cashFlowDisplay)
                            .foregroundColor(AppColors.successGreen)
                        
                        Text(formatCurrency(taxSavings / 12) + "/month additional cash flow")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textMuted)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Property Basis
                    VStack(alignment: .leading, spacing: 12) {
                        Text("PROPERTY BASIS")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        CurrencyTextField(
                            title: "Purchase Price",
                            value: $purchasePrice,
                            placeholder: "250000"
                        )
                        
                        CurrencyTextField(
                            title: "Land Value (non-depreciable)",
                            value: $landValue,
                            placeholder: "50000"
                        )
                        
                        CurrencyTextField(
                            title: "Closing Costs (added to basis)",
                            value: $closingCosts,
                            placeholder: "8000"
                        )
                        
                        Divider().background(AppColors.divider)
                        
                        HStack {
                            Text("Depreciable Basis")
                                .font(AppFonts.bodyBold)
                                .foregroundColor(AppColors.textPrimary)
                            Spacer()
                            Text(formatCurrency(depreciableBasis))
                                .font(AppFonts.bodyBold)
                                .foregroundColor(AppColors.primaryTeal)
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Depreciation
                    VStack(alignment: .leading, spacing: 12) {
                        Text("DEPRECIATION")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Toggle(isOn: $useAcceleratedDepreciation) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Cost Segregation Study")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.textPrimary)
                                Text("Accelerate depreciation in early years")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.textMuted)
                            }
                        }
                        .tint(AppColors.primaryTeal)
                        
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(AppColors.primaryTeal)
                            Text(useAcceleratedDepreciation ?
                                 "~5.45% of basis in Year 1" :
                                 "Straight-line over 27.5 years")
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        Divider().background(AppColors.divider)
                        
                        HStack {
                            Text("Annual Depreciation")
                                .font(AppFonts.bodyBold)
                                .foregroundColor(AppColors.textPrimary)
                            Spacer()
                            Text(formatCurrency(annualDepreciation))
                                .font(AppFonts.bodyBold)
                                .foregroundColor(AppColors.successGreen)
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Tax Rate
                    VStack(alignment: .leading, spacing: 12) {
                        Text("YOUR TAX BRACKET")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        HStack {
                            Text("Marginal Tax Rate")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textSecondary)
                            Spacer()
                            Text(String(format: "%.0f%%", marginalTaxRate))
                                .font(AppFonts.bodyBold)
                                .foregroundColor(AppColors.textPrimary)
                        }
                        
                        Slider(value: $marginalTaxRate, in: 10...37, step: 1)
                            .tint(AppColors.primaryTeal)
                        
                        HStack {
                            Text("10%")
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.textMuted)
                            Spacer()
                            Text("37%")
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.textMuted)
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Deductions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("DEDUCTIBLE EXPENSES")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        DeductionRow(
                            title: "Mortgage Interest",
                            amount: annualMortgageInterest,
                            isIncluded: $includeMortgageInterest
                        )
                        
                        DeductionRow(
                            title: "Property Tax",
                            amount: annualPropertyTax,
                            isIncluded: $includePropertyTax
                        )
                        
                        DeductionRow(
                            title: "Insurance",
                            amount: annualInsurance,
                            isIncluded: $includeInsurance
                        )
                        
                        DeductionRow(
                            title: "Repairs & Maintenance",
                            amount: annualRepairs,
                            isIncluded: $includeRepairs
                        )
                        
                        DeductionRow(
                            title: "Property Management",
                            amount: annualPropertyManagement,
                            isIncluded: $includePropertyManagement
                        )
                        
                        DeductionRow(
                            title: "Travel & Mileage",
                            amount: 500,
                            isIncluded: $includeTravel
                        )
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Summary
                    VStack(alignment: .leading, spacing: 12) {
                        Text("TAX BENEFIT SUMMARY")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        SummaryRow(label: "Total Deductions", value: formatCurrency(totalDeductions))
                        SummaryRow(label: "Your Tax Rate", value: String(format: "%.0f%%", marginalTaxRate))
                        
                        Divider().background(AppColors.divider)
                        
                        SummaryRow(label: "Annual Tax Savings", value: formatCurrency(taxSavings), isHighlighted: true)
                        SummaryRow(label: "Monthly Benefit", value: formatCurrency(taxSavings / 12))
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Disclaimer
                    Text("⚠️ This is an estimate only. Consult a tax professional for personalized advice.")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textMuted)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .padding()
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Tax Benefits")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AppColors.primaryTeal)
                }
            }
            .onAppear {
                purchasePrice = viewModel.deal.purchasePrice > 0 ? viewModel.deal.purchasePrice : 250000
                landValue = purchasePrice * 0.2
            }
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        return CurrencyFormatter.format(value)
    }
}

// MARK: - Deduction Row

struct DeductionRow: View {
    let title: String
    let amount: Double
    @Binding var isIncluded: Bool
    
    var body: some View {
        HStack {
            Toggle(isOn: $isIncluded) {
                Text(title)
                    .font(AppFonts.body)
                    .foregroundColor(isIncluded ? AppColors.textPrimary : AppColors.textMuted)
            }
            .tint(AppColors.successGreen)
            
            Text(formatCurrency(amount))
                .font(AppFonts.bodyBold)
                .foregroundColor(isIncluded ? AppColors.successGreen : AppColors.textMuted)
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        return CurrencyFormatter.format(value)
    }
}

#Preview {
    TaxBenefitsView(viewModel: {
        let vm = DealViewModel()
        vm.deal = .sampleDeal
        return vm
    }())
}
