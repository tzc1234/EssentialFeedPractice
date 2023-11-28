//
//  LocalFeedImageDataLoader.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 08/10/2023.
//

import Foundation

public final class LocalFeedImageDataLoader {
    private let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
}

extension LocalFeedImageDataLoader: FeedImageDataCache {
    public enum SaveError: Error {
        case failed
    }
    
    public func save(_ data: Data, for url: URL) throws {
        do {
            try store.insert(data, for: url)
        } catch {
            throw SaveError.failed
        }
    }
}

extension LocalFeedImageDataLoader: FeedImageDataLoader {
    public typealias LoadResult = FeedImageDataLoader.Result
    
    public enum LoadError: Error {
        case failed
        case notFound
    }
    
    private class ImageDataLoaderTaskWrapper: FeedImageDataLoaderTask {
        private var completion: ((LoadResult) -> Void)?
        
        init(_ completion: @escaping (LoadResult) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: LoadResult) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    public func loadImageData(from url: URL,
                              completion: @escaping (LoadResult) -> Void) -> FeedImageDataLoaderTask {
        let taskWrapper = ImageDataLoaderTaskWrapper(completion)
        taskWrapper.complete(
            with: Swift.Result {
                try store.retrieveData(for: url)
            }
            .mapError { _ in LoadError.failed }
            .flatMap { data in data.map { .success($0) } ?? .failure(LoadError.notFound)
        })
        return taskWrapper
    }
}
