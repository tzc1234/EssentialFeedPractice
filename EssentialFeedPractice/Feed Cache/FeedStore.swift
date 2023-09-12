//
//  FeedStore.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 11/09/2023.
//

import Foundation

public protocol FeedStore {
    typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)
    
    func deleteCachedFeed(completion: @escaping (Result<Void, Error>) -> Void)
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping (Result<Void, Error>) -> Void)
    func retrieve(completion: @escaping (Result<CachedFeed?, Error>) -> Void)
}
