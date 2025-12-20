//
//  DealRatingView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/18.
//

import SwiftUI

/// Star rating and quick score for a deal
struct DealRatingView: View {
    @Bindable var viewModel: DealViewModel
    @Environment(\.dismiss) private var dismiss
    
    var overallScore: Int {
        var score = 0
        let results = viewModel.results
        
        // Cash flow scoring (0-25 points)
        if results.monthlyCashFlow >= 400 { score += 25 }
        else if results.monthlyCashFlow >= 200 { score += 20 }
        else if results.monthlyCashFlow >= 100 { score += 15 }
        else if results.monthlyCashFlow >= 0 { score += 10 }
        
        // CoC Return scoring (0-25 points)
        if results.cashOnCashReturn >= 15 { score += 25 }
        else if results.cashOnCashReturn >= 10 { score += 20 }
        else if results.cashOnCashReturn >= 8 { score += 15 }
        else if results.cashOnCashReturn >= 5 { score += 10 }
        
        // Cap Rate scoring (0-25 points)
        if results.capRate >= 10 { score += 25 }
        else if results.capRate >= 8 { score += 20 }
        else if results.capRate >= 6 { score += 15 }
        else if results.capRate >= 4 { score += 10 }
        
        // DSCR scoring (0-25 points)
        if results.debtServiceCoverageRatio >= 1.5 { score += 25 }
        else if results.debtServiceCoverageRatio >= 1.25 { score += 20 }
        else if results.debtServiceCoverageRatio >= 1.1 { score += 15 }
        else if results.debtServiceCoverageRatio >= 1.0 { score += 10 }
        
        return score
    }
    
    var scoreGrade: String {
        if overallScore >= 90 { return "A+" }
        if overallScore >= 85 { return "A" }
        if overallScore >= 80 { return "A-" }
        if overallScore >= 75 { return "B+" }
        if overallScore >= 70 { return "B" }
        if overallScore >= 65 { return "B-" }
        if overallScore >= 60 { return "C+" }
        if overallScore >= 55 { return "C" }
        if overallScore >= 50 { return "C-" }
        if overallScore >= 40 { return "D" }
        return "F"
    }
    
