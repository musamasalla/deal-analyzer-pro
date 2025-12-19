//
//  RepairEstimatorView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/19.
//

import SwiftUI

/// Itemized repair/rehab cost estimator
struct RepairEstimatorView: View {
    @Bindable var viewModel: DealViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var repairs: [RepairItem] = RepairItem.defaultItems
    @State private var laborMultiplier: Double = 1.0
    @State private var contingencyPercent: Double = 10
    
    var subtotal: Double {
        repairs.filter { $0.isSelected }.reduce(0) { $0 + $1.totalCost }
    }
    
    var laborCost: Double {
        subtotal * (laborMultiplier - 1.0)
    }
    
    var contingency: Double {
        (subtotal + laborCost) * (contingencyPercent / 100)
    }
    
    var totalCost: Double {
        subtotal + laborCost + contingency
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Total Display
                VStack(spacing: 8) {
                    Text("ESTIMATED REPAIR COST")
                        .font(AppFonts.metricLabel)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text(formatCurrency(totalCost))
                        .font(AppFonts.cashFlowDisplay)
                        .foregroundColor(AppColors.warningAmber)
                    
                    Text("\(repairs.filter { $0.isSelected }.count) items selected")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textMuted)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(AppColors.cardBackground)
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Repair Categories
                        ForEach(RepairCategory.allCases, id: \.self) { category in
                            RepairCategorySection(
                                category: category,
                                repairs: $repairs
                            )
                        }
                        
                        // Labor Multiplier
                        VStack(alignment: .leading, spacing: 12) {
                            Text("LABOR ADJUSTMENT")
                                .font(AppFonts.metricLabel)
                                .foregroundColor(AppColors.textSecondary)
                            
                            HStack {
                                Text("Labor Cost Factor")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.textSecondary)
                                Spacer()
                                Text(String(format: "%.1fx", laborMultiplier))
                                    .font(AppFonts.bodyBold)
                                    .foregroundColor(AppColors.textPrimary)
                            }
                            
                            Slider(value: $laborMultiplier, in: 1.0...2.5, step: 0.1)
                                .tint(AppColors.primaryTeal)
                            
                            Text("1.0x = DIY, 1.5x = Handyman, 2.0x = Licensed Contractor")
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.textMuted)
                        }
                        .padding()
                        .background(AppColors.cardBackground)
                        .cornerRadius(16)
                        
                        // Contingency
                        VStack(alignment: .leading, spacing: 12) {
                            Text("CONTINGENCY")
                                .font(AppFonts.metricLabel)
                                .foregroundColor(AppColors.textSecondary)
                            
                            HStack {
                                Text("Buffer for Unknowns")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.textSecondary)
                                Spacer()
                                Text(String(format: "%.0f%%", contingencyPercent))
                                    .font(AppFonts.bodyBold)
                                    .foregroundColor(AppColors.textPrimary)
                            }
                            
                            Slider(value: $contingencyPercent, in: 0...30, step: 5)
                                .tint(AppColors.warningAmber)
                        }
                        .padding()
                        .background(AppColors.cardBackground)
                        .cornerRadius(16)
                        
                        // Summary
                        VStack(alignment: .leading, spacing: 12) {
                            Text("COST BREAKDOWN")
                                .font(AppFonts.metricLabel)
                                .foregroundColor(AppColors.textSecondary)
                            
                            SummaryRow(label: "Materials & Base Costs", value: formatCurrency(subtotal))
                            SummaryRow(label: "Labor Adjustment", value: "+" + formatCurrency(laborCost))
                            SummaryRow(label: "Contingency (\(Int(contingencyPercent))%)", value: "+" + formatCurrency(contingency))
                            
                            Divider().background(AppColors.divider)
                            
                            SummaryRow(label: "Total Estimate", value: formatCurrency(totalCost), isHighlighted: true)
                        }
                        .padding()
                        .background(AppColors.cardBackground)
                        .cornerRadius(16)
                        
                        // Apply Button
                        Button(action: applyToMainDeal) {
                            Text("Add to Deal Analysis")
                                .font(AppFonts.bodyBold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppColors.primaryTeal)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Repair Estimator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppColors.textSecondary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Reset") {
                        repairs = RepairItem.defaultItems
                    }
                    .foregroundColor(AppColors.dangerRed)
                }
            }
        }
    }
    
    private func applyToMainDeal() {
        viewModel.deal.otherMonthlyExpenses += totalCost / 12 // Spread over first year
        dismiss()
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

// MARK: - Repair Category

enum RepairCategory: String, CaseIterable {
    case exterior = "Exterior"
    case interior = "Interior"
    case kitchen = "Kitchen"
    case bathroom = "Bathroom"
    case systems = "Systems"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .exterior: return "house.fill"
        case .interior: return "sofa.fill"
        case .kitchen: return "refrigerator.fill"
        case .bathroom: return "shower.fill"
        case .systems: return "gearshape.fill"
        case .other: return "wrench.fill"
        }
    }
}

// MARK: - Repair Item

struct RepairItem: Identifiable {
    let id = UUID()
    var name: String
    var category: RepairCategory
    var unitCost: Double
    var quantity: Int
    var isSelected: Bool
    
    var totalCost: Double {
        isSelected ? unitCost * Double(quantity) : 0
    }
    
