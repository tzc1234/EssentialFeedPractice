//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 11/09/2023.
//

import XCTest
import EssentialFeedPractice

final class LoadFeedFromCacheUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStore() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()
        
        sut.load() { _ in }
        
        XCTAssertEqual(store.messages, [.retrieval])
    }
    
    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(retrievalError)) {
            store.completeRetrieval(with: retrievalError)
        }
    }
    
    func test_load_deliversNoImagesOnNonExpiredEmptyCache() {
        let now = Date()
        let (sut, store) = makeSUT(currentDate: { now })
        let emptyFeed = [LocalFeedImage]()
        let nonExpiredDate = now.minusMaxCacheAgeInDays().adding(seconds: 1)
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: emptyFeed, timestamp: nonExpiredDate)
        }
    }
    
    func test_load_deliversNoImagesOnExpiredCache() {
        let now = Date()
        let expiredDate = now.minusMaxCacheAgeInDays().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { now })
        let feed = uniqueFeed()
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: feed.locals, timestamp: expiredDate)
        }
    }
    
    func test_load_deliversNoImagesWhenCacheOnExpiration() {
        let now = Date()
        let expirationDate = now.minusMaxCacheAgeInDays()
        let (sut, store) = makeSUT(currentDate: { now })
        let feed = uniqueFeed()
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: feed.locals, timestamp: expirationDate)
        }
    }
    
    func test_load_deliversImagesOnNonExpiredCache() {
        let now = Date()
        let nonExpiredDate = now.minusMaxCacheAgeInDays().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { now })
        let feed = uniqueFeed()
        
        expect(sut, toCompleteWith: .success(feed.models)) {
            store.completeRetrieval(with: feed.locals, timestamp: nonExpiredDate)
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceIsDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store)
        
        var receivedResult: LocalFeedLoader.LoadResult?
        sut?.load { receivedResult = $0 }
        sut = nil
        store.completeRetrieval(with: [], timestamp: .now)
        
        XCTAssertNil(receivedResult)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader,
                        toCompleteWith expectedResult: LocalFeedLoader.LoadResult,
                        action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        sut.load() { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedReed), .success(expectedFeed)):
                XCTAssertEqual(receivedReed, expectedFeed, file: file, line: line)
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError as NSError, expectedError as NSError, file: file, line: line)
            default:
                XCTFail("Expect \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1)
    }
}
