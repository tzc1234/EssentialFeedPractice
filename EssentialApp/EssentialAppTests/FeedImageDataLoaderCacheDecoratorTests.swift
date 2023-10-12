//
//  FeedImageDataLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Tsz-Lung on 12/10/2023.
//

import XCTest
import EssentialFeedPractice

protocol FeedImageDataCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}

final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoader
    private let cache: FeedImageDataCache
    
    init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    private struct TaskWrapper: FeedImageDataLoaderTask {
        let wrapped: FeedImageDataLoaderTask
        
        func cancel() {
            wrapped.cancel()
        }
    }
    
    func loadImageData(from url: URL,
                       completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        TaskWrapper(wrapped: decoratee.loadImageData(from: url) { [weak self] result in
            if case let .success(data) = result {
                self?.cache.save(data, for: url) { _ in }
            }
            
            completion(result)
        })
    }
}

final class FeedImageDataLoaderCacheDecoratorTests: XCTestCase, FeedImageDataLoaderTestCase {
    func test_init_doesNotLoadImageData() {
        let (_, loader, _) = makeSUT()
        
        XCTAssertTrue(loader.loadedURLs.isEmpty)
    }
    
    func test_loadImageData_loadsFromLoader() {
        let (sut, loader, _) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(loader.loadedURLs, [url])
    }
    
    func test_cancelLoadImageData_cancelsLoaderTask() {
        let (sut, loader, _) = makeSUT()
        let url = anyURL()
        
        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()
        
        XCTAssertEqual(loader.cancelledURLs, [url])
    }
    
    func test_loadImageData_deliversDataOnLoaderSuccess() {
        let (sut, loader, _) = makeSUT()
        let imageData = anyData()
        
        expect(sut, toCompleteWith: .success(imageData), when: {
            loader.complete(with: imageData)
        })
    }
    
    func test_loadImageData_deliversDataOnLoaderFailure() {
        let (sut, loader, _) = makeSUT()
        let loaderError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(loaderError), when: {
            loader.complete(with: loaderError)
        })
    }
    
    func test_loadImageData_cachesLoadedImageDataOnLoaderSuccess() {
        let (sut, loader, cache) = makeSUT()
        let url = anyURL()
        let imageData = anyData()
        
        _ = sut.loadImageData(from: url) { _ in }
        loader.complete(with: imageData)
        
        XCTAssertEqual(cache.messages, [.save(imageData, for: url)])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: FeedImageDataLoader,
                                                 loader: FeedImageDataLoaderSpy,
                                                 cache: FeedImageDataCacheSpy) {
        let loader = FeedImageDataLoaderSpy()
        let cache = FeedImageDataCacheSpy()
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader, cache)
    }
    
    private class FeedImageDataCacheSpy: FeedImageDataCache {
        enum Message: Equatable {
            case save(Data, for: URL)
        }
        
        private(set) var messages = [Message]()
        
        func save(_ data: Data, for url: URL, completion: @escaping (FeedImageDataCache.Result) -> Void) {
            messages.append(.save(data, for: url))
        }
    }
}
