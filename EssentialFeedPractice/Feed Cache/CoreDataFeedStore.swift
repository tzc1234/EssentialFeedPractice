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
        context.perform { [context] in
            let request = NSFetchRequest<ManagedCache>(entityName: "ManagedCache")
            request.returnsObjectsAsFaults = false
            request.fetchLimit = 1
            
            do {
                guard let managedCache = try context.fetch(request).first else {
                    completion(.success(.none))
                    return
                }
                        
                let feed = managedCache.feed
                    .compactMap { $0 as? ManagedFeedImage }
                    .map { image in
                        LocalFeedImage(
                            id: image.id,
                            description: image.imageDescription,
                            location: image.location,
                            imageURL: image.url)
                }
                
                completion(.success((feed, managedCache.timestamp)))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeleteCompletion) {
        
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertCompletion) {
        context.perform { [context] in
            let managedCache = ManagedCache(context: context)
            managedCache.timestamp = timestamp
            managedCache.feed = NSOrderedSet(array: feed.map { local in
                let managed = ManagedFeedImage(context: context)
                managed.id = local.id
                managed.imageDescription = local.description
                managed.location = local.location
                managed.url = local.imageURL
                return managed
            })
            
            do {
                try context.save()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
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
