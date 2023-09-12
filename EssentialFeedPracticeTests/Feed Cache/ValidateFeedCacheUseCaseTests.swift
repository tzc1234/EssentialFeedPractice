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
        
        sut.validateCache()
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.messages, [.retrieval, .deletion])
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let now = Date()
        let nonExpiredDate = now.minusMaxCacheAgeInDays().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { now })
        
        sut.validateCache()
        store.completeRetrieval(with: [], timestamp: nonExpiredDate)
        
        XCTAssertEqual(store.messages, [.retrieval])
    }
    
    func test_validateCache_doesNotDeleteCacheOnNonExpiredCache() {
        let now = Date()
        let nonExpiredDate = now.minusMaxCacheAgeInDays().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { now })
        let feed = uniqueFeed()
        
        sut.validateCache()
        store.completeRetrieval(with: feed.locals, timestamp: nonExpiredDate)
        
        XCTAssertEqual(store.messages, [.retrieval])
    }
    
    func test_validateCache_deletesCacheWhenCacheOnExpiration() {
        let now = Date()
        let expirationDate = now.minusMaxCacheAgeInDays()
        let (sut, store) = makeSUT(currentDate: { now })
        let feed = uniqueFeed()
        
        sut.validateCache()
        store.completeRetrieval(with: feed.locals, timestamp: expirationDate)
        
        XCTAssertEqual(store.messages, [.retrieval, .deletion])
    }
    
    func test_validateCache_deletesCacheOnExpiredCache() {
        let now = Date()
        let expiredDate = now.minusMaxCacheAgeInDays().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { now })
        let feed = uniqueFeed()
        
        sut.validateCache()
        store.completeRetrieval(with: feed.locals, timestamp: expiredDate)
        
        XCTAssertEqual(store.messages, [.retrieval, .deletion])
    }
    
    func test_validateCache_doesNotDeleteInvalidCacheAfterSUTInstanceIsDeallocated() {
        let store = FeedStoreSpy()
        let now = Date()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: { now })
        
        sut?.validateCache()
        sut = nil
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.messages, [.retrieval])
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
}
