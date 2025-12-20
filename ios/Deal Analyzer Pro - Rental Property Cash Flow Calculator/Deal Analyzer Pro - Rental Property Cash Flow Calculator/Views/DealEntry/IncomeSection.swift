//
//  IncomeSection.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/17.
//

import SwiftUI

/// Income input section with rent, other income, and vacancy
struct IncomeSection: View {
    @Bindable var viewModel: DealViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                title: "Income",
                icon: "arrow.down.circle.fill",
                subtitle: "Monthly rental income and vacancy"
            )
            
            // Monthly Rent
            CurrencyTextField(
                title: "Monthly Rent",
                value: $viewModel.deal.monthlyRent,
                placeholder: "1,800"
            )
            
            // Other Monthly Income
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Other Monthly Income")
                        .font(AppFonts.fieldLabel)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Spacer()
                    
                    Text("(parking, laundry, storage)")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textMuted)
                }
                
                HStack(spacing: 8) {
                    Text("$")
                        .font(AppFonts.currencyInput)
                        .foregroundColor(AppColors.textSecondary)
                    
                    TextField("0", value: $viewModel.deal.otherMonthlyIncome, format: .number)
                        .font(AppFonts.currencyInput)
                        .foregroundColor(AppColors.textPrimary)
                        .keyboardType(.decimalPad)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(AppColors.inputBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.border, lineWidth: 1)
                )
            }
            
            // Vacancy Rate Slider
            PercentageSlider(
                title: "Vacancy Rate",
                value: $viewModel.deal.vacancyRatePercent,
                range: 0...20,
                step: 1
            )
            
            // Effective Income Display
            if viewModel.deal.monthlyRent > 0 {
                VStack(spacing: 12) {
                    HStack {
                        Text("Gross Monthly Income")
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Spacer()
                        
                        Text(formatCurrency(viewModel.deal.grossMonthlyIncome))
                            .font(AppFonts.bodyBold)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    
                    HStack {
                        Text("Vacancy Loss (\(Int(viewModel.deal.vacancyRatePercent))%)")
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Spacer()
                        
                        Text("-\(formatCurrency(viewModel.deal.grossMonthlyIncome - viewModel.deal.effectiveMonthlyIncome))")
                            .font(AppFonts.bodyBold)
                            .foregroundColor(AppColors.dangerRed)
                    }
                    
                    Divider()
                        .background(AppColors.divider)
                    
                    HStack {
                        Text("Effective Monthly Income")
                            .font(AppFonts.bodyBold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Spacer()
                        
                        Text(formatCurrency(viewModel.deal.effectiveMonthlyIncome))
                            .font(AppFonts.title2)
                            .foregroundColor(AppColors.successGreen)
                    }
                }
                .padding(16)
                .background(
                    LinearGradient(
                        colors: [AppColors.successGreen.opacity(0.1), AppColors.successGreen.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.successGreen.opacity(0.3), lineWidth: 1)
                )
            }
            
            // 1% Rule Indicator
            if viewModel.deal.purchasePrice > 0 && viewModel.deal.monthlyRent > 0 {
                let onePercentRule = viewModel.deal.monthlyRent / viewModel.deal.purchasePrice * 100
                let isGood = onePercentRule >= 1.0
                
                HStack(spacing: 12) {
                    Image(systemName: isGood ? "checkmark.circle.fill" : "info.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(isGood ? AppColors.successGreen : AppColors.warningAmber)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("1% Rule: \(String(format: "%.2f", onePercentRule))%")
                            .font(AppFonts.bodyBold)
                            .foregroundColor(isGood ? AppColors.successGreen : AppColors.warningAmber)
                        
                        Text(isGood ? "Rent meets or exceeds 1% of purchase price" : "Rent is below 1% of purchase price")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textMuted)
                    }
                    
                    Spacer()
                }
                .padding(12)
                .background(
                    (isGood ? AppColors.successGreen : AppColors.warningAmber).opacity(0.1)
                )
                .cornerRadius(10)
            }
        }
        .padding(16)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        return CurrencyFormatter.format(value)
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        ScrollView {
            IncomeSection(viewModel: {
                let vm = DealViewModel()
                vm.deal.purchasePrice = 250000
                vm.deal.monthlyRent = 1800
                return vm
            }())
            .padding()
        }
    }
}
