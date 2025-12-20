import Foundation
import Supabase
import CoreData

/// Service to synchronize data between Core Data and Supabase
class CloudSyncService {
    static let shared = CloudSyncService()
    
    private let supabase = SupabaseService.shared.client
    private let auth = AuthService.shared
    
    private init() {}
    
    /// Sync a single property deal to Supabase
    func syncProperty(_ deal: PropertyDeal) async throws {
        guard let userId = auth.currentUser?.id else { return }
        
        let record = PropertyRecord(from: deal, userId: userId)
        
        try await supabase.database
            .from("properties")
            .upsert(record)
            .execute()
    }
    
    /// Pull all properties from Supabase and sync to local Core Data
    func pullInitialData(dataService: DealDataService) async throws {
        guard let userId = auth.currentUser?.id else { return }
        
        let records: [PropertyRecord] = try await supabase.database
            .from("properties")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
        
        // Convert and save to local
        for record in records {
            let deal = record.toPropertyDeal()
            dataService.saveDeal(deal)
        }
    }
    
    /// Delete a property deal from Supabase
    func deleteProperty(_ deal: PropertyDeal) async throws {
        guard auth.isAuthenticated else { return }
        
        try await supabase.database
            .from("properties")
            .delete()
            .eq("id", value: deal.id.uuidString)
            .execute()
    }
}

// MARK: - Supabase Records

struct PropertyRecord: Codable {
    let id: UUID
    let user_id: UUID
    let name: String?
    let address: String?
    let purchase_price: Double
    let monthly_rent: Double
    let down_payment_percent: Double
    let interest_rate: Double
    let loan_term_years: Int
    let annual_property_tax: Double
    let monthly_insurance: Double
    let monthly_hoa: Double
    let monthly_utilities: Double
    let maintenance_percent: Double
    let cap_ex_percent: Double
    let property_management_percent: Double
    let vacancy_rate_percent: Double
    let appreciation_rate_percent: Double
    let closing_cost_percent: Double
    let other_monthly_expenses: Double
    let other_monthly_income: Double
    let bedrooms: Int
    let bathrooms: Double
    let square_footage: Int
    let year_built: Int
    let property_type_raw: String
    let is_archived: Bool
    let is_cash_purchase: Bool
    let rating: Int
    let notes: String?
    let created_at: Date
    let updated_at: Date
    
    init(from deal: PropertyDeal, userId: UUID) {
        self.id = deal.id
        self.user_id = userId
        self.name = deal.name
        self.address = deal.address
        self.purchase_price = deal.purchasePrice
        self.monthly_rent = deal.monthlyRent
        self.down_payment_percent = deal.downPaymentPercent
        self.interest_rate = deal.interestRate
        self.loan_term_years = deal.loanTermYears
        self.annual_property_tax = deal.annualPropertyTax
        self.monthly_insurance = deal.monthlyInsurance
        self.monthly_hoa = deal.monthlyHOA
        self.monthly_utilities = deal.monthlyUtilities
        self.maintenance_percent = deal.maintenancePercent
        self.cap_ex_percent = deal.capExPercent
        self.property_management_percent = deal.propertyManagementPercent
        self.vacancy_rate_percent = deal.vacancyRatePercent
        self.appreciation_rate_percent = deal.appreciationRatePercent
        self.closing_cost_percent = deal.closingCostPercent
        self.other_monthly_expenses = deal.otherMonthlyExpenses
        self.other_monthly_income = deal.otherMonthlyIncome
        self.bedrooms = deal.bedrooms
        self.bathrooms = deal.bathrooms
        self.square_footage = deal.squareFootage
        self.year_built = deal.yearBuilt
        self.property_type_raw = deal.propertyType.rawValue
        self.is_archived = deal.isArchived
        self.is_cash_purchase = deal.isCashPurchase
        self.rating = deal.rating
        self.notes = deal.notes
        self.created_at = deal.createdAt
        self.updated_at = deal.updatedAt
    }
    
    func toPropertyDeal() -> PropertyDeal {
        PropertyDeal(
            id: id,
            name: name ?? "",
            createdAt: created_at,
            updatedAt: updated_at,
            purchasePrice: purchase_price,
            address: address ?? "",
            propertyType: PropertyType(rawValue: property_type_raw) ?? .singleFamily,
            bedrooms: bedrooms,
            bathrooms: bathrooms,
            squareFootage: square_footage,
            yearBuilt: year_built,
            isCashPurchase: is_cash_purchase,
            downPaymentPercent: down_payment_percent,
            interestRate: interest_rate,
            loanTermYears: loan_term_years,
            closingCostPercent: closing_cost_percent,
            monthlyRent: monthly_rent,
            otherMonthlyIncome: other_monthly_income,
            vacancyRatePercent: vacancy_rate_percent,
            annualPropertyTax: annual_property_tax,
            monthlyInsurance: monthly_insurance,
            monthlyHOA: monthly_hoa,
            propertyManagementPercent: property_management_percent,
            maintenancePercent: maintenance_percent,
            capExPercent: cap_ex_percent,
            monthlyUtilities: monthly_utilities,
            otherMonthlyExpenses: other_monthly_expenses,
            appreciationRatePercent: appreciation_rate_percent,
            notes: notes ?? "",
            rating: rating
        )
    }
}
