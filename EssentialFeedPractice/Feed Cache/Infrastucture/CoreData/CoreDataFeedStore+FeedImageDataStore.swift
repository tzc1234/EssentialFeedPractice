//
//  CoreDataFeedStore+FeedImageDataStore.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 09/10/2023.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
    public func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        
    }
    
    public func retrieveData(for url: URL, completion: @escaping (RetrievalResult) -> Void) {
        completion(.success(.none))
    }
}
