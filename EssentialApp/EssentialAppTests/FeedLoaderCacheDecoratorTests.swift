//
//  FeedLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Tsz-Lung on 12/10/2023.
//

import XCTest
import EssentialFeedPractice
import EssentialApp

final class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTestCase {
    func test_load_deliversFeedOnLoaderSuccess() {
        let feed = uniqueFeed()
        let (sut, _) = makeSUT(loaderResult: .success(feed))
        
        expect(sut, toCompleteWith: .success(feed))
    }
    
    func test_load_deliversFeedOnLoaderFailure() {
        let (sut, _) = makeSUT(loaderResult: .failure(anyNSError()))
        
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
    func test_load_cachesLoadedFeedOnLoaderSuccess() {
        let feed = uniqueFeed()
        let (sut, cache) = makeSUT(loaderResult: .success(feed))
        
        sut.load { _ in }
        
        XCTAssertEqual(cache.messages, [.save(feed)])
    }
    
    func test_load_doesNotCacheOnLoaderFailure() {
        let (sut, cache) = makeSUT(loaderResult: .failure(anyNSError()))
        
        sut.load { _ in }
        
        XCTAssertTrue(cache.messages.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(loaderResult: FeedLoader.Result,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: FeedLoader, cache: CacheSpy) {
        let loader = FeedLoaderStub(result: loaderResult)
        let cache = CacheSpy()
        let sut = FeedLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(cache, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, cache)
    }
    
    private class CacheSpy: FeedCache {
        enum Message: Equatable {
            case save([FeedImage])
        }
        
        private(set) var messages = [Message]()
        
        func save(_ feed: [FeedImage], completion: @escaping (FeedCache.Result) -> Void) {
            messages.append(.save(feed))
            completion(.success(()))
        }
    }
}
