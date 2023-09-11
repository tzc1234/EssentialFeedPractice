//
//  FeedStore.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 11/09/2023.
//

import Foundation

public protocol FeedStore {
    func deleteCachedFeed(completion: @escaping (Result<Void, Error>) -> Void)
    func insert(_ feed: [FeedImage], timestamp: Date, completion: @escaping (Result<Void, Error>) -> Void)
}
