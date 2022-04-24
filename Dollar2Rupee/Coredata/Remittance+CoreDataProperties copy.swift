//
//  Remittance+CoreDataProperties.swift
//  
//
//  Created by Ankerasani on 4/2/19.
//
//

import Foundation
import CoreData

extension Remittance {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Remittance> {
        return NSFetchRequest<Remittance>(entityName: "Remittance")
    }

    @NSManaged public var currancy: String?
    @NSManaged public var rate: Double
    @NSManaged public var dateString: String?
    @NSManaged public var forexRate: String?


}
