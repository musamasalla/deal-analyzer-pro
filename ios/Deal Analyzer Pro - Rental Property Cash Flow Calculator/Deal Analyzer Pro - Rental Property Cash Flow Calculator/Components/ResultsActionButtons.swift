//
//  ResultsActionButtons.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/18.
//

import SwiftUI

/// Small action button for results dashboard
struct ActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.primaryTeal)
                
                Text(title)
                    .font(AppFonts.caption2)
                    .foregroundColor(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(AppColors.cardBackground)
            .cornerRadius(12)
        }
    }
}

/// PDF Preview Sheet with share functionality
struct PDFPreviewSheet: View {
    @Bindable var viewModel: DealViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var pdfData: Data?
    @State private var showingShareSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                if let pdfData = pdfData {
                    VStack(spacing: 20) {
                        // Preview placeholder
                        VStack(spacing: 16) {
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 60))
                                .foregroundColor(AppColors.primaryTeal)
                            
                            Text("PDF Report Ready")
                                .font(AppFonts.title2)
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("\(pdfData.count / 1024) KB")
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.textMuted)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(40)
                        .background(AppColors.cardBackground)
                        .cornerRadius(16)
                        
                        // Share Button
                        Button(action: { showingShareSheet = true }) {
                            Label("Share PDF", systemImage: "square.and.arrow.up")
                                .font(AppFonts.button)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(AppColors.primaryGradient)
                                .cornerRadius(14)
                        }
                        
                        // Report Contents Preview
                        VStack(alignment: .leading, spacing: 12) {
                            Text("REPORT INCLUDES")
                                .font(AppFonts.metricLabel)
                                .foregroundColor(AppColors.textSecondary)
                            
                            ReportFeatureRow(icon: "dollarsign.circle.fill", text: "Cash flow analysis")
                            ReportFeatureRow(icon: "percent", text: "Key metrics (CoC, Cap Rate, DSCR)")
                            ReportFeatureRow(icon: "chart.line.uptrend.xyaxis", text: "5-year projections")
                            ReportFeatureRow(icon: "list.bullet.rectangle", text: "Monthly breakdown")
                        }
                        .padding()
                        .background(AppColors.cardBackground)
                        .cornerRadius(16)
                        
                        Spacer()
                    }
                    .padding()
                } else {
                    ProgressView("Generating PDF...")
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .navigationTitle("Export Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .onAppear {
                pdfData = viewModel.generatePDFReport()
            }
            .sheet(isPresented: $showingShareSheet) {
                if let pdfData = pdfData {
                    ShareSheet(items: [pdfData])
                }
            }
        }
    }
}

struct ReportFeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(AppColors.primaryTeal)
                .frame(width: 24)
            
            Text(text)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textPrimary)
        }
    }
}

/// Share sheet wrapper for UIActivityViewController
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview("Action Button") {
    HStack {
        ActionButton(icon: "slider.horizontal.3", title: "What If") {}
        ActionButton(icon: "calendar", title: "Amort.") {}
        ActionButton(icon: "note.text", title: "Notes") {}
        ActionButton(icon: "doc.fill", title: "PDF") {}
    }
    .padding()
    .background(AppColors.background)
}
