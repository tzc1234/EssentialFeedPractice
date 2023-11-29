//
//  NullStore.swift
//  EssentialApp
//
//  Created by Tsz-Lung on 03/11/2023.
//

import Foundation
import EssentialFeedPractice

final class NullStore: FeedStore {
    func retrieve() throws -> CachedFeed? {
        nil
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {}
    
    func deleteCachedFeed() throws {}
}

extension NullStore: FeedImageDataStore {
    func insert(_ data: Data, for url: URL) throws {}
    
    func retrieveData(for url: URL) throws -> Data? {
        nil
    }
}
