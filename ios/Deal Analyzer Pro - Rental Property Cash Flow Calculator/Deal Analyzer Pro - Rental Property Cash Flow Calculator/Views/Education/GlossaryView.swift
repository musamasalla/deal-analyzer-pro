//
//  GlossaryView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/17.
//

import SwiftUI

/// Educational glossary of real estate investment terms
struct GlossaryView: View {
    @State private var searchText: String = ""
    
    var filteredTerms: [GlossaryTerm] {
        if searchText.isEmpty {
            return GlossaryTerm.allTerms
        } else {
            return GlossaryTerm.allTerms.filter {
                $0.term.localizedCaseInsensitiveContains(searchText) ||
                $0.definition.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredTerms) { term in
                        GlossaryTermCard(term: term)
                    }
                }
                .padding()
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Glossary")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search terms")
        }
    }
}

// MARK: - Glossary Term Card

struct GlossaryTermCard: View {
    let term: GlossaryTerm
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    Text(term.term)
                        .font(AppFonts.bodyBold)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Text(term.definition)
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textSecondary)
                    
                    if let formula = term.formula {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("FORMULA")
                                .font(AppFonts.caption2)
                                .foregroundColor(AppColors.textMuted)
                            
                            Text(formula)
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(AppColors.textAccent)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(AppColors.inputBackground)
                                .cornerRadius(8)
                        }
                    }
                    
                    if let example = term.example {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("EXAMPLE")
                                .font(AppFonts.caption2)
                                .foregroundColor(AppColors.textMuted)
                            
                            Text(example)
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.textSecondary)
                                .italic()
                        }
                    }
                    
                    if let benchmark = term.benchmark {
                        HStack(spacing: 8) {
                            Image(systemName: "target")
                                .foregroundColor(AppColors.successGreen)
                            
                            Text(benchmark)
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.successGreen)
                        }
                        .padding(10)
                        .background(AppColors.successGreen.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
}

// MARK: - Glossary Term Model

struct GlossaryTerm: Identifiable {
    let id = UUID()
    let term: String
    let definition: String
    let formula: String?
    let example: String?
    let benchmark: String?
    
    static let allTerms: [GlossaryTerm] = [
        GlossaryTerm(
            term: "Cash Flow",
            definition: "The money left over each month after collecting rent and paying all expenses including your mortgage. This is your actual profit from the rental property.",
            formula: "Cash Flow = Rent - Vacancy - Operating Expenses - Mortgage Payment",
            example: "If you collect $1,800 rent and have $1,400 in total expenses, your cash flow is $400/month.",
            benchmark: "Target: $200+ per door (unit) per month"
        ),
        GlossaryTerm(
            term: "Cash-on-Cash Return (CoC)",
            definition: "The annual return on the actual cash you invested. This tells you how hard your money is working for you compared to other investments.",
            formula: "CoC = (Annual Cash Flow ÷ Total Cash Invested) × 100",
            example: "If you invested $50,000 and make $4,000/year in cash flow, your CoC is 8%.",
            benchmark: "8%+ is good, 12%+ is excellent"
        ),
        GlossaryTerm(
            term: "Cap Rate (Capitalization Rate)",
            definition: "The rate of return on a property based on the income it generates, assuming you paid all cash. Useful for comparing properties regardless of financing.",
            formula: "Cap Rate = (Net Operating Income ÷ Purchase Price) × 100",
            example: "A $200,000 property with $16,000 NOI has an 8% cap rate.",
            benchmark: "8%+ is decent (varies by market)"
        ),
        GlossaryTerm(
            term: "Net Operating Income (NOI)",
            definition: "Your rental income minus all operating expenses, but NOT including mortgage payments. This shows how profitable the property is operationally.",
            formula: "NOI = Gross Income - Operating Expenses",
            example: "If you collect $21,600/year and have $8,000 in operating expenses, your NOI is $13,600.",
            benchmark: nil
        ),
        GlossaryTerm(
            term: "Gross Rent Multiplier (GRM)",
            definition: "A quick way to estimate property value based on rent. Lower is generally better as it means you're paying less per dollar of rent.",
            formula: "GRM = Purchase Price ÷ Annual Gross Rent",
            example: "A $200,000 property with $20,000 annual rent has a GRM of 10.",
            benchmark: "Lower GRM = better value (typically 8-12)"
        ),
        GlossaryTerm(
            term: "Debt Service Coverage Ratio (DSCR)",
            definition: "How many times your NOI covers your annual mortgage payments. Banks use this to determine if you can afford the loan.",
            formula: "DSCR = NOI ÷ Annual Debt Service",
            example: "If your NOI is $15,000 and mortgage is $12,000/year, DSCR is 1.25.",
            benchmark: "Banks typically require 1.25+ DSCR"
        ),
        GlossaryTerm(
            term: "Vacancy Rate",
            definition: "The percentage of time you expect the property to be vacant between tenants. This accounts for turnover and the time to find new renters.",
            formula: "Vacancy Loss = Monthly Rent × Vacancy Rate %",
            example: "At 8% vacancy, expect about 1 month vacant per year.",
            benchmark: "5-10% is typical (varies by market)"
        ),
        GlossaryTerm(
            term: "1% Rule",
            definition: "A quick screening rule suggesting monthly rent should be at least 1% of the purchase price for a property to potentially cash flow.",
            formula: "Monthly Rent ≥ Purchase Price × 1%",
            example: "A $200,000 property should rent for at least $2,000/month.",
            benchmark: "Passing 1% = worth analyzing further"
        ),
        GlossaryTerm(
            term: "CapEx Reserve",
            definition: "Money set aside for big-ticket repairs and replacements like roof, HVAC, water heater, appliances. These are expensive but infrequent costs.",
            formula: "Typically 1% of property value per year ÷ 12",
            example: "For a $200,000 home, budget about $167/month for CapEx.",
            benchmark: nil
        ),
        GlossaryTerm(
            term: "Down Payment",
            definition: "The upfront cash you pay toward the purchase price. The remainder is financed with a mortgage loan.",
            formula: "Down Payment = Purchase Price × Down Payment %",
            example: "20% down on a $250,000 home is $50,000.",
            benchmark: "Investment properties typically require 20-25% down"
        )
    ]
}

#Preview {
    GlossaryView()
}