    static var defaultItems: [RepairItem] {
        [
            // Exterior
            RepairItem(name: "Roof Replacement", category: .exterior, unitCost: 8000, quantity: 1, isSelected: false),
            RepairItem(name: "Exterior Paint", category: .exterior, unitCost: 3000, quantity: 1, isSelected: false),
            RepairItem(name: "Siding Repair", category: .exterior, unitCost: 2000, quantity: 1, isSelected: false),
            RepairItem(name: "Windows (each)", category: .exterior, unitCost: 400, quantity: 1, isSelected: false),
            RepairItem(name: "Landscaping", category: .exterior, unitCost: 1500, quantity: 1, isSelected: false),
            
            // Interior
            RepairItem(name: "Interior Paint (per room)", category: .interior, unitCost: 300, quantity: 5, isSelected: false),
            RepairItem(name: "Flooring (per sqft)", category: .interior, unitCost: 5, quantity: 1000, isSelected: false),
            RepairItem(name: "Drywall Repair", category: .interior, unitCost: 500, quantity: 1, isSelected: false),
            RepairItem(name: "Door (each)", category: .interior, unitCost: 150, quantity: 1, isSelected: false),
            
            // Kitchen
            RepairItem(name: "Full Kitchen Remodel", category: .kitchen, unitCost: 15000, quantity: 1, isSelected: false),
            RepairItem(name: "Countertops", category: .kitchen, unitCost: 2500, quantity: 1, isSelected: false),
            RepairItem(name: "Cabinets", category: .kitchen, unitCost: 4000, quantity: 1, isSelected: false),
            RepairItem(name: "Appliances Package", category: .kitchen, unitCost: 2000, quantity: 1, isSelected: false),
            
            // Bathroom
            RepairItem(name: "Full Bath Remodel", category: .bathroom, unitCost: 8000, quantity: 1, isSelected: false),
            RepairItem(name: "Vanity + Sink", category: .bathroom, unitCost: 500, quantity: 1, isSelected: false),
            RepairItem(name: "Toilet", category: .bathroom, unitCost: 200, quantity: 1, isSelected: false),
            RepairItem(name: "Tile Work", category: .bathroom, unitCost: 1500, quantity: 1, isSelected: false),
            
            // Systems
            RepairItem(name: "HVAC System", category: .systems, unitCost: 6000, quantity: 1, isSelected: false),
            RepairItem(name: "Water Heater", category: .systems, unitCost: 1200, quantity: 1, isSelected: false),
            RepairItem(name: "Electrical Panel", category: .systems, unitCost: 2000, quantity: 1, isSelected: false),
            RepairItem(name: "Plumbing Repairs", category: .systems, unitCost: 1500, quantity: 1, isSelected: false),
            
            // Other
            RepairItem(name: "Permits", category: .other, unitCost: 500, quantity: 1, isSelected: false),
            RepairItem(name: "Dumpster/Cleanup", category: .other, unitCost: 400, quantity: 1, isSelected: false),
            RepairItem(name: "Misc Repairs", category: .other, unitCost: 1000, quantity: 1, isSelected: false),
        ]
    }
}

// MARK: - Repair Category Section

struct RepairCategorySection: View {
    let category: RepairCategory
    @Binding var repairs: [RepairItem]
    
    var categoryItems: [RepairItem] {
        repairs.filter { $0.category == category }
    }
    
    var selectedCount: Int {
        categoryItems.filter { $0.isSelected }.count
    }
    
    var categoryTotal: Double {
        categoryItems.reduce(0) { $0 + $1.totalCost }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: category.icon)
                    .foregroundColor(AppColors.primaryTeal)
                
                Text(category.rawValue.uppercased())
                    .font(AppFonts.metricLabel)
                    .foregroundColor(AppColors.textSecondary)
                
                Spacer()
                
                if selectedCount > 0 {
                    Text(formatCurrency(categoryTotal))
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.warningAmber)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppColors.warningAmber.opacity(0.1))
                        .cornerRadius(6)
                }
            }
            
            ForEach(categoryItems) { item in
                RepairItemRow(
                    item: item,
                    onToggle: { toggleItem(item) },
                    onQuantityChange: { qty in updateQuantity(item, qty) }
                )
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
    
    private func toggleItem(_ item: RepairItem) {
        if let index = repairs.firstIndex(where: { $0.id == item.id }) {
            repairs[index].isSelected.toggle()
        }
    }
    
    private func updateQuantity(_ item: RepairItem, _ qty: Int) {
        if let index = repairs.firstIndex(where: { $0.id == item.id }) {
            repairs[index].quantity = qty
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

// MARK: - Repair Item Row

struct RepairItemRow: View {
    let item: RepairItem
    let onToggle: () -> Void
    let onQuantityChange: (Int) -> Void
    
    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: item.isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isSelected ? AppColors.successGreen : AppColors.textMuted)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(AppFonts.body)
                    .foregroundColor(item.isSelected ? AppColors.textPrimary : AppColors.textSecondary)
                
                Text(formatCurrency(item.unitCost) + " each")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)
            }
            
            Spacer()
            
            if item.isSelected {
                Stepper(value: Binding(
                    get: { item.quantity },
                    set: { onQuantityChange($0) }
                ), in: 1...100) {
                    Text("\(item.quantity)")
                        .font(AppFonts.bodyBold)
                        .foregroundColor(AppColors.textPrimary)
                        .frame(width: 30)
                }
                .frame(width: 100)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

#Preview {
    RepairEstimatorView(viewModel: DealViewModel())
}
