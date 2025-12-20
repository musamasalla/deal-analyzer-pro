//
//  ExportOptionsView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/18.
//

import SwiftUI

/// Export and share options for a deal
struct ExportOptionsView: View {
    @Bindable var viewModel: DealViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingShareSheet: Bool = false
    @State private var exportData: Any?
    @State private var isGenerating: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ExportOptionRow(
                        icon: "doc.richtext.fill",
                        title: "PDF Report",
                        subtitle: "Professional analysis report",
                        color: .red
                    ) {
                        generatePDFReport()
                    }
                    
                    ExportOptionRow(
                        icon: "tablecells.fill",
                        title: "CSV Export",
                        subtitle: "Spreadsheet-compatible data",
                        color: .green
                    ) {
                        generateCSVExport()
                    }
                    
                    ExportOptionRow(
                        icon: "doc.text.fill",
                        title: "Text Summary",
                        subtitle: "Plain text overview",
                        color: .blue
                    ) {
                        generateTextSummary()
                    }
                } header: {
                    Text("Export Formats")
                }
                
                Section {
                    ExportOptionRow(
                        icon: "message.fill",
                        title: "Share via Messages",
                        subtitle: "Quick text summary",
                        color: .green
                    ) {
                        shareViaMessages()
                    }
                    
                    ExportOptionRow(
                        icon: "envelope.fill",
                        title: "Email Report",
                        subtitle: "Send PDF via email",
                        color: .blue
                    ) {
                        emailReport()
                    }
                    
                    ExportOptionRow(
                        icon: "doc.on.clipboard.fill",
                        title: "Copy to Clipboard",
                        subtitle: "Copy key metrics",
                        color: .orange
                    ) {
                        copyToClipboard()
                    }
                } header: {
                    Text("Share")
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Deal Summary")
                            .font(AppFonts.sectionHeader)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text(dealSummaryText)
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Preview")
                }
            }
            .navigationTitle("Export & Share")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AppColors.primaryTeal)
                }
            }
            .overlay {
                if isGenerating {
                    ProgressView("Generating...")
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let data = exportData {
                    ShareSheet(items: [data])
                }
            }
        }
    }
    
    var dealSummaryText: String {
        """
        \(viewModel.deal.name.isEmpty ? "Property Analysis" : viewModel.deal.name)
        Price: \(formatCurrency(viewModel.deal.purchasePrice))
        Monthly Cash Flow: \(formatCurrency(viewModel.results.monthlyCashFlow))
        CoC Return: \(String(format: "%.1f%%", viewModel.results.cashOnCashReturn))
        Cap Rate: \(String(format: "%.1f%%", viewModel.results.capRate))
        """
    }
    
    private func generatePDFReport() {
        isGenerating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let pdfData = viewModel.generatePDFReport() {
                exportData = pdfData
                showingShareSheet = true
            }
            isGenerating = false
        }
    }
    
    private func generateCSVExport() {
        let csv = """
        Property Analysis Export
        
        Property Details
        Name,\(viewModel.deal.name)
        Address,\(viewModel.deal.address)
        Purchase Price,\(viewModel.deal.purchasePrice)
        Property Type,\(viewModel.deal.propertyType.displayName)
        
        Financing
        Down Payment %,\(viewModel.deal.downPaymentPercent)
        Interest Rate %,\(viewModel.deal.interestRate)
        Loan Term Years,\(viewModel.deal.loanTermYears)
        
        Income
        Monthly Rent,\(viewModel.deal.monthlyRent)
        Vacancy Rate %,\(viewModel.deal.vacancyRatePercent)
        
        Results
        Monthly Cash Flow,\(viewModel.results.monthlyCashFlow)
        Annual Cash Flow,\(viewModel.results.annualCashFlow)
        Cash on Cash Return %,\(viewModel.results.cashOnCashReturn)
        Cap Rate %,\(viewModel.results.capRate)
        DSCR,\(viewModel.results.debtServiceCoverageRatio)
        """
        
        exportData = csv
        showingShareSheet = true
    }
    
    private func generateTextSummary() {
        exportData = dealSummaryText
        showingShareSheet = true
    }
    
    private func shareViaMessages() {
        exportData = dealSummaryText
        showingShareSheet = true
    }
    
    private func emailReport() {
        generatePDFReport()
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = dealSummaryText
        HapticManager.shared.success()
        dismiss()
    }
    
    private func formatCurrency(_ value: Double) -> String {
        return CurrencyFormatter.format(value)
    }
}

// MARK: - Export Option Row

struct ExportOptionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(color)
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(subtitle)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textMuted)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textMuted)
            }
        }
    }
}

#Preview {
    ExportOptionsView(viewModel: {
        let vm = DealViewModel()
        vm.deal = .sampleDeal
        return vm
    }())
}
