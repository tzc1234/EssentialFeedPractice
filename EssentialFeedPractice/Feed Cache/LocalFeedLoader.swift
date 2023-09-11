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
        store.insert(feed.toLocals(), timestamp: currentDate()) { [weak self] result in
            guard self != nil else { return }
            
            completion(result)
        }
    }
    
    public func load(completion: @escaping (Result<[FeedImage], Error>) -> Void) {
        store.retrieve { [weak self] result in
            switch result {
            case let .success((feed, timestamp)) where self?.isValid(timestamp) == true:
                completion(.success(feed.toModels()))
            case .success:
                completion(.success([]))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    private func isValid(_ timestamp: Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        guard let expirationDate = calendar.date(byAdding: .day, value: -7, to: currentDate()) else {
            return false
        }
        
        return timestamp > expirationDate
    }
}

private extension [FeedImage] {
    func toLocals() -> [LocalFeedImage] {
        map { .init(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) }
    }
}

private extension [LocalFeedImage] {
    func toModels() -> [FeedImage] {
        map { .init(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) }
    }
}
