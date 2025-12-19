//
//  CalculationService.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/17.
//

import Foundation

/// Service for all financial calculations
/// Provides real-time analysis of rental property deals
class CalculationService {
    
    // MARK: - Mortgage Calculations
    
    /// Calculate monthly Principal & Interest payment using standard amortization formula
    /// Formula: P = L[c(1 + c)^n]/[(1 + c)^n – 1]
    /// Where: L = loan amount, c = monthly interest rate, n = number of payments
    static func calculateMonthlyMortgagePayment(
        loanAmount: Double,
        annualInterestRate: Double,
        loanTermYears: Int
    ) -> Double {
        guard loanAmount > 0, annualInterestRate > 0, loanTermYears > 0 else {
            return 0
        }
        
        let monthlyRate = annualInterestRate / 100 / 12
        let numberOfPayments = Double(loanTermYears * 12)
        
        let numerator = monthlyRate * pow(1 + monthlyRate, numberOfPayments)
        let denominator = pow(1 + monthlyRate, numberOfPayments) - 1
        
        return loanAmount * (numerator / denominator)
    }
    
    /// Calculate monthly P&I for a deal
    static func monthlyMortgagePayment(for deal: PropertyDeal) -> Double {
        if deal.isCashPurchase {
            return 0
        }
        return calculateMonthlyMortgagePayment(
            loanAmount: deal.loanAmount,
            annualInterestRate: deal.interestRate,
            loanTermYears: deal.loanTermYears
        )
    }
    
    // MARK: - Cash Flow Calculations
    
    /// Calculate results for a deal
    static func calculateResults(for deal: PropertyDeal) -> CalculationResults {
        let monthlyMortgage = monthlyMortgagePayment(for: deal)
        
        // Cash Flow = Effective Income - Operating Expenses - Mortgage
        let monthlyCashFlow = deal.effectiveMonthlyIncome - deal.monthlyOperatingExpenses - monthlyMortgage
        let annualCashFlow = monthlyCashFlow * 12
        
        // NOI = Effective Income - Operating Expenses (no mortgage)
        let annualNOI = (deal.effectiveMonthlyIncome - deal.monthlyOperatingExpenses) * 12
        
        // Cash-on-Cash Return = Annual Cash Flow / Total Cash Invested × 100
        let cocReturn: Double
        if deal.totalCashNeeded > 0 {
            cocReturn = (annualCashFlow / deal.totalCashNeeded) * 100
        } else {
            cocReturn = 0
        }
        
        // Cap Rate = NOI / Purchase Price × 100
        let capRate: Double
        if deal.purchasePrice > 0 {
            capRate = (annualNOI / deal.purchasePrice) * 100
        } else {
            capRate = 0
        }
        
        // Gross Rent Multiplier = Purchase Price / Annual Gross Rent
        let grm: Double
        let annualGrossRent = deal.grossMonthlyIncome * 12
        if annualGrossRent > 0 {
            grm = deal.purchasePrice / annualGrossRent
        } else {
            grm = 0
        }
        
        // Debt Service Coverage Ratio = NOI / Annual Debt Service
        let annualDebtService = monthlyMortgage * 12
        let dscr: Double
        if annualDebtService > 0 {
            dscr = annualNOI / annualDebtService
        } else {
            dscr = deal.isCashPurchase ? Double.infinity : 0
        }
        
        // Expense Ratio = Total Operating Expenses / Gross Rent × 100
        let expenseRatio: Double
        if deal.grossMonthlyIncome > 0 {
            expenseRatio = (deal.monthlyOperatingExpenses / deal.grossMonthlyIncome) * 100
        } else {
            expenseRatio = 0
        }
        
        // Break-even Rent = (Operating Expenses + Mortgage) / (1 - Vacancy Rate)
        let breakEvenRent: Double
        let totalMonthlyObligations = deal.monthlyOperatingExpenses + monthlyMortgage
        if deal.vacancyRatePercent < 100 {
            breakEvenRent = totalMonthlyObligations / (1 - deal.vacancyRatePercent / 100)
        } else {
            breakEvenRent = 0
        }
        
        // Cash flow per door
        let cashFlowPerDoor = monthlyCashFlow / Double(deal.doorCount)
        
        // Calculate 5-year projection
        let fiveYearProjection = calculate5YearProjection(for: deal, monthlyMortgage: monthlyMortgage)
        
        return CalculationResults(
            monthlyMortgagePayment: monthlyMortgage,
            monthlyCashFlow: monthlyCashFlow,
            annualCashFlow: annualCashFlow,
            cashFlowPerDoor: cashFlowPerDoor,
            netOperatingIncome: annualNOI,
            cashOnCashReturn: cocReturn,
            capRate: capRate,
            grossRentMultiplier: grm,
            debtServiceCoverageRatio: dscr,
            expenseRatio: expenseRatio,
            breakEvenRent: breakEvenRent,
            totalCashNeeded: deal.totalCashNeeded,
            fiveYearProjection: fiveYearProjection
        )
    }
    
