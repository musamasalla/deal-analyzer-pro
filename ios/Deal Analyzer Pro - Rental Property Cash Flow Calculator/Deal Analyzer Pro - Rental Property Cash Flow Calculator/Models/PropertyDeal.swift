//
//  PropertyDeal.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/17.
//

import Foundation

/// Main model representing a property deal with all input parameters
struct PropertyDeal: Identifiable, Codable {
    var id = UUID()
    var name: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var isArchived: Bool = false
    
    // MARK: - Property Details
    var purchasePrice: Double = 0
    var address: String = ""
    var propertyType: PropertyType = .singleFamily
    var bedrooms: Int = 3
    var bathrooms: Double = 2.0
    var squareFootage: Int = 0
    var yearBuilt: Int = Calendar.current.component(.year, from: Date())
    
    // MARK: - Financing
    var isCashPurchase: Bool = false
    var downPaymentPercent: Double = 20.0
    var interestRate: Double = 7.5
    var loanTermYears: Int = 30
    var closingCostPercent: Double = 3.0
    
    // MARK: - Income
    var monthlyRent: Double = 0
    var otherMonthlyIncome: Double = 0
    var vacancyRatePercent: Double = 8.0
    
    // MARK: - Expenses
    var annualPropertyTax: Double = 0
    var monthlyInsurance: Double = 0
    var monthlyHOA: Double = 0
    var propertyManagementPercent: Double = 10.0
    var maintenancePercent: Double = 1.0 // % of property value annually
    var capExPercent: Double = 1.0 // % of property value annually
    var monthlyUtilities: Double = 0
    var otherMonthlyExpenses: Double = 0
    
    // MARK: - Projections
    var appreciationRatePercent: Double = 3.0
    
    // MARK: - Notes & Media
    var notes: String = ""
    var rating: Int = 0 // 1-5 stars
    var photoURLs: [String] = []
    var voiceNoteURLs: [String] = []
    
    // MARK: - Checklist
    var checklistItems: [String] = []
    var inspectionComplete: Bool = false
    var appraisalComplete: Bool = false
    var insuranceQuoteComplete: Bool = false
    var titleSearchComplete: Bool = false
    var financingApproved: Bool = false
    
    // MARK: - Computed Properties
    
    /// Down payment in dollars
    var downPaymentAmount: Double {
        purchasePrice * (downPaymentPercent / 100)
    }
    
    /// Loan amount after down payment
    var loanAmount: Double {
        isCashPurchase ? 0 : purchasePrice - downPaymentAmount
    }
    
    /// Closing costs in dollars
    var closingCosts: Double {
        purchasePrice * (closingCostPercent / 100)
    }
    
    /// Total cash needed to close the deal
    var totalCashNeeded: Double {
        isCashPurchase ? (purchasePrice + closingCosts) : (downPaymentAmount + closingCosts)
    }
    
    /// Monthly property tax
    var monthlyPropertyTax: Double {
        annualPropertyTax / 12
    }
    
    /// Monthly maintenance reserve
    var monthlyMaintenanceReserve: Double {
        (purchasePrice * (maintenancePercent / 100)) / 12
    }
    
    /// Monthly CapEx reserve
    var monthlyCapExReserve: Double {
        (purchasePrice * (capExPercent / 100)) / 12
    }
    
    /// Monthly property management fee
    var monthlyPropertyManagement: Double {
        monthlyRent * (propertyManagementPercent / 100)
    }
    
    /// Gross monthly income
    var grossMonthlyIncome: Double {
        monthlyRent + otherMonthlyIncome
    }
    
    /// Effective monthly income after vacancy
    var effectiveMonthlyIncome: Double {
        grossMonthlyIncome * (1 - vacancyRatePercent / 100)
    }
    
    /// Total monthly operating expenses (not including mortgage)
    var monthlyOperatingExpenses: Double {
        monthlyPropertyTax +
        monthlyInsurance +
        monthlyHOA +
        monthlyPropertyManagement +
        monthlyMaintenanceReserve +
        monthlyCapExReserve +
        monthlyUtilities +
        otherMonthlyExpenses
    }
    
    /// Number of doors/units
    var doorCount: Int {
        propertyType.unitCount
    }
}

// MARK: - Sample Data

extension PropertyDeal {
    static var sampleDeal: PropertyDeal {
        var deal = PropertyDeal()
        deal.name = "123 Main Street"
        deal.purchasePrice = 250000
        deal.address = "123 Main Street, Phoenix, AZ 85001"
        deal.propertyType = .singleFamily
        deal.bedrooms = 3
        deal.bathrooms = 2.0
        deal.squareFootage = 1500
        deal.yearBuilt = 1998
        deal.monthlyRent = 1800
        deal.annualPropertyTax = 2400
        deal.monthlyInsurance = 150
        deal.rating = 4
        return deal
    }
    
    static var emptyDeal: PropertyDeal {
        PropertyDeal()
    }
}
