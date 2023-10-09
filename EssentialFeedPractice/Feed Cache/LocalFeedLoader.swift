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
}

extension LocalFeedLoader {
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
        store.insert(feed.toLocals(), timestamp: currentDate()) { [weak self] result in
            guard self != nil else { return }
            
            completion(result)
        }
    }
}

extension LocalFeedLoader: FeedLoader {
    public typealias LoadResult = FeedLoader.Result
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self else { return }
            
            switch result {
            case let .success(.some((feed, timestamp)))
                where FeedCachePolicy.validate(timestamp, against: self.currentDate()):
                completion(.success(feed.toModels()))
            case .success:
                completion(.success([]))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

extension LocalFeedLoader {
    public typealias ValidationResult = Result<Void, Error>
    
    public func validateCache(completion: @escaping (ValidationResult) -> Void = { _ in }) {
        store.retrieve { [weak self] result in
            guard let self else { return }
            
            switch result {
            case let .success(.some(cache))
                where !FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                self.store.deleteCachedFeed { _ in }
            case .success:
                completion(.success(()))
            case .failure:
                self.store.deleteCachedFeed { _ in }
            }
        }
    }
}

private extension [FeedImage] {
    func toLocals() -> [LocalFeedImage] {
        map { .init(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}

private extension [LocalFeedImage] {
    func toModels() -> [FeedImage] {
        map { .init(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}
