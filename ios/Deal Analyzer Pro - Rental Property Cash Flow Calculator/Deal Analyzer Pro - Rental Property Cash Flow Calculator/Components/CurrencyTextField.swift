//
//  CurrencyTextField.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/17.
//

import SwiftUI

/// Custom currency input field with $ formatting
struct CurrencyTextField: View {
    let title: String
    @Binding var value: Double
    var placeholder: String = "0"
    var showCents: Bool = false
    
    @State private var textValue: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(AppFonts.fieldLabel)
                .foregroundColor(AppColors.textSecondary)
            
            HStack(spacing: 8) {
                Text("$")
                    .font(AppFonts.currencyInput)
                    .foregroundColor(isFocused ? AppColors.primaryTeal : AppColors.textSecondary)
                
                TextField(placeholder, text: $textValue)
                    .font(AppFonts.currencyInput)
                    .foregroundColor(AppColors.textPrimary)
                    .keyboardType(.decimalPad)
                    .focused($isFocused)
                    .onChange(of: textValue) { _, newValue in
                        let filtered = newValue.filter { $0.isNumber || $0 == "." }
                        if filtered != newValue {
                            textValue = filtered
                        }
                        if let number = Double(filtered) {
                            value = number
                        }
                    }
                    .onChange(of: isFocused) { _, focused in
                        if !focused {
                            formatValue()
                        }
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(AppColors.inputBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isFocused ? AppColors.primaryTeal : AppColors.border, lineWidth: 1)
            )
        }
        .onAppear {
            formatValue()
        }
    }
    
    private func formatValue() {
        if value == 0 {
            textValue = ""
        } else if showCents {
            textValue = String(format: "%.2f", value)
        } else {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 0
            textValue = formatter.string(from: NSNumber(value: value)) ?? ""
        }
    }
}

/// Compact currency input for Quick Entry mode
struct CompactCurrencyField: View {
    let title: String
    @Binding var value: Double
    
    @State private var textValue: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)
            
            HStack(spacing: 4) {
                Text("$")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
                
                TextField("0", text: $textValue)
                    .font(AppFonts.bodyBold)
                    .foregroundColor(AppColors.textPrimary)
                    .keyboardType(.decimalPad)
                    .focused($isFocused)
                    .onChange(of: textValue) { _, newValue in
                        let filtered = newValue.filter { $0.isNumber || $0 == "." }
                        if filtered != newValue {
                            textValue = filtered
                        }
                        if let number = Double(filtered) {
                            value = number
                        }
                    }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(AppColors.inputBackground)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isFocused ? AppColors.primaryTeal : AppColors.border, lineWidth: 1)
            )
        }
        .onAppear {
            if value > 0 {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.maximumFractionDigits = 0
                textValue = formatter.string(from: NSNumber(value: value)) ?? ""
            }
        }
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        VStack(spacing: 20) {
            CurrencyTextField(
                title: "Purchase Price",
                value: .constant(250000)
            )
            
            CompactCurrencyField(
                title: "Rent",
                value: .constant(1800)
            )
        }
        .padding()
    }
}
