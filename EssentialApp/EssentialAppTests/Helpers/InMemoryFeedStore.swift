//
//  InMemoryFeedStore.swift
//  EssentialAppTests
//
//  Created by Tsz-Lung on 16/10/2023.
//

import Foundation
import EssentialFeedPractice

final class InMemoryFeedStore: FeedStore {
    private var feedImageDataCache = [URL: Data]()
    
    private(set) var feedCache: CachedFeed?
    
    init(feedCache: CachedFeed? = nil) {
        self.feedCache = feedCache
    }
    
    func retrieve() throws -> CachedFeed? {
       feedCache
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
        feedCache = (feed, timestamp)
    }
    
    func deleteCachedFeed() throws {
        feedCache = nil
    }
}

extension InMemoryFeedStore: FeedImageDataStore {
    func insert(_ data: Data, for url: URL) throws {
        feedImageDataCache[url] = data
    }

    func retrieveData(for url: URL) throws -> Data? {
        feedImageDataCache[url]
    }
}

extension InMemoryFeedStore {
    static var empty: InMemoryFeedStore {
        .init()
    }
    
    static var withExpiredFeedCache: InMemoryFeedStore {
        InMemoryFeedStore(feedCache: CachedFeed(feed: [], timestamp: .distantPast))
    }
    
    static var withNonExpiredFeedCache: InMemoryFeedStore {
        InMemoryFeedStore(feedCache: CachedFeed(feed: [], timestamp: .distantFuture))
    }
}
