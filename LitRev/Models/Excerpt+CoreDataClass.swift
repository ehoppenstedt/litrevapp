//
//  Excerpt+CoreDataClass.swift
//  LitRev
//
//  Core Data entity for Excerpt
//

import Foundation
import CoreData

@objc(Excerpt)
public class Excerpt: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID?
    @NSManaged public var content: String?
    @NSManaged public var pageNumber: String?
    @NSManaged public var tags: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var source: Source?
    @NSManaged public var project: Project?
}

extension Excerpt {
    static func fetchRequest() -> NSFetchRequest<Excerpt> {
        return NSFetchRequest<Excerpt>(entityName: "Excerpt")
    }
}

