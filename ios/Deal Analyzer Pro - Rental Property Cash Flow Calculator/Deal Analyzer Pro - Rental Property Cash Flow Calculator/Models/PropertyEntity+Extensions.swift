//
//  PropertyEntity+Extensions.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/18.
//

import Foundation
import CoreData

extension PropertyEntity {
    
    /// Convert Core Data entity to PropertyDeal model
    func toPropertyDeal() -> PropertyDeal {
        var deal = PropertyDeal()
        deal.id = id ?? UUID()
        deal.name = name ?? ""
        deal.address = address ?? ""
        deal.purchasePrice = purchasePrice
        deal.monthlyRent = monthlyRent
        deal.downPaymentPercent = downPaymentPercent
        deal.interestRate = interestRate
        deal.loanTermYears = Int(loanTermYears)
        deal.isCashPurchase = isCashPurchase
        deal.closingCostPercent = closingCostPercent
        deal.annualPropertyTax = annualPropertyTax
        deal.monthlyInsurance = monthlyInsurance
        deal.monthlyHOA = monthlyHOA
        deal.propertyManagementPercent = propertyManagementPercent
        deal.maintenancePercent = maintenancePercent
        deal.capExPercent = capExPercent
        deal.monthlyUtilities = monthlyUtilities
        deal.otherMonthlyExpenses = otherMonthlyExpenses
        deal.otherMonthlyIncome = otherMonthlyIncome
        deal.vacancyRatePercent = vacancyRatePercent
        deal.appreciationRatePercent = appreciationRatePercent
        deal.bedrooms = Int(bedrooms)
        deal.bathrooms = bathrooms
        deal.squareFootage = Int(squareFootage)
        deal.yearBuilt = Int(yearBuilt)
        deal.rating = Int(rating)
        deal.notes = notes ?? ""
        deal.createdAt = createdAt ?? Date()
        deal.updatedAt = updatedAt ?? Date()
        
        if let typeRaw = propertyTypeRaw,
           let type = PropertyType(rawValue: typeRaw) {
            deal.propertyType = type
        }
        
        return deal
    }
    
    /// Update entity from PropertyDeal model
    func update(from deal: PropertyDeal) {
        id = deal.id
        name = deal.name
        address = deal.address
        purchasePrice = deal.purchasePrice
        monthlyRent = deal.monthlyRent
        downPaymentPercent = deal.downPaymentPercent
        interestRate = deal.interestRate
        loanTermYears = Int16(deal.loanTermYears)
        isCashPurchase = deal.isCashPurchase
        closingCostPercent = deal.closingCostPercent
        annualPropertyTax = deal.annualPropertyTax
        monthlyInsurance = deal.monthlyInsurance
        monthlyHOA = deal.monthlyHOA
        propertyManagementPercent = deal.propertyManagementPercent
        maintenancePercent = deal.maintenancePercent
        capExPercent = deal.capExPercent
        monthlyUtilities = deal.monthlyUtilities
        otherMonthlyExpenses = deal.otherMonthlyExpenses
        otherMonthlyIncome = deal.otherMonthlyIncome
        vacancyRatePercent = deal.vacancyRatePercent
        appreciationRatePercent = deal.appreciationRatePercent
        bedrooms = Int16(deal.bedrooms)
        bathrooms = deal.bathrooms
        squareFootage = Int32(deal.squareFootage)
        yearBuilt = Int16(deal.yearBuilt)
        rating = Int16(deal.rating)
        notes = deal.notes
        propertyTypeRaw = deal.propertyType.rawValue
        updatedAt = Date()
        
        if createdAt == nil {
            createdAt = Date()
        }
    }
}
