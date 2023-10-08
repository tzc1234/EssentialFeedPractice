//
//  LocalFeedImageDataLoader.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 08/10/2023.
//

import Foundation

public final class LocalFeedImageDataLoader: FeedImageDataLoader {
    private let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
    
    public enum Error: Swift.Error {
        case fail
        case notFound
    }
    
    private class ImageDataLoaderTaskWrapper: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
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
                              completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let taskWrapper = ImageDataLoaderTaskWrapper(completion)
        store.retrieveData(for: url) { [weak self] result in
            guard self != nil else { return }
            
            taskWrapper.complete(with: result
                .mapError { _ in Error.fail }
                .flatMap { data in data.map { .success($0) } ?? .failure(Error.notFound) }
            )
        }
        return taskWrapper
    }
}

extension LocalFeedImageDataLoader {
    public typealias SaveResult = Swift.Result<Void, Error>
    
    public func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(data, for: url) { result in
            
        }
    }
}
