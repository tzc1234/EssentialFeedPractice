//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 12/09/2023.
//

import XCTest
import EssentialFeedPractice

final class ValidateFeedCacheUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStore() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    func test_validateCache_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        store.completeRetrieval(with: anyNSError())
        
        try? sut.validateCache()
        
        XCTAssertEqual(store.messages, [.retrieval, .deletion])
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()
        store.completeRetrievalWithEmptyCache()
        
        try? sut.validateCache()
        
        XCTAssertEqual(store.messages, [.retrieval])
    }
    
    func test_validateCache_doesNotDeleteCacheOnNonExpiredCache() {
        let now = Date()
        let nonExpiredDate = now.minusMaxCacheAgeInDays().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { now })
        let feed = uniqueFeed()
        store.completeRetrieval(with: feed.locals, timestamp: nonExpiredDate)
        
        try? sut.validateCache()
        
        XCTAssertEqual(store.messages, [.retrieval])
    }
    
    func test_validateCache_deletesCacheWhenCacheOnExpiration() {
        let now = Date()
        let expirationDate = now.minusMaxCacheAgeInDays()
        let (sut, store) = makeSUT(currentDate: { now })
        let feed = uniqueFeed()
        store.completeRetrieval(with: feed.locals, timestamp: expirationDate)
        
        try? sut.validateCache()
        
        XCTAssertEqual(store.messages, [.retrieval, .deletion])
    }
    
    func test_validateCache_deletesCacheOnExpiredCache() {
        let now = Date()
        let expiredDate = now.minusMaxCacheAgeInDays().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { now })
        let feed = uniqueFeed()
        store.completeRetrieval(with: feed.locals, timestamp: expiredDate)
        
        try? sut.validateCache()
        
        XCTAssertEqual(store.messages, [.retrieval, .deletion])
    }
    
    func test_validateCache_failsOnDeletionErrorOfFailedRetrieval() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(deletionError), when: {
            store.completeRetrieval(with: anyNSError())
            store.completeDeletion(with: deletionError)
        })
    }
    
    func test_validateCache_succeedsOnSuccessfulDeletionOfFailedRetrieval() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success(()), when: {
            store.completeRetrieval(with: anyNSError())
            store.completeDeletionSuccessfully()
        })
    }
    
    func test_validateCache_succeedsOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success(()), when: {
            store.completeRetrievalWithEmptyCache()
        })
    }
    
    func test_validateCache_succeedsOnNonExpiredCache() {
        let now = Date.now
        let (sut, store) = makeSUT(currentDate: { now })
        let nonExpiredTimestamp = now.minusMaxCacheAgeInDays().adding(seconds: 1)
        let feed = uniqueFeed().locals
        
        expect(sut, toCompleteWith: .success(()), when: {
            store.completeRetrieval(with: feed, timestamp: nonExpiredTimestamp)
        })
    }
    
    func test_validateCache_failsOnDeletionErrorOfExpiredCache() {
        let now = Date.now
        let (sut, store) = makeSUT(currentDate: { now })
        let expiredTimestamp = now.minusMaxCacheAgeInDays().adding(seconds: -1)
        let feed = uniqueFeed().locals
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(deletionError), when: {
            store.completeRetrieval(with: feed, timestamp: expiredTimestamp)
            store.completeDeletion(with: deletionError)
        })
    }
    
    func test_validateCache_succeedsOnSuccessfulDeletionOfExpiredCache() {
        let now = Date.now
        let (sut, store) = makeSUT(currentDate: { now })
        let expiredTimestamp = now.minusMaxCacheAgeInDays().adding(seconds: -1)
        let feed = uniqueFeed().locals
        
        expect(sut, toCompleteWith: .success(()), when: {
            store.completeRetrieval(with: feed, timestamp: expiredTimestamp)
            store.completeDeletionSuccessfully()
        })
    }
    
    func test_validateCache_failsOnDeletionErrorOfCacheThatOnExpiration() {
        let now = Date.now
        let (sut, store) = makeSUT(currentDate: { now })
        let expirationTimestamp = now.minusMaxCacheAgeInDays()
        let feed = uniqueFeed().locals
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(deletionError), when: {
            store.completeRetrieval(with: feed, timestamp: expirationTimestamp)
            store.completeDeletion(with: deletionError)
        })
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
                        toCompleteWith expectedResult: Result<Void, Error>,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        action()
        
        let receivedResult = Result { try sut.validateCache() }
        
        switch (receivedResult, expectedResult) {
        case (.success, .success):
            break
        case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
            XCTAssertEqual(receivedError, expectedError, file: file, line: line)
        default:
            XCTFail("Expect result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
        }
    }
}
