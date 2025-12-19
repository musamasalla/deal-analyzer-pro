//
//  PropertyDetailsSection.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/17.
//

import SwiftUI

/// Property details input section
struct PropertyDetailsSection: View {
    @Bindable var viewModel: DealViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                title: "Property Details",
                icon: "house.fill",
                subtitle: "Enter basic property information"
            )
            
            // Purchase Price (most important)
            CurrencyTextField(
                title: "Purchase Price",
                value: $viewModel.deal.purchasePrice,
                placeholder: "250,000"
            )
            
            // Address
            VStack(alignment: .leading, spacing: 6) {
                Text("Address (Optional)")
                    .font(AppFonts.fieldLabel)
                    .foregroundColor(AppColors.textSecondary)
                
                TextField("123 Main Street, City, State", text: $viewModel.deal.address)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(AppColors.inputBackground)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.border, lineWidth: 1)
                    )
            }
            
            // Property Type
            VStack(alignment: .leading, spacing: 6) {
                Text("Property Type")
                    .font(AppFonts.fieldLabel)
                    .foregroundColor(AppColors.textSecondary)
                
                Menu {
                    ForEach(PropertyType.allCases) { type in
                        Button(action: { viewModel.deal.propertyType = type }) {
                            HStack {
                                Image(systemName: type.iconName)
                                Text(type.rawValue)
                                if viewModel.deal.propertyType == type {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: viewModel.deal.propertyType.iconName)
                            .foregroundColor(AppColors.primaryTeal)
                        
                        Text(viewModel.deal.propertyType.rawValue)
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textSecondary)
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
            }
            
            // Beds/Baths Row
            HStack(spacing: 12) {
                NumberInputField(
                    title: "Bedrooms",
                    value: $viewModel.deal.bedrooms,
                    icon: "bed.double.fill"
                )
                
                DecimalInputField(
                    title: "Bathrooms",
                    value: $viewModel.deal.bathrooms,
                    icon: "shower.fill"
                )
            }
            
            // Square Footage & Year Built
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Square Footage")
                        .font(AppFonts.fieldLabel)
                        .foregroundColor(AppColors.textSecondary)
                    
                    HStack {
                        TextField("0", value: $viewModel.deal.squareFootage, format: .number)
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textPrimary)
                            .keyboardType(.numberPad)
                        
                        Text("sqft")
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
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Year Built")
                        .font(AppFonts.fieldLabel)
                        .foregroundColor(AppColors.textSecondary)
                    
                    TextField("2000", value: $viewModel.deal.yearBuilt, format: .number)
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textPrimary)
                        .keyboardType(.numberPad)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(AppColors.inputBackground)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                }
            }
        }
        .padding(16)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
}

// MARK: - Helper Input Fields

struct NumberInputField: View {
    let title: String
    @Binding var value: Int
    var icon: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(AppFonts.fieldLabel)
                .foregroundColor(AppColors.textSecondary)
            
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                TextField("0", value: $value, format: .number)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textPrimary)
                    .keyboardType(.numberPad)
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
    }
}

struct DecimalInputField: View {
    let title: String
    @Binding var value: Double
    var icon: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(AppFonts.fieldLabel)
                .foregroundColor(AppColors.textSecondary)
            
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                TextField("0", value: $value, format: .number.precision(.fractionLength(1)))
                    .font(AppFonts.body)
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
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        ScrollView {
            PropertyDetailsSection(viewModel: DealViewModel())
                .padding()
        }
    }
}
