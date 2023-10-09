//
//  CoreDataFeedStore+FeedImageDataStore.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 09/10/2023.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
    public func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        perform { context in
            completion(Result {
                let image = try ManagedFeedImage.first(with: url, in: context)
                image?.data = data
                try context.save()
            })
        }
    }
    
    public func retrieveData(for url: URL, completion: @escaping (RetrievalResult) -> Void) {
        perform { context in
            completion(Result {
                try? ManagedFeedImage.first(with: url, in: context)?.data
            })
        }
    }
}
