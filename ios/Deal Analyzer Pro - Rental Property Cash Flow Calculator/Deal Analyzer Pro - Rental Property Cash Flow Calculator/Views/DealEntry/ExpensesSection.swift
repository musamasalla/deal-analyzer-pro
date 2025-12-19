//
//  ExpensesSection.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/17.
//

import SwiftUI

/// Expenses input section with all monthly costs
struct ExpensesSection: View {
    @Bindable var viewModel: DealViewModel
    @State private var showAdvanced: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                title: "Expenses",
                icon: "arrow.up.circle.fill",
                subtitle: "Monthly operating expenses"
            )
            
            // Property Tax (Annual → Monthly)
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Annual Property Tax")
                        .font(AppFonts.fieldLabel)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Spacer()
                    
                    if viewModel.deal.annualPropertyTax > 0 {
                        Text("\(formatCurrency(viewModel.deal.monthlyPropertyTax))/mo")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textMuted)
                    }
                }
                
                HStack(spacing: 8) {
                    Text("$")
                        .font(AppFonts.currencyInput)
                        .foregroundColor(AppColors.textSecondary)
                    
                    TextField("0", value: $viewModel.deal.annualPropertyTax, format: .number)
                        .font(AppFonts.currencyInput)
                        .foregroundColor(AppColors.textPrimary)
                        .keyboardType(.decimalPad)
                    
                    Text("/year")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textMuted)
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
            
            // Monthly Insurance
            CurrencyTextField(
                title: "Monthly Insurance",
                value: $viewModel.deal.monthlyInsurance,
                placeholder: "150"
            )
            
            // HOA Fees
            CurrencyTextField(
                title: "Monthly HOA Fees",
                value: $viewModel.deal.monthlyHOA,
                placeholder: "0"
            )
            
            // Property Management %
            PercentageSlider(
                title: "Property Management",
                value: $viewModel.deal.propertyManagementPercent,
                range: 0...12,
                step: 1,
                suffix: "% of rent"
            )
            
            if viewModel.deal.monthlyRent > 0 {
                HStack {
                    Text("= \(formatCurrency(viewModel.deal.monthlyPropertyManagement))/month")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textMuted)
                    
                    Spacer()
                    
                    if viewModel.deal.propertyManagementPercent == 0 {
                        Text("Self-managed")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.successGreen)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, -8)
            }
            
            // Advanced Expenses Toggle
            Button(action: { withAnimation { showAdvanced.toggle() } }) {
                HStack {
                    Text(showAdvanced ? "Hide Advanced" : "Show Advanced Expenses")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.primaryTeal)
                    
                    Spacer()
                    
                    Image(systemName: showAdvanced ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.primaryTeal)
                }
                .padding(12)
                .background(AppColors.primaryTeal.opacity(0.1))
                .cornerRadius(10)
            }
            
            if showAdvanced {
                VStack(spacing: 16) {
                    // Maintenance Reserve %
                    PercentageSlider(
                        title: "Maintenance Reserve",
                        value: $viewModel.deal.maintenancePercent,
                        range: 0...5,
                        step: 0.5,
                        suffix: "% of value/year",
                        showDecimal: true
                    )
                    
                    if viewModel.deal.purchasePrice > 0 {
                        Text("= \(formatCurrency(viewModel.deal.monthlyMaintenanceReserve))/month")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textMuted)
                            .padding(.horizontal, 16)
                            .padding(.top, -8)
                    }
                    
                    // CapEx Reserve %
                    PercentageSlider(
                        title: "CapEx Reserve",
                        value: $viewModel.deal.capExPercent,
                        range: 0...5,
                        step: 0.5,
                        suffix: "% of value/year",
                        showDecimal: true
                    )
                    
                    if viewModel.deal.purchasePrice > 0 {
                        Text("= \(formatCurrency(viewModel.deal.monthlyCapExReserve))/month")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textMuted)
                            .padding(.horizontal, 16)
                            .padding(.top, -8)
                    }
                    
                    // Utilities (if landlord pays)
                    CurrencyTextField(
                        title: "Monthly Utilities (if landlord pays)",
                        value: $viewModel.deal.monthlyUtilities,
                        placeholder: "0"
                    )
                    
                    // Other Expenses
                    CurrencyTextField(
                        title: "Other Monthly Expenses",
                        value: $viewModel.deal.otherMonthlyExpenses,
                        placeholder: "0"
                    )
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            // Templates Button
            Menu {
                ForEach(ExpenseTemplate.templates) { template in
                    Button(action: { viewModel.applyTemplate(template) }) {
                        VStack(alignment: .leading) {
                            Text(template.name)
                            Text(template.description)
                                .font(.caption)
                        }
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "doc.on.doc.fill")
                    Text("Apply Template")
                    Spacer()
                    Image(systemName: "chevron.down")
                }
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
                .padding(12)
                .background(AppColors.inputBackground)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(AppColors.border, lineWidth: 1)
                )
            }
            
            // Total Monthly Expenses Display
            if viewModel.deal.monthlyOperatingExpenses > 0 {
                VStack(spacing: 8) {
                    Divider()
                        .background(AppColors.divider)
                    
                    HStack {
                        Text("Total Monthly Expenses")
                            .font(AppFonts.bodyBold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Spacer()
                        
                        Text(formatCurrency(viewModel.deal.monthlyOperatingExpenses))
                            .font(AppFonts.title2)
                            .foregroundColor(AppColors.dangerRed)
                    }
                    
                    if viewModel.deal.grossMonthlyIncome > 0 {
                        let expenseRatio = viewModel.deal.monthlyOperatingExpenses / viewModel.deal.grossMonthlyIncome * 100
                        
                        HStack {
                            Text("Expense Ratio")
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.textMuted)
                            
                            Spacer()
                            
                            Text("\(String(format: "%.0f", expenseRatio))% of gross rent")
                                .font(AppFonts.caption)
                                .foregroundColor(expenseRatio > 50 ? AppColors.warningAmber : AppColors.textMuted)
                        }
                    }
                }
            }
        }
        .padding(16)
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

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        ScrollView {
            ExpensesSection(viewModel: {
                let vm = DealViewModel()
                vm.deal.purchasePrice = 250000
                vm.deal.monthlyRent = 1800
                vm.deal.annualPropertyTax = 2400
                vm.deal.monthlyInsurance = 150
                return vm
            }())
            .padding()
        }
    }
}
