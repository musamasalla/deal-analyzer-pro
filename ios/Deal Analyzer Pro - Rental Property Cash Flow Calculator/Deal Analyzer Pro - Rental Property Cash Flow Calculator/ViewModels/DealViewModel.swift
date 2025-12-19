//
//  DealViewModel.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/17.
//

import Foundation
import SwiftUI

/// Main view model for deal analysis
/// Provides live calculations as user types
@Observable
class DealViewModel {
    // MARK: - Services
    private let dataService = DealDataService()
    
    // MARK: - Deal Data
    var deal: PropertyDeal = PropertyDeal()
    
    // MARK: - Calculated Results (auto-updated)
    var results: CalculationResults {
        CalculationService.calculateResults(for: deal)
    }
    
    // MARK: - Warnings
    var warnings: [DealWarning] {
        CalculationService.getWarnings(for: deal, results: results)
    }
    
    // MARK: - UI State
    var isQuickEntryMode: Bool = false
    var showingAdvancedExpenses: Bool = false
    var isAgentMode: Bool = false
    var showingScenarioTesting: Bool = false
    var showingAmortization: Bool = false
    var showingNotes: Bool = false
    var showingPDFPreview: Bool = false
    var showingToolsMenu: Bool = false
    
    // MARK: - Saved Deals
    var savedDeals: [PropertyDeal] = []
    
    // MARK: - Scenario Testing
    var isScenarioMode: Bool = false
    var scenarioDeal: PropertyDeal?
    
    // MARK: - Comparison
    var selectedDealsForComparison: Set<UUID> = []
    
    init() {
        loadSavedDeals()
    }
    
    // MARK: - Quick Entry Properties
    
    /// Quick entry for only essential fields
    func setupQuickEntry(
        purchasePrice: Double,
        monthlyRent: Double,
        downPaymentPercent: Double,
        interestRate: Double,
        annualPropertyTax: Double,
        monthlyInsurance: Double
    ) {
        deal.purchasePrice = purchasePrice
        deal.monthlyRent = monthlyRent
        deal.downPaymentPercent = downPaymentPercent
        deal.interestRate = interestRate
        deal.annualPropertyTax = annualPropertyTax
        deal.monthlyInsurance = monthlyInsurance
    }
    
    // MARK: - Persistence Actions
    
    func loadSavedDeals() {
        savedDeals = dataService.fetchAllDeals()
    }
    
    func resetDeal() {
        deal = PropertyDeal()
    }
    
    func saveDeal(name: String) {
        deal.name = name
        deal.updatedAt = Date()
        if deal.createdAt.timeIntervalSince1970 < 1 {
            deal.createdAt = Date()
        }
        dataService.saveDeal(deal)
        loadSavedDeals()
    }
    
    func loadDeal(_ loadedDeal: PropertyDeal) {
        deal = loadedDeal
    }
    
    func deleteDeal(_ dealToDelete: PropertyDeal) {
        dataService.deleteDeal(dealToDelete)
        loadSavedDeals()
    }
    
    func archiveDeal(_ dealToArchive: PropertyDeal) {
        dataService.archiveDeal(dealToArchive)
        loadSavedDeals()
    }
    
    // MARK: - Scenario Testing
    
    func startScenario() {
        scenarioDeal = deal
        isScenarioMode = true
    }
    
    func cancelScenario() {
        if let original = scenarioDeal {
            deal = original
        }
        scenarioDeal = nil
        isScenarioMode = false
    }
    
    func applyScenario() {
        scenarioDeal = nil
        isScenarioMode = false
    }
    
    // MARK: - PDF Export
    
    func generatePDFReport() -> Data? {
        PDFReportService.generateReport(for: deal)
    }
    
    // MARK: - Templates
    
    func applyTemplate(_ template: ExpenseTemplate) {
        deal.propertyManagementPercent = template.propertyManagementPercent
        deal.maintenancePercent = template.maintenancePercent
        deal.capExPercent = template.capExPercent
        deal.vacancyRatePercent = template.vacancyRatePercent
    }
    
    // MARK: - Use Last Deal Values
    
    func useLastRent() {
        if let lastDeal = savedDeals.first {
            deal.monthlyRent = lastDeal.monthlyRent
        }
    }
    
    func useLastExpenses() {
        if let lastDeal = savedDeals.first {
            deal.annualPropertyTax = lastDeal.annualPropertyTax
            deal.monthlyInsurance = lastDeal.monthlyInsurance
            deal.monthlyHOA = lastDeal.monthlyHOA
            deal.propertyManagementPercent = lastDeal.propertyManagementPercent
            deal.maintenancePercent = lastDeal.maintenancePercent
            deal.capExPercent = lastDeal.capExPercent
        }
    }
    
    // MARK: - Comparison
    
    func toggleComparisonSelection(_ dealId: UUID) {
        if selectedDealsForComparison.contains(dealId) {
            selectedDealsForComparison.remove(dealId)
        } else if selectedDealsForComparison.count < 3 {
            selectedDealsForComparison.insert(dealId)
        }
    }
    
    func clearComparisonSelection() {
        selectedDealsForComparison.removeAll()
    }
    
    var dealsForComparison: [PropertyDeal] {
        savedDeals.filter { selectedDealsForComparison.contains($0.id) }
    }
}

// MARK: - Expense Templates

struct ExpenseTemplate: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let propertyManagementPercent: Double
    let maintenancePercent: Double
    let capExPercent: Double
    let vacancyRatePercent: Double
    
    static let templates: [ExpenseTemplate] = [
        ExpenseTemplate(
            name: "Conservative",
            description: "Higher reserves, self-managed",
            propertyManagementPercent: 0,
            maintenancePercent: 1.5,
            capExPercent: 1.5,
            vacancyRatePercent: 10
        ),
        ExpenseTemplate(
            name: "Typical SFH",
            description: "Standard single-family assumptions",
            propertyManagementPercent: 10,
            maintenancePercent: 1,
            capExPercent: 1,
            vacancyRatePercent: 8
        ),
        ExpenseTemplate(
            name: "Turnkey Rental",
            description: "Fully managed, newer property",
            propertyManagementPercent: 10,
            maintenancePercent: 0.5,
            capExPercent: 0.5,
            vacancyRatePercent: 5
        ),
        ExpenseTemplate(
            name: "Multi-Family",
            description: "Multiple units, higher occupancy",
            propertyManagementPercent: 8,
            maintenancePercent: 1,
            capExPercent: 1,
            vacancyRatePercent: 6
        )
    ]
}

// MARK: - Sorting Options

enum DealSortOption: String, CaseIterable {
    case dateNewest = "Newest First"
    case dateOldest = "Oldest First"
    case cashFlowHighest = "Highest Cash Flow"
    case cashFlowLowest = "Lowest Cash Flow"
    case cocReturnHighest = "Highest CoC Return"
    case capRateHighest = "Highest Cap Rate"
    case priceLowest = "Lowest Price"
    case priceHighest = "Highest Price"
}
