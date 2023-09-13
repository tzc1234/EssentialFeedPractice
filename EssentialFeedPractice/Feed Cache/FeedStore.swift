//
//  FeedStore.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 11/09/2023.
//

import Foundation

public protocol FeedStore {
    typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)
    
    typealias DeleteCompletion = (Result<Void, Error>) -> Void
    typealias InsertCompletion = (Result<Void, Error>) -> Void
    typealias RetrieveCompletion = (Result<CachedFeed?, Error>) -> Void
    
    func deleteCachedFeed(completion: @escaping DeleteCompletion)
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertCompletion)
    func retrieve(completion: @escaping RetrieveCompletion)
}
