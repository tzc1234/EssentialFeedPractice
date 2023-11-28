//
//  CoreDataFeedStore+FeedImageDataStore.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 09/10/2023.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
    public func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        performAsync { context in
            completion(Result {
                try ManagedFeedImage.first(with: url, in: context)
                    .map { $0.data = data }
                    .map(context.save)
            })
        }
    }
    
    public func retrieveData(for url: URL, completion: @escaping (RetrievalResult) -> Void) {
        performAsync { context in
            completion(Result {
                try ManagedFeedImage.data(with: url, in: context)
            })
        }
    }
}
