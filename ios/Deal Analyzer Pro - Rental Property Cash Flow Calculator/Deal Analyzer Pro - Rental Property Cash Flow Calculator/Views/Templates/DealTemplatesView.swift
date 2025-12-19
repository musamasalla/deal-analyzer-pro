//
//  DealTemplatesView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/19.
//

import SwiftUI

/// Pre-filled deal templates for different investment strategies
struct DealTemplatesView: View {
    @Bindable var viewModel: DealViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Choose a template to quick-start your analysis")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.horizontal)
                    
                    // Property Type Templates
                    VStack(alignment: .leading, spacing: 12) {
                        Text("BY PROPERTY TYPE")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        TemplateCard(
                            icon: "house.fill",
                            title: "Single Family Home",
                            description: "Typical SFR rental in suburban area",
                            color: .blue,
                            template: .singleFamily
                        ) {
                            applyTemplate(.singleFamily)
                        }
                        
                        TemplateCard(
                            icon: "building.2.fill",
                            title: "Duplex",
                            description: "House-hack or small multi-family",
                            color: .green,
                            template: .duplex
                        ) {
                            applyTemplate(.duplex)
                        }
                        
                        TemplateCard(
                            icon: "building.fill",
                            title: "Small Apartment",
                            description: "4-plex or small apartment building",
                            color: .purple,
                            template: .smallApartment
                        ) {
                            applyTemplate(.smallApartment)
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Strategy Templates
                    VStack(alignment: .leading, spacing: 12) {
                        Text("BY STRATEGY")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        TemplateCard(
                            icon: "arrow.triangle.2.circlepath",
                            title: "BRRRR Deal",
                            description: "Buy, Rehab, Rent, Refinance, Repeat",
                            color: .orange,
                            template: .brrrr
                        ) {
                            applyTemplate(.brrrr)
                        }
                        
                        TemplateCard(
                            icon: "banknote.fill",
                            title: "Cash Flow Focus",
                            description: "Maximize monthly cash flow",
                            color: .teal,
                            template: .cashFlow
                        ) {
                            applyTemplate(.cashFlow)
                        }
                        
                        TemplateCard(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Appreciation Play",
                            description: "Focus on long-term value growth",
                            color: .pink,
                            template: .appreciation
                        ) {
                            applyTemplate(.appreciation)
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Market Templates
                    VStack(alignment: .leading, spacing: 12) {
                        Text("BY MARKET")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        TemplateCard(
                            icon: "building.2.crop.circle.fill",
                            title: "High Cost Market",
                            description: "Coastal cities, expensive metros",
                            color: .red,
                            template: .highCost
                        ) {
                            applyTemplate(.highCost)
                        }
                        
                        TemplateCard(
                            icon: "house.and.flag.fill",
                            title: "Midwest Cash Flow",
                            description: "Affordable markets with strong yields",
                            color: .indigo,
                            template: .midwestCashFlow
                        ) {
                            applyTemplate(.midwestCashFlow)
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                }
                .padding()
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Deal Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }
    
    private func applyTemplate(_ template: DealTemplate) {
        let deal = template.createDeal()
        viewModel.deal = deal
        dismiss()
    }
}

// MARK: - Deal Template Enum

enum DealTemplate: String, CaseIterable {
    case singleFamily
    case duplex
    case smallApartment
    case brrrr
    case cashFlow
    case appreciation
    case highCost
    case midwestCashFlow
    
    func createDeal() -> PropertyDeal {
        var deal = PropertyDeal()
        
        switch self {
        case .singleFamily:
            deal.name = "SFR Analysis"
            deal.propertyType = .singleFamily
            deal.purchasePrice = 250000
            deal.downPaymentPercent = 20
            deal.interestRate = 7.0
            deal.loanTermYears = 30
            deal.monthlyRent = 1800
            deal.annualPropertyTax = 3000
            deal.monthlyInsurance = 150
            deal.vacancyRatePercent = 5
            deal.maintenancePercent = 5
            deal.propertyManagementPercent = 8
            
        case .duplex:
            deal.name = "Duplex Analysis"
            deal.propertyType = .duplex
            deal.purchasePrice = 350000
            deal.downPaymentPercent = 25
            deal.interestRate = 7.0
            deal.loanTermYears = 30
            deal.monthlyRent = 2800
            deal.annualPropertyTax = 4200
            deal.monthlyInsurance = 200
            deal.vacancyRatePercent = 5
            deal.maintenancePercent = 6
            deal.propertyManagementPercent = 10
            
        case .smallApartment:
            deal.name = "4-Plex Analysis"
            deal.propertyType = .fourplex
            deal.purchasePrice = 600000
            deal.downPaymentPercent = 25
            deal.interestRate = 7.25
            deal.loanTermYears = 30
            deal.monthlyRent = 4800
            deal.annualPropertyTax = 7200
            deal.monthlyInsurance = 400
            deal.vacancyRatePercent = 8
            deal.maintenancePercent = 8
            deal.propertyManagementPercent = 10
            
        case .brrrr:
            deal.name = "BRRRR Deal"
            deal.propertyType = .singleFamily
            deal.purchasePrice = 120000
            deal.downPaymentPercent = 100 // Cash purchase
            deal.monthlyRent = 1400
            deal.annualPropertyTax = 1800
            deal.monthlyInsurance = 100
            deal.vacancyRatePercent = 5
            deal.maintenancePercent = 10
            deal.propertyManagementPercent = 10
            
        case .cashFlow:
            deal.name = "Cash Flow Deal"
            deal.propertyType = .singleFamily
            deal.purchasePrice = 150000
            deal.downPaymentPercent = 25
            deal.interestRate = 7.0
            deal.loanTermYears = 30
            deal.monthlyRent = 1500
            deal.annualPropertyTax = 1800
            deal.monthlyInsurance = 100
            deal.vacancyRatePercent = 5
            deal.maintenancePercent = 5
            deal.propertyManagementPercent = 10
            
        case .appreciation:
            deal.name = "Appreciation Play"
            deal.propertyType = .singleFamily
            deal.purchasePrice = 400000
            deal.downPaymentPercent = 20
            deal.interestRate = 6.5
            deal.loanTermYears = 30
            deal.monthlyRent = 2200
            deal.annualPropertyTax = 4800
            deal.monthlyInsurance = 200
            deal.vacancyRatePercent = 3
            deal.maintenancePercent = 3
            deal.appreciationRatePercent = 5
            
        case .highCost:
            deal.name = "Coastal Market"
            deal.propertyType = .singleFamily
            deal.purchasePrice = 800000
            deal.downPaymentPercent = 20
            deal.interestRate = 6.5
            deal.loanTermYears = 30
            deal.monthlyRent = 3500
            deal.annualPropertyTax = 10000
            deal.monthlyInsurance = 300
            deal.vacancyRatePercent = 3
            deal.maintenancePercent = 3
            deal.appreciationRatePercent = 4
            
        case .midwestCashFlow:
            deal.name = "Midwest Cash Cow"
            deal.propertyType = .singleFamily
            deal.purchasePrice = 100000
            deal.downPaymentPercent = 20
            deal.interestRate = 7.0
            deal.loanTermYears = 30
            deal.monthlyRent = 1100
            deal.annualPropertyTax = 1500
            deal.monthlyInsurance = 80
            deal.vacancyRatePercent = 8
            deal.maintenancePercent = 8
            deal.propertyManagementPercent = 10
        }
        
        return deal
    }
}

// MARK: - Template Card

struct TemplateCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let template: DealTemplate
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
                    Text(title)
                        .font(AppFonts.bodyBold)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(description)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textMuted)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(color)
            }
            .padding()
            .background(AppColors.inputBackground)
            .cornerRadius(12)
        }
    }
}

#Preview {
    DealTemplatesView(viewModel: DealViewModel())
}
