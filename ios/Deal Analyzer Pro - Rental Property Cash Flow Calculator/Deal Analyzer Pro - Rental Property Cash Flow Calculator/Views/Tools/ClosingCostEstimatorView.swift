//
//  ClosingCostEstimatorView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/18.
//

import SwiftUI

/// Detailed closing cost estimator
struct ClosingCostEstimatorView: View {
    @Bindable var viewModel: DealViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Buyer closing costs (percentages of purchase price)
    @State private var loanOriginationFee: Double = 1.0 // 1% of loan
    @State private var appraisalFee: Double = 500
    @State private var creditReportFee: Double = 50
    @State private var titleInsurance: Double = 0.5 // 0.5% of price
    @State private var escrowFee: Double = 0.5 // 0.5% of price
    @State private var recordingFee: Double = 150
    @State private var homeInspection: Double = 450
    @State private var surveyFee: Double = 400
    @State private var attorneyFee: Double = 800
    @State private var prepaidPropertyTax: Double = 2 // months
    @State private var prepaidInsurance: Double = 12 // months
    
    var loanOriginationAmount: Double {
        viewModel.deal.loanAmount * (loanOriginationFee / 100)
    }
    
    var titleInsuranceAmount: Double {
        viewModel.deal.purchasePrice * (titleInsurance / 100)
    }
    
    var escrowAmount: Double {
        viewModel.deal.purchasePrice * (escrowFee / 100)
    }
    
    var prepaidTaxAmount: Double {
        (viewModel.deal.annualPropertyTax / 12) * prepaidPropertyTax
    }
    
    var prepaidInsuranceAmount: Double {
        viewModel.deal.monthlyInsurance * prepaidInsurance
    }
    
    var totalLenderFees: Double {
        loanOriginationAmount + appraisalFee + creditReportFee
    }
    
    var totalTitleFees: Double {
        titleInsuranceAmount + escrowAmount + recordingFee
    }
    
    var totalInspectionFees: Double {
        homeInspection + surveyFee
    }
    
    var totalPrepaids: Double {
        prepaidTaxAmount + prepaidInsuranceAmount
    }
    
    var totalClosingCosts: Double {
        totalLenderFees + totalTitleFees + totalInspectionFees + attorneyFee + totalPrepaids
    }
    
    var closingCostPercent: Double {
        guard viewModel.deal.purchasePrice > 0 else { return 0 }
        return (totalClosingCosts / viewModel.deal.purchasePrice) * 100
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Summary Card
                    VStack(spacing: 12) {
                        Text("ESTIMATED CLOSING COSTS")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text(formatCurrency(totalClosingCosts))
                            .font(AppFonts.metricValueLarge)
                            .foregroundColor(AppColors.textAccent)
                        
                        Text(String(format: "%.1f%% of purchase price", closingCostPercent))
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textMuted)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(20)
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Lender Fees
                    ClosingCostSection(
                        title: "LENDER FEES",
                        total: totalLenderFees
                    ) {
                        ClosingCostRow(
                            label: "Loan Origination (\(String(format: "%.1f", loanOriginationFee))%)",
                            value: loanOriginationAmount
                        )
                        ClosingCostRow(label: "Appraisal", value: appraisalFee)
                        ClosingCostRow(label: "Credit Report", value: creditReportFee)
                    }
                    
                    // Title Fees
                    ClosingCostSection(
                        title: "TITLE & ESCROW",
                        total: totalTitleFees
                    ) {
                        ClosingCostRow(
                            label: "Title Insurance (\(String(format: "%.1f", titleInsurance))%)",
                            value: titleInsuranceAmount
                        )
                        ClosingCostRow(
                            label: "Escrow Fee (\(String(format: "%.1f", escrowFee))%)",
                            value: escrowAmount
                        )
                        ClosingCostRow(label: "Recording Fee", value: recordingFee)
                    }
                    
                    // Inspection Fees
                    ClosingCostSection(
                        title: "INSPECTIONS",
                        total: totalInspectionFees
                    ) {
                        ClosingCostRow(label: "Home Inspection", value: homeInspection)
                        ClosingCostRow(label: "Survey", value: surveyFee)
                    }
                    
                    // Other Fees
                    ClosingCostSection(title: "OTHER", total: attorneyFee) {
                        ClosingCostRow(label: "Attorney/Legal Fees", value: attorneyFee)
                    }
                    
                    // Prepaids
                    ClosingCostSection(
                        title: "PREPAID ITEMS",
                        total: totalPrepaids
                    ) {
                        ClosingCostRow(
                            label: "Property Tax (\(Int(prepaidPropertyTax)) months)",
                            value: prepaidTaxAmount
                        )
                        ClosingCostRow(
                            label: "Insurance (\(Int(prepaidInsurance)) months)",
                            value: prepaidInsuranceAmount
                        )
                    }
                    
                    // Apply Button
                    Button(action: applyEstimate) {
                        Text("Apply to Deal Analysis")
                            .font(AppFonts.button)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppColors.primaryGradient)
                            .cornerRadius(14)
                    }
                    
                    Text("Closing costs will be set to \(String(format: "%.1f", closingCostPercent))% in your analysis")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textMuted)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Closing Costs")
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
        viewModel.deal.closingCostPercent = closingCostPercent
        dismiss()
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

// MARK: - Closing Cost Section

struct ClosingCostSection<Content: View>: View {
    let title: String
    let total: Double
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(AppFonts.metricLabel)
                    .foregroundColor(AppColors.textSecondary)
                
                Spacer()
                
                Text(formatCurrency(total))
                    .font(AppFonts.bodyBold)
                    .foregroundColor(AppColors.textAccent)
            }
            
            content
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

// MARK: - Closing Cost Row

struct ClosingCostRow: View {
    let label: String
    let value: Double
    
    var body: some View {
        HStack {
            Text(label)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
            
            Spacer()
            
            Text(formatCurrency(value))
                .font(AppFonts.body)
                .foregroundColor(AppColors.textPrimary)
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

#Preview {
    ClosingCostEstimatorView(viewModel: {
        let vm = DealViewModel()
        vm.deal = .sampleDeal
        return vm
    }())
}
