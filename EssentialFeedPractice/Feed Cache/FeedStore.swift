//
//  FeedStore.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 11/09/2023.
//

import Foundation

public protocol FeedStore {
    typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)
    typealias RetrieveResult = Result<CachedFeed?, Error>
    
    typealias RetrieveCompletion = (RetrieveResult) -> Void
    typealias InsertCompletion = (Result<Void, Error>) -> Void
    typealias DeleteCompletion = (Result<Void, Error>) -> Void
    
    func retrieve() throws -> CachedFeed?
    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws
    func deleteCachedFeed() throws
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    @available(*, deprecated)
    func retrieve(completion: @escaping RetrieveCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    @available(*, deprecated)
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    @available(*, deprecated)
    func deleteCachedFeed(completion: @escaping DeleteCompletion)
}

public extension FeedStore {
    func retrieve() throws -> CachedFeed? {
        let group = DispatchGroup()
        group.enter()
        var result: RetrieveResult!
        retrieve {
            result = $0
            group.leave()
        }
        group.wait()
        return try result.get()
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
        let group = DispatchGroup()
        group.enter()
        var result: Result<Void, Error>!
        insert(feed, timestamp: timestamp) {
            result = $0
            group.leave()
        }
        group.wait()
        try result.get()
    }
    
    func deleteCachedFeed() throws {
        let group = DispatchGroup()
        group.enter()
        var result: Result<Void, Error>!
        deleteCachedFeed {
            result = $0
            group.leave()
        }
        group.wait()
        try result.get()
    }
    
    func retrieve(completion: @escaping RetrieveCompletion) {}
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertCompletion) {}
    func deleteCachedFeed(completion: @escaping DeleteCompletion) {}
}
