//
//  NullStore.swift
//  EssentialApp
//
//  Created by Tsz-Lung on 03/11/2023.
//

import Foundation
import EssentialFeedPractice

final class NullStore: FeedStore {
    func retrieve(completion: @escaping RetrieveCompletion) {
        completion(.success(nil))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertCompletion) {
        completion(.success(()))
    }
    
    func deleteCachedFeed(completion: @escaping DeleteCompletion) {
        completion(.success(()))
    }
}

extension NullStore: FeedImageDataStore {
    func insert(_ data: Data, for url: URL) throws {}
    
    func retrieveData(for url: URL) throws -> Data? {
        nil
    }
}