    // MARK: - 5-Year Projection
    
    static func calculate5YearProjection(
        for deal: PropertyDeal,
        monthlyMortgage: Double
    ) -> FiveYearProjection {
        var totalCashFlow: Double = 0
        var totalEquityBuildup: Double = 0
        var propertyValue = deal.purchasePrice
        var loanBalance = deal.loanAmount
        
        let monthlyRate = deal.interestRate / 100 / 12
        
        for year in 1...5 {
            // Cash flow for this year (assuming rent grows with appreciation)
            let rentGrowthFactor = pow(1 + deal.appreciationRatePercent / 100, Double(year - 1))
            let adjustedMonthlyRent = deal.monthlyRent * rentGrowthFactor
            let adjustedGrossIncome = (adjustedMonthlyRent + deal.otherMonthlyIncome)
            let adjustedEffectiveIncome = adjustedGrossIncome * (1 - deal.vacancyRatePercent / 100)
            let adjustedMonthlyManagement = adjustedMonthlyRent * (deal.propertyManagementPercent / 100)
            
            // Adjust expenses that are based on rent
            let adjustedOperatingExpenses = deal.monthlyPropertyTax +
                deal.monthlyInsurance +
                deal.monthlyHOA +
                adjustedMonthlyManagement +
                deal.monthlyMaintenanceReserve +
                deal.monthlyCapExReserve +
                deal.monthlyUtilities +
                deal.otherMonthlyExpenses
            
            let yearlyMonthlyCashFlow = adjustedEffectiveIncome - adjustedOperatingExpenses - monthlyMortgage
            totalCashFlow += yearlyMonthlyCashFlow * 12
            
            // Equity buildup from loan paydown
            if !deal.isCashPurchase && loanBalance > 0 {
                for _ in 1...12 {
                    let interestPayment = loanBalance * monthlyRate
                    let principalPayment = monthlyMortgage - interestPayment
                    loanBalance -= principalPayment
                    totalEquityBuildup += principalPayment
                }
            }
            
            // Property appreciation
            propertyValue *= (1 + deal.appreciationRatePercent / 100)
        }
        
        let totalAppreciation = propertyValue - deal.purchasePrice
        let totalReturn = totalCashFlow + totalEquityBuildup + totalAppreciation
        let roi: Double
        if deal.totalCashNeeded > 0 {
            roi = (totalReturn / deal.totalCashNeeded) * 100
        } else {
            roi = 0
        }
        
        return FiveYearProjection(
            totalCashFlow: totalCashFlow,
            totalEquityBuildup: totalEquityBuildup,
            totalAppreciation: totalAppreciation,
            projectedPropertyValue: propertyValue,
            remainingLoanBalance: max(0, loanBalance),
            totalReturn: totalReturn,
            returnOnInvestment: roi
        )
    }
    
    // MARK: - Amortization Schedule
    
    static func generateAmortizationSchedule(for deal: PropertyDeal) -> [AmortizationEntry] {
        guard !deal.isCashPurchase, deal.loanAmount > 0 else {
            return []
        }
        
        let monthlyPayment = monthlyMortgagePayment(for: deal)
        let monthlyRate = deal.interestRate / 100 / 12
        var balance = deal.loanAmount
        var schedule: [AmortizationEntry] = []
        
        for month in 1...(deal.loanTermYears * 12) {
            let interestPayment = balance * monthlyRate
            let principalPayment = monthlyPayment - interestPayment
            balance -= principalPayment
            
            // Only add yearly entries to keep it manageable
            if month % 12 == 0 {
                schedule.append(AmortizationEntry(
                    year: month / 12,
                    monthlyPayment: monthlyPayment,
                    principalPayment: principalPayment,
                    interestPayment: interestPayment,
                    remainingBalance: max(0, balance),
                    totalPrincipalPaid: deal.loanAmount - max(0, balance),
                    totalInterestPaid: (monthlyPayment * Double(month)) - (deal.loanAmount - max(0, balance))
                ))
            }
        }
        
        return schedule
    }
    
