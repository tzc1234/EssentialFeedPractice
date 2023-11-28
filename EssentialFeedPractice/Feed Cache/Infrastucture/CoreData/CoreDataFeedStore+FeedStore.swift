//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 09/10/2023.
//

import CoreData

extension CoreDataFeedStore: FeedStore {
    public func retrieve(completion: @escaping RetrieveCompletion) {
        performAsync { context in
            do {
                guard let managedCache = try ManagedCache.find(in: context) else {
                    completion(.success(.none))
                    return
                }
                
                completion(.success((managedCache.localFeed, managedCache.timestamp)))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertCompletion) {
        performAsync { context in
            do {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = feed.toManagedFeed(in: context)
                
                try context.save()
                completion(.success(()))
            } catch {
                context.rollback()
                completion(.failure(error))
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeleteCompletion) {
        performAsync { context in
            do {
                try ManagedCache.deleteCache(in: context)
                completion(.success(()))
            } catch {
                context.rollback()
                completion(.failure(error))
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
