//
//  FeedStore.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 11/09/2023.
//

import Foundation

public protocol FeedStore {
    typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)
    
    func retrieve() throws -> CachedFeed?
    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws
    func deleteCachedFeed() throws
}
