//
//  CoreDataFeedStore.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 14/09/2023.
//

import CoreData

public class CoreDataFeedStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL) throws {
        guard let model = Self.model else {
            throw StoreError.modelNotFound
        }
        
        self.container = try Self.loadContainer(for: storeURL, with: model)
        self.context = container.newBackgroundContext()
    }
    
    func perform(_ block: @escaping (NSManagedObjectContext) -> Void) {
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
    private static let model = getModel()
    
    private static func getModel() -> NSManagedObjectModel? {
        let bundle = Bundle(for: Self.self)
        guard let url = bundle.url(forResource: modelName, withExtension: "momd") else {
            return nil
        }
        
        return NSManagedObjectModel(contentsOf: url)
    }
    
    private static func loadContainer(for storeURL: URL,
                                      with model: NSManagedObjectModel) throws -> NSPersistentContainer {
        let container = NSPersistentContainer(name: modelName, managedObjectModel: model)
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
}
