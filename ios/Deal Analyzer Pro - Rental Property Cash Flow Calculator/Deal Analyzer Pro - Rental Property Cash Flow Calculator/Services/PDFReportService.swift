//
//  PDFReportService.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/18.
//

import SwiftUI
import PDFKit

/// Service for generating PDF deal reports
class PDFReportService {
    
    static func generateReport(for deal: PropertyDeal) -> Data? {
        let results = CalculationService.calculateResults(for: deal)
        
        let pdfMetaData = [
            kCGPDFContextCreator: "Deal Analyzer Pro",
            kCGPDFContextAuthor: "Deal Analyzer Pro",
            kCGPDFContextTitle: deal.name.isEmpty ? "Property Analysis" : deal.name
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth: CGFloat = 612 // US Letter
        let pageHeight: CGFloat = 792
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let margin: CGFloat = 50
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            var yPosition: CGFloat = margin
            
            // Title
            let titleFont = UIFont.systemFont(ofSize: 24, weight: .bold)
            let title = deal.name.isEmpty ? "Property Analysis Report" : deal.name
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: UIColor.black
            ]
            title.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: titleAttributes)
            yPosition += 40
            
            // Subtitle (address)
            if !deal.address.isEmpty {
                let subtitleFont = UIFont.systemFont(ofSize: 14, weight: .regular)
                let subtitleAttributes: [NSAttributedString.Key: Any] = [
                    .font: subtitleFont,
                    .foregroundColor: UIColor.darkGray
                ]
                deal.address.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: subtitleAttributes)
                yPosition += 30
            }
            
            // Date
            let dateFont = UIFont.systemFont(ofSize: 12, weight: .regular)
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            let dateString = "Generated: \(dateFormatter.string(from: Date()))"
            let dateAttributes: [NSAttributedString.Key: Any] = [
                .font: dateFont,
                .foregroundColor: UIColor.gray
            ]
            dateString.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: dateAttributes)
            yPosition += 40
            
            // Divider
            let dividerPath = UIBezierPath()
            dividerPath.move(to: CGPoint(x: margin, y: yPosition))
            dividerPath.addLine(to: CGPoint(x: pageWidth - margin, y: yPosition))
            UIColor.lightGray.setStroke()
            dividerPath.stroke()
            yPosition += 20
            
            // Cash Flow Highlight
            let cashFlowFont = UIFont.systemFont(ofSize: 28, weight: .bold)
            let cashFlowColor = results.monthlyCashFlow >= 0 ? UIColor.systemGreen : UIColor.systemRed
            let prefix = results.monthlyCashFlow >= 0 ? "+" : ""
            let cashFlowText = "\(prefix)\(formatCurrency(results.monthlyCashFlow))/month"
            let cashFlowAttributes: [NSAttributedString.Key: Any] = [
                .font: cashFlowFont,
                .foregroundColor: cashFlowColor
            ]
            cashFlowText.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: cashFlowAttributes)
            yPosition += 35
            
            let cashFlowLabel = "Monthly Cash Flow (after all expenses)"
            let labelFont = UIFont.systemFont(ofSize: 12, weight: .regular)
            let labelAttributes: [NSAttributedString.Key: Any] = [
                .font: labelFont,
                .foregroundColor: UIColor.gray
            ]
            cashFlowLabel.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: labelAttributes)
            yPosition += 40
            
            // Key Metrics Section
            let sectionFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
            let sectionAttributes: [NSAttributedString.Key: Any] = [
                .font: sectionFont,
                .foregroundColor: UIColor.black
            ]
            "KEY METRICS".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: sectionAttributes)
            yPosition += 25
            
            let metricsFont = UIFont.systemFont(ofSize: 14, weight: .regular)
            let metricsAttributes: [NSAttributedString.Key: Any] = [
                .font: metricsFont,
                .foregroundColor: UIColor.black
            ]
            
            let metrics = [
                ("Cash-on-Cash Return", String(format: "%.1f%%", results.cashOnCashReturn)),
                ("Cap Rate", String(format: "%.1f%%", results.capRate)),
                ("Gross Rent Multiplier", String(format: "%.1f", results.grossRentMultiplier)),
                ("Debt Service Coverage", String(format: "%.2f", results.debtServiceCoverageRatio)),
                ("Monthly NOI", formatCurrency(results.netOperatingIncome / 12)),
                ("Break-Even Rent", formatCurrency(results.breakEvenRent))
            ]
            
            for (label, value) in metrics {
                let metricText = "\(label): \(value)"
                metricText.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: metricsAttributes)
                yPosition += 22
            }
            yPosition += 20
            
            // Purchase Summary Section
            "PURCHASE SUMMARY".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: sectionAttributes)
            yPosition += 25
            
            let purchaseDetails = [
                ("Purchase Price", formatCurrency(deal.purchasePrice)),
                ("Down Payment (\(Int(deal.downPaymentPercent))%)", formatCurrency(deal.downPaymentAmount)),
                ("Loan Amount", formatCurrency(deal.loanAmount)),
                ("Monthly P&I", formatCurrency(results.monthlyMortgagePayment)),
                ("Total Cash Needed", formatCurrency(results.totalCashNeeded))
            ]
            
            for (label, value) in purchaseDetails {
                let text = "\(label): \(value)"
                text.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: metricsAttributes)
                yPosition += 22
            }
            yPosition += 20
            
            // Monthly Income/Expenses
            "MONTHLY BREAKDOWN".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: sectionAttributes)
            yPosition += 25
            
            let incomeExpenses = [
                ("Gross Rent", formatCurrency(deal.grossMonthlyIncome)),
                ("Vacancy (\(Int(deal.vacancyRatePercent))%)", "-\(formatCurrency(deal.grossMonthlyIncome - deal.effectiveMonthlyIncome))"),
                ("Operating Expenses", "-\(formatCurrency(deal.monthlyOperatingExpenses))"),
                ("Mortgage (P&I)", "-\(formatCurrency(results.monthlyMortgagePayment))"),
                ("Net Cash Flow", "\(results.monthlyCashFlow >= 0 ? "+" : "")\(formatCurrency(results.monthlyCashFlow))")
            ]
            
            for (label, value) in incomeExpenses {
                let text = "\(label): \(value)"
                text.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: metricsAttributes)
                yPosition += 22
            }
            yPosition += 20
            
            // 5-Year Projection
            "5-YEAR PROJECTION".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: sectionAttributes)
            yPosition += 25
            
            let projection = results.fiveYearProjection
            let projectionDetails = [
                ("Total Cash Flow", formatCurrency(projection.totalCashFlow)),
                ("Equity Buildup", formatCurrency(projection.totalEquityBuildup)),
                ("Appreciation (at \(String(format: "%.1f", deal.appreciationRatePercent))%)", formatCurrency(projection.totalAppreciation)),
                ("Total Return", formatCurrency(projection.totalReturn)),
                ("ROI", String(format: "%.1f%%", projection.returnOnInvestment))
            ]
            
            for (label, value) in projectionDetails {
                let text = "\(label): \(value)"
                text.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: metricsAttributes)
                yPosition += 22
            }
            
            // Footer
            let footerY = pageHeight - margin - 20
            let footerFont = UIFont.systemFont(ofSize: 10, weight: .regular)
            let footerAttributes: [NSAttributedString.Key: Any] = [
                .font: footerFont,
                .foregroundColor: UIColor.gray
            ]
            let footer = "Generated by Deal Analyzer Pro • For informational purposes only"
            footer.draw(at: CGPoint(x: margin, y: footerY), withAttributes: footerAttributes)
        }
        
        return data
    }
    
    private static func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}
