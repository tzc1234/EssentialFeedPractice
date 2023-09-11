//
//  LocalFeedLoader.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 11/09/2023.
//

import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date = Date.init) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public typealias SaveResult = Result<Void, Error>
    
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success:
                self.cache(feed, with: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], with completion: @escaping (Result<Void, Error>) -> Void) {
        store.insert(feed, timestamp: currentDate()) { [weak self] result in
            guard self != nil else { return }
            
            completion(result)
        }
    }
}
