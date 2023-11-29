//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 09/10/2023.
//

import CoreData

extension CoreDataFeedStore: FeedStore {
    public func retrieve() throws -> CachedFeed? {
        try performSync { context in
            Result {
                try ManagedCache.find(in: context)
            }.map { cache in
                cache == nil ? .none : cache.map { ($0.localFeed, $0.timestamp) }
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
        try performSync { context in
            Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = feed.toManagedFeed(in: context)
                
                try context.save()
            }.mapError { error in
                context.rollback()
                return error
            }
        }
    }
    
    public func deleteCachedFeed() throws {
        try performSync { context in
            Result {
                try ManagedCache.deleteCache(in: context)
            }.mapError { error in
                context.rollback()
                return error
            }
        }
    }
}

private extension [LocalFeedImage] {
    func toManagedFeed(in context: NSManagedObjectContext) -> NSOrderedSet {
        let feed = NSOrderedSet(array: map { local in
            let managed = ManagedFeedImage(context: context)
            managed.id = local.id
            managed.imageDescription = local.description
            managed.location = local.location
            managed.url = local.url
            managed.data = context.userInfo[local.url] as? Data
            return managed
        })
        context.userInfo.removeAllObjects()
        return feed
    }
}
