//
//  PersistenceController.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/18.
//

import CoreData

/// Core Data stack for persistent storage
struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        
        // Create sample data for previews
        let viewContext = controller.container.viewContext
        
        let sampleDeal = PropertyEntity(context: viewContext)
        sampleDeal.id = UUID()
        sampleDeal.name = "123 Sample Street"
        sampleDeal.address = "123 Sample Street, Phoenix, AZ"
        sampleDeal.purchasePrice = 250000
        sampleDeal.monthlyRent = 1800
        sampleDeal.downPaymentPercent = 20
        sampleDeal.interestRate = 7.5
        sampleDeal.loanTermYears = 30
        sampleDeal.annualPropertyTax = 2400
        sampleDeal.monthlyInsurance = 150
        sampleDeal.createdAt = Date()
        sampleDeal.updatedAt = Date()
        
        do {
            try viewContext.save()
        } catch {
            fatalError("Preview save failed: \(error)")
        }
        
        return controller
    }()
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "DealAnalyzerPro")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // In production, handle this gracefully
                fatalError("Core Data load failed: \(error)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // MARK: - Save Context
    
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Save error: \(error)")
            }
        }
    }
}