    var scoreColor: Color {
        if overallScore >= 80 { return AppColors.successGreen }
        if overallScore >= 60 { return AppColors.primaryTeal }
        if overallScore >= 40 { return AppColors.warningAmber }
        return AppColors.dangerRed
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Overall Score
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .stroke(AppColors.inputBackground, lineWidth: 12)
                                .frame(width: 150, height: 150)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(overallScore) / 100)
                                .stroke(scoreColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                                .frame(width: 150, height: 150)
                                .rotationEffect(.degrees(-90))
                            
                            VStack(spacing: 4) {
                                Text(scoreGrade)
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(scoreColor)
                                
                                Text("\(overallScore)/100")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.textMuted)
                            }
                        }
                        
                        Text("Deal Score")
                            .font(AppFonts.title2)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(30)
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Score Breakdown
                    VStack(alignment: .leading, spacing: 16) {
                        Text("SCORE BREAKDOWN")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        ScoreBreakdownRow(
                            title: "Cash Flow",
                            value: formatCurrency(viewModel.results.monthlyCashFlow) + "/mo",
                            score: cashFlowScore,
                            maxScore: 25
                        )
                        
                        ScoreBreakdownRow(
                            title: "Cash-on-Cash Return",
                            value: String(format: "%.1f%%", viewModel.results.cashOnCashReturn),
                            score: cocScore,
                            maxScore: 25
                        )
                        
                        ScoreBreakdownRow(
                            title: "Cap Rate",
                            value: String(format: "%.1f%%", viewModel.results.capRate),
                            score: capRateScore,
                            maxScore: 25
                        )
                        
                        ScoreBreakdownRow(
                            title: "Debt Service Coverage",
                            value: String(format: "%.2f", viewModel.results.debtServiceCoverageRatio),
                            score: dscrScore,
                            maxScore: 25
                        )
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Personal Rating
                    VStack(alignment: .leading, spacing: 16) {
                        Text("YOUR RATING")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        HStack(spacing: 12) {
                            ForEach(1...5, id: \.self) { star in
                                Button(action: { viewModel.deal.rating = star }) {
                                    Image(systemName: star <= viewModel.deal.rating ? "star.fill" : "star")
                                        .font(.system(size: 36))
                                        .foregroundColor(star <= viewModel.deal.rating ? AppColors.warningAmber : AppColors.textMuted)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        Text(ratingDescription)
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Verdict
                    VStack(spacing: 12) {
                        Text(dealVerdict.0)
                            .font(AppFonts.title)
                            .foregroundColor(dealVerdict.1)
                        
                        Text(dealVerdict.2)
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(20)
                    .background(dealVerdict.1.opacity(0.1))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(dealVerdict.1.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding()
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Deal Score")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AppColors.primaryTeal)
                }
            }
        }
    }
    
    // Individual scores for breakdown
    var cashFlowScore: Int {
        let cf = viewModel.results.monthlyCashFlow
        if cf >= 400 { return 25 }
        if cf >= 200 { return 20 }
        if cf >= 100 { return 15 }
        if cf >= 0 { return 10 }
        return 0
    }
    
    var cocScore: Int {
        let coc = viewModel.results.cashOnCashReturn
        if coc >= 15 { return 25 }
        if coc >= 10 { return 20 }
        if coc >= 8 { return 15 }
        if coc >= 5 { return 10 }
        return 0
    }
    
    var capRateScore: Int {
        let cap = viewModel.results.capRate
        if cap >= 10 { return 25 }
        if cap >= 8 { return 20 }
        if cap >= 6 { return 15 }
        if cap >= 4 { return 10 }
        return 0
    }
    
    var dscrScore: Int {
        let dscr = viewModel.results.debtServiceCoverageRatio
        if dscr >= 1.5 { return 25 }
        if dscr >= 1.25 { return 20 }
        if dscr >= 1.1 { return 15 }
        if dscr >= 1.0 { return 10 }
        return 0
    }
    
    var ratingDescription: String {
        switch viewModel.deal.rating {
        case 1: return "Not interested at current terms"
        case 2: return "Would consider with significant price reduction"
        case 3: return "Decent deal, worth following up"
        case 4: return "Good deal, high priority"
        case 5: return "Excellent deal, pursue immediately!"
        default: return "Tap stars to rate this deal"
        }
    }
    
    var dealVerdict: (String, Color, String) {
        if overallScore >= 80 {
            return ("🎯 Strong Buy", AppColors.successGreen, "This deal meets or exceeds benchmarks in all categories.")
        } else if overallScore >= 60 {
            return ("👍 Consider", AppColors.primaryTeal, "Solid deal with room for negotiation on price or terms.")
        } else if overallScore >= 40 {
            return ("⚠️ Proceed with Caution", AppColors.warningAmber, "Below average returns. Consider negotiating harder.")
        } else {
            return ("🚫 Pass", AppColors.dangerRed, "Numbers don't work at current terms. Look for better deals.")
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        return CurrencyFormatter.format(value, showSign: true)
    }
}

// MARK: - Score Breakdown Row

struct ScoreBreakdownRow: View {
    let title: String
    let value: String
    let score: Int
    let maxScore: Int
    
    var scoreColor: Color {
        let percent = Double(score) / Double(maxScore)
        if percent >= 0.8 { return AppColors.successGreen }
        if percent >= 0.6 { return AppColors.primaryTeal }
        if percent >= 0.4 { return AppColors.warningAmber }
        return AppColors.dangerRed
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Text(value)
                    .font(AppFonts.bodyBold)
                    .foregroundColor(AppColors.textSecondary)
                
                Text("\(score)/\(maxScore)")
                    .font(AppFonts.caption)
                    .foregroundColor(scoreColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(scoreColor.opacity(0.15))
                    .cornerRadius(6)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppColors.inputBackground)
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(scoreColor)
                        .frame(width: geometry.size.width * CGFloat(score) / CGFloat(maxScore), height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding(12)
        .background(AppColors.inputBackground.opacity(0.5))
        .cornerRadius(12)
    }
}

#Preview {
    DealRatingView(viewModel: {
        let vm = DealViewModel()
        vm.deal = .sampleDeal
        return vm
    }())
}