    // MARK: - Validation & Warnings
    
    static func getWarnings(for deal: PropertyDeal, results: CalculationResults) -> [DealWarning] {
        var warnings: [DealWarning] = []
        
        // Negative cash flow
        if results.monthlyCashFlow < 0 {
            warnings.append(DealWarning(
                type: .critical,
                title: "Negative Cash Flow",
                message: "This property loses $\(formatCurrency(abs(results.monthlyCashFlow)))/month after all expenses."
            ))
        }
        
        // Low CoC return
        if results.cashOnCashReturn < 5 && results.cashOnCashReturn > 0 {
            warnings.append(DealWarning(
                type: .warning,
                title: "Low Cash-on-Cash Return",
                message: "CoC return of \(String(format: "%.1f", results.cashOnCashReturn))% is below the 8% target."
            ))
        }
        
        // High expense ratio
        if results.expenseRatio > 50 {
            warnings.append(DealWarning(
                type: .warning,
                title: "High Expense Ratio",
                message: "Operating expenses consume \(String(format: "%.0f", results.expenseRatio))% of gross rent."
            ))
        }
        
        // Rent seems unrealistic (1% rule check)
        let onePercentRent = deal.purchasePrice * 0.01
        if deal.monthlyRent > 0 && deal.monthlyRent < onePercentRent * 0.5 {
            warnings.append(DealWarning(
                type: .info,
                title: "Rent May Be Low",
                message: "Rent is significantly below the 1% rule. Consider verifying market rents."
            ))
        }
        
        // DSCR below 1
        if results.debtServiceCoverageRatio < 1 && !deal.isCashPurchase {
            warnings.append(DealWarning(
                type: .critical,
                title: "DSCR Below 1.0",
                message: "Income doesn't cover debt service. Banks typically require 1.25+ DSCR."
            ))
        }
        
        // Cash flow per door below $200
        if results.cashFlowPerDoor < 200 && results.cashFlowPerDoor > 0 {
            warnings.append(DealWarning(
                type: .info,
                title: "Low Cash Flow Per Door",
                message: "$\(String(format: "%.0f", results.cashFlowPerDoor))/door is below the $200/door target."
            ))
        }
        
        return warnings
    }
    
    // MARK: - Helpers
    
    private static func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
}

// MARK: - Result Models

struct CalculationResults {
    let monthlyMortgagePayment: Double
    let monthlyCashFlow: Double
    let annualCashFlow: Double
    let cashFlowPerDoor: Double
    let netOperatingIncome: Double
    let cashOnCashReturn: Double
    let capRate: Double
    let grossRentMultiplier: Double
    let debtServiceCoverageRatio: Double
    let expenseRatio: Double
    let breakEvenRent: Double
    let totalCashNeeded: Double
    let fiveYearProjection: FiveYearProjection
    
    static var empty: CalculationResults {
        CalculationResults(
            monthlyMortgagePayment: 0,
            monthlyCashFlow: 0,
            annualCashFlow: 0,
            cashFlowPerDoor: 0,
            netOperatingIncome: 0,
            cashOnCashReturn: 0,
            capRate: 0,
            grossRentMultiplier: 0,
            debtServiceCoverageRatio: 0,
            expenseRatio: 0,
            breakEvenRent: 0,
            totalCashNeeded: 0,
            fiveYearProjection: .empty
        )
    }
}

struct FiveYearProjection {
    let totalCashFlow: Double
    let totalEquityBuildup: Double
    let totalAppreciation: Double
    let projectedPropertyValue: Double
    let remainingLoanBalance: Double
    let totalReturn: Double
    let returnOnInvestment: Double
    
    static var empty: FiveYearProjection {
        FiveYearProjection(
            totalCashFlow: 0,
            totalEquityBuildup: 0,
            totalAppreciation: 0,
            projectedPropertyValue: 0,
            remainingLoanBalance: 0,
            totalReturn: 0,
            returnOnInvestment: 0
        )
    }
}

struct AmortizationEntry: Identifiable {
    let id = UUID()
    let year: Int
    let monthlyPayment: Double
    let principalPayment: Double
    let interestPayment: Double
    let remainingBalance: Double
    let totalPrincipalPaid: Double
    let totalInterestPaid: Double
}

struct DealWarning: Identifiable {
    let id = UUID()
    let type: WarningType
    let title: String
    let message: String
    
    enum WarningType {
        case info
        case warning
        case critical
        
        var iconName: String {
            switch self {
            case .info: return "info.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .critical: return "xmark.octagon.fill"
            }
        }
    }
}
