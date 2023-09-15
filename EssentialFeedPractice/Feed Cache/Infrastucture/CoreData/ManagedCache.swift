//
//  ManagedCache.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 15/09/2023.
//

import CoreData

@objc(ManagedCache)
final class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
}

extension ManagedCache {
    var localFeed: [LocalFeedImage] {
        feed.compactMap { $0 as? ManagedFeedImage }.map(\.local)
    }
    
    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        try find(by: context).map(context.delete)
        return ManagedCache(context: context)
    }
    
    static func find(by context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: String(describing: Self.self))
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
}
