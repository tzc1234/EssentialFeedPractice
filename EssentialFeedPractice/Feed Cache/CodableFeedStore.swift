//
//  CodableFeedStore.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 13/09/2023.
//

import Foundation

public final class CodableFeedStore: FeedStore {
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            feed.map(\.local)
        }
    }
    
    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let imageURL: URL
        
        init(_ model: LocalFeedImage) {
            self.id = model.id
            self.description = model.description
            self.location = model.location
            self.imageURL = model.imageURL
        }
        
        var local: LocalFeedImage {
            .init(id: id, description: description, location: location, imageURL: imageURL)
        }
    }
    
    private let storeURL: URL
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    public func retrieve(completion: @escaping RetrieveCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            completion(.success(.none))
            return
        }
        
        do {
            let decoded = try JSONDecoder().decode(Cache.self, from: data)
            completion(.success(.some((decoded.localFeed, decoded.timestamp))))
        } catch {
            completion(.failure(error))
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertCompletion) {
        do {
            let encoded = try JSONEncoder().encode(Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp))
            try encoded.write(to: storeURL)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeleteCompletion) {
        guard FileManager.default.fileExists(atPath: storeURL.path(percentEncoded: false)) else {
            completion(.success(()))
            return
        }
        
        do {
            try FileManager.default.removeItem(at: storeURL)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
}
