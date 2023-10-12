//
//  FeedImageDataLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Tsz-Lung on 12/10/2023.
//

import Foundation
import EssentialFeedPractice

public final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoader
    private let cache: FeedImageDataCache
    
    public init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    private struct TaskWrapper: FeedImageDataLoaderTask {
        let wrapped: FeedImageDataLoaderTask
        
        func cancel() {
            wrapped.cancel()
        }
    }
    
    public func loadImageData(from url: URL,
                       completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        TaskWrapper(wrapped: decoratee.loadImageData(from: url) { [weak self] result in
            completion(result.map { data in
                self?.cache.save(data, for: url) { _ in }
                return data
            })
        })
    }
}
