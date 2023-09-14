//
//  CoreDataFeedStore.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 14/09/2023.
//

import CoreData

public class CoreDataFeedStore: FeedStore {
    private let container: NSPersistentContainer
    
    public init(storeURL: URL) throws {
        self.container = try Self.loadContainer(for: storeURL)
    }
    
    public func retrieve(completion: @escaping RetrieveCompletion) {
        completion(.success(.none))
    }
    
    public func deleteCachedFeed(completion: @escaping DeleteCompletion) {
        
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertCompletion) {
        
    }
}

extension CoreDataFeedStore {
    enum StoreError: Error {
        case modelNotFound
        case loadContainerFailed
    }
    
    private static let modelName = "FeedStore"
    
    private static func loadContainer(for storeURL: URL) throws -> NSPersistentContainer {
        let container = NSPersistentContainer(name: modelName, managedObjectModel: try model())
        container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: storeURL)]
        
        var loadError: Error?
        container.loadPersistentStores { loadError = $1 }
        
        do {
            try loadError.map { throw $0 }
            return container
        } catch {
            throw StoreError.loadContainerFailed
        }
    }
    
    private static func model() throws -> NSManagedObjectModel {
        let bundle = Bundle(for: Self.self)
        guard let url = bundle.url(forResource: modelName, withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: url) else {
            throw StoreError.modelNotFound
        }
        
        return model
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
