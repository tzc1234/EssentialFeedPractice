//
//  CoreDataFeedStore.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 14/09/2023.
//

import CoreData

public class CoreDataFeedStore: FeedStore {
    public init() {
        
    }
    
    public func retrieve(completion: @escaping RetrieveCompletion) {
        completion(.success(.none))
    }
    
    public func deleteCachedFeed(completion: @escaping DeleteCompletion) {
        
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertCompletion) {
        
    }
}

@objc(ManagedCache)
class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
}

@objc(ManagedFeedImage)
class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache
}
