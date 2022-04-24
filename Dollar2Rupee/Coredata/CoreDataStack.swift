//
//  PersistanceService.swift
//  Dollar2Rupee
//
//  Created by Ankerasani on 4/2/19.
//  Copyright © 2019 Ankersani. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    // MARK: - Core Data stack
    
    private init() {}
    
    static var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "RemittanceModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    static func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // Creation
    static func createPhotoEntityFrom(rate: Rate) -> NSManagedObject? {
        let context = CoreDataStack.context
        if let remittance = NSEntityDescription.insertNewObject(forEntityName: "Remittance", into: context) as? Remittance {
            remittance.currancy = rate.currency
            remittance.dateString = rate.dateString
            remittance.rate = rate.rate
            remittance.forexRate = rate.forexRate
            return remittance
        }
        return nil
    }
    
    // Reading data
    private static var fetchedhResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Remittance.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateString", ascending: false)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
        return frc
    }()
    
    // Updating data
    static func saveInCoreDataWith(array: [Rate]) {
        _ = array.map{self.createPhotoEntityFrom(rate: $0)}
        self.saveContext()
    }
    
    static func getCoreDataObjects() -> Dictionary<String,[Remittance]> {
        do {
            try CoreDataStack.fetchedhResultController.performFetch()
            let objects = CoreDataStack.fetchedhResultController.fetchedObjects
            guard let remittance = objects as? [Remittance] else {
                return [:]
            }
            
            let sortedFields = Dictionary(grouping: remittance) {$0.dateString}
            return sortedFields as? Dictionary<String, [Remittance]> ?? [:]
        } catch _  {
            return [:]
        }
    }
    
    static func getCurrentDayObjects() {
        
    }
    
    static func checkCurrentDataObjects(objects: Dictionary<String,[Remittance]>) -> [Remittance] {
        let today = Date()
        let currentDateString = today.toString(dateFormat: "dd-MMM-yyyy")
        
        if objects.keys.contains(currentDateString) {
            return objects[currentDateString] ?? []
        }
        return []
    }
    
}


extension Date
{
    func toString(dateFormat format  : String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
