//
//  Source+CoreDataClass.swift
//  LitRev
//
//  Core Data entity for Source
//

import Foundation
import CoreData

@objc(Source)
public class Source: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var authors: String?
    @NSManaged public var year: Int32
    @NSManaged public var journal: String?
    @NSManaged public var doi: String?
    @NSManaged public var apaReference: String?
    @NSManaged public var dateAdded: Date?
    @NSManaged public var filePath: String?
    @NSManaged public var fileName: String?
    @NSManaged public var project: Project?
    @NSManaged public var excerpts: NSSet?
}

extension Source {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Source> {
        return NSFetchRequest<Source>(entityName: "Source")
    }
}

