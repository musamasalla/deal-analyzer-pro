//
//  QuickInputRow.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/18.
//

import SwiftUI

/// Compact inline input for quick data entry
struct QuickInputRow: View {
    let label: String
    @Binding var value: Double
    let format: InputFormat
    var prefix: String = ""
    var suffix: String = ""
    
    enum InputFormat {
        case currency
        case percent
        case number
    }
    
    @State private var textValue: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack {
            Text(label)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
            
            Spacer()
            
            HStack(spacing: 4) {
                if !prefix.isEmpty {
                    Text(prefix)
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textMuted)
                }
                
                TextField("0", text: $textValue)
                    .font(AppFonts.bodyBold)
                    .foregroundColor(AppColors.textPrimary)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: format == .currency ? 100 : 60)
                    .focused($isFocused)
                    .onChange(of: textValue) { _, newValue in
                        if let parsed = Double(newValue.replacingOccurrences(of: ",", with: "")) {
                            value = parsed
                        }
                    }
                    .onAppear {
                        updateTextFromValue()
                    }
                    .onChange(of: value) { _, _ in
                        if !isFocused {
                            updateTextFromValue()
                        }
                    }
                
                if !suffix.isEmpty {
                    Text(suffix)
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textMuted)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(AppColors.inputBackground)
            .cornerRadius(8)
        }
    }
    
    private func updateTextFromValue() {
        switch format {
        case .currency:
            textValue = value > 0 ? String(format: "%.0f", value) : ""
        case .percent:
            textValue = value > 0 ? String(format: "%.1f", value) : ""
        case .number:
            textValue = value > 0 ? String(format: "%.0f", value) : ""
        }
    }
}

// MARK: - Stepper Input

struct StepperInputRow: View {
    let label: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int
    
    var body: some View {
        HStack {
            Text(label)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: { 
                    if value - step >= range.lowerBound {
                        value -= step
                        HapticManager.shared.lightImpact()
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(value <= range.lowerBound ? AppColors.textMuted : AppColors.primaryTeal)
                }
                .disabled(value <= range.lowerBound)
                
                Text("\(value)")
                    .font(AppFonts.bodyBold)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(minWidth: 40)
                
                Button(action: { 
                    if value + step <= range.upperBound {
                        value += step
                        HapticManager.shared.lightImpact()
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(value >= range.upperBound ? AppColors.textMuted : AppColors.primaryTeal)
                }
                .disabled(value >= range.upperBound)
            }
        }
    }
}

// MARK: - Toggle Input Row

struct ToggleInputRow: View {
    let label: String
    @Binding var isOn: Bool
    var subtitle: String? = nil
    
    var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textMuted)
                }
            }
        }
        .tint(AppColors.primaryTeal)
        .onChange(of: isOn) { _, _ in
            HapticManager.shared.selection()
        }
    }
}

// MARK: - Segment Picker Row

struct SegmentPickerRow<T: Hashable & CustomStringConvertible>: View {
    let label: String
    @Binding var selection: T
    let options: [T]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(AppFonts.fieldLabel)
                .foregroundColor(AppColors.textSecondary)
            
            Picker(label, selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(option.description).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selection) { _, _ in
                HapticManager.shared.selection()
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        QuickInputRow(label: "Purchase Price", value: .constant(250000), format: .currency, prefix: "$")
        QuickInputRow(label: "Down Payment", value: .constant(20), format: .percent, suffix: "%")
        StepperInputRow(label: "Bedrooms", value: .constant(3), range: 1...10, step: 1)
        ToggleInputRow(label: "Cash Purchase", isOn: .constant(false), subtitle: "No financing needed")
    }
    .padding()
    .background(AppColors.cardBackground)
}
