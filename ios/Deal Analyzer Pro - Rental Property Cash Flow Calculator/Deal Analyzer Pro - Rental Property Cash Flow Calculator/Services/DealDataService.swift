//
//  DealDataService.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/18.
//

import Foundation
import CoreData

/// Service for managing property deals with Core Data
@Observable
class DealDataService {
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = context
    }
    
    // MARK: - Fetch Deals
    
    func fetchAllDeals() -> [PropertyDeal] {
        let request: NSFetchRequest<PropertyEntity> = PropertyEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isArchived == NO")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \PropertyEntity.updatedAt, ascending: false)]
        
        do {
            let entities = try viewContext.fetch(request)
            return entities.map { $0.toPropertyDeal() }
        } catch {
            print("Fetch failed: \(error)")
            return []
        }
    }
    
    func fetchArchivedDeals() -> [PropertyDeal] {
        let request: NSFetchRequest<PropertyEntity> = PropertyEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isArchived == YES")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \PropertyEntity.updatedAt, ascending: false)]
        
        do {
            let entities = try viewContext.fetch(request)
            return entities.map { $0.toPropertyDeal() }
        } catch {
            print("Fetch failed: \(error)")
            return []
        }
    }
    
    // MARK: - Save Deal
    
    func saveDeal(_ deal: PropertyDeal) {
        // Check if deal already exists
        let request: NSFetchRequest<PropertyEntity> = PropertyEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", deal.id as CVarArg)
        
        do {
            let existing = try viewContext.fetch(request).first
            let entity = existing ?? PropertyEntity(context: viewContext)
            entity.update(from: deal)
            try viewContext.save()
        } catch {
            print("Save failed: \(error)")
        }
    }
    
    // MARK: - Delete Deal
    
    func deleteDeal(_ deal: PropertyDeal) {
        let request: NSFetchRequest<PropertyEntity> = PropertyEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", deal.id as CVarArg)
        
        do {
            if let entity = try viewContext.fetch(request).first {
                viewContext.delete(entity)
                try viewContext.save()
            }
        } catch {
            print("Delete failed: \(error)")
        }
    }
    
    // MARK: - Archive Deal
    
    func archiveDeal(_ deal: PropertyDeal) {
        let request: NSFetchRequest<PropertyEntity> = PropertyEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", deal.id as CVarArg)
        
        do {
            if let entity = try viewContext.fetch(request).first {
                entity.isArchived = true
                entity.updatedAt = Date()
                try viewContext.save()
            }
        } catch {
            print("Archive failed: \(error)")
        }
    }
    
    func unarchiveDeal(_ deal: PropertyDeal) {
        let request: NSFetchRequest<PropertyEntity> = PropertyEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", deal.id as CVarArg)
        
        do {
            if let entity = try viewContext.fetch(request).first {
                entity.isArchived = false
                entity.updatedAt = Date()
                try viewContext.save()
            }
        } catch {
            print("Unarchive failed: \(error)")
        }
    }
    
    // MARK: - Count
    
    func dealCount() -> Int {
        let request: NSFetchRequest<PropertyEntity> = PropertyEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isArchived == NO")
        
        do {
            return try viewContext.count(for: request)
        } catch {
            return 0
        }
    }
}
