//
//  CoreDataFeedStore.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 14/09/2023.
//

import CoreData

public class CoreDataFeedStore: FeedStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL) throws {
        self.container = try Self.loadContainer(for: storeURL)
        self.context = container.newBackgroundContext()
    }
    
    public func retrieve(completion: @escaping RetrieveCompletion) {
        perform { context in
            do {
                guard let managedCache = try ManagedCache.find(by: context) else {
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
        perform { context in
            do {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = feed.toManagedFeed(in: context)
                
                try context.save()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeleteCompletion) {
        perform { context in
            do {
                try ManagedCache.find(by: context).map(context.delete).map(context.save)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private func perform(_ block: @escaping (NSManagedObjectContext) -> Void) {
        context.perform { [context] in
            block(context)
        }
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

private extension [LocalFeedImage] {
    func toManagedFeed(in context: NSManagedObjectContext) -> NSOrderedSet {
        NSOrderedSet(array: map { local in
            let managed = ManagedFeedImage(context: context)
            managed.id = local.id
            managed.imageDescription = local.description
            managed.location = local.location
            managed.url = local.url
            return managed
        })
    }
}
