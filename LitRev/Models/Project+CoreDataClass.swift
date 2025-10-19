//
//  Project+CoreDataClass.swift
//  LitRev
//
//  Core Data entity for Project
//

import Foundation
import CoreData

@objc(Project)
public class Project: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var researchQuestion: String?
    @NSManaged public var notesData: Data?
    @NSManaged public var createdAt: Date?
    @NSManaged public var lastModified: Date?
    @NSManaged public var sources: NSSet?
    @NSManaged public var excerpts: NSSet?
}

extension Project {
    @objc(addSourcesObject:)
    @NSManaged public func addToSources(_ value: Source)

    @objc(removeSourcesObject:)
    @NSManaged public func removeFromSources(_ value: Source)

    @objc(addSources:)
    @NSManaged public func addToSources(_ values: NSSet)

    @objc(removeSources:)
    @NSManaged public func removeFromSources(_ values: NSSet)
}

