//
//  FeedStore.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 11/09/2023.
//

import Foundation

public struct LocalFeedImage: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(id: UUID, description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}

public protocol FeedStore {
    func deleteCachedFeed(completion: @escaping (Result<Void, Error>) -> Void)
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping (Result<Void, Error>) -> Void)
}
