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
        
        sut.validateCache() { _ in }
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.messages, [.retrieval, .deletion])
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.validateCache() { _ in }
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.messages, [.retrieval])
    }
    
    func test_validateCache_doesNotDeleteCacheOnNonExpiredCache() {
        let now = Date()
        let nonExpiredDate = now.minusMaxCacheAgeInDays().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { now })
        let feed = uniqueFeed()
        
        sut.validateCache() { _ in }
        store.completeRetrieval(with: feed.locals, timestamp: nonExpiredDate)
        
        XCTAssertEqual(store.messages, [.retrieval])
    }
    
    func test_validateCache_deletesCacheWhenCacheOnExpiration() {
        let now = Date()
        let expirationDate = now.minusMaxCacheAgeInDays()
        let (sut, store) = makeSUT(currentDate: { now })
        let feed = uniqueFeed()
        
        sut.validateCache() { _ in }
        store.completeRetrieval(with: feed.locals, timestamp: expirationDate)
        
        XCTAssertEqual(store.messages, [.retrieval, .deletion])
    }
    
    func test_validateCache_deletesCacheOnExpiredCache() {
        let now = Date()
        let expiredDate = now.minusMaxCacheAgeInDays().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { now })
        let feed = uniqueFeed()
        
        sut.validateCache() { _ in }
        store.completeRetrieval(with: feed.locals, timestamp: expiredDate)
        
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
    
    func test_validateCache_doesNotDeleteInvalidCacheAfterSUTInstanceIsDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store)
        
        sut?.validateCache() { _ in }
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
    
    private func expect(_ sut: LocalFeedLoader, 
                        toCompleteWith expectedResult: LocalFeedLoader.ValidationResult,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for validation")
        sut.validateCache { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success, .success):
                break
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expect result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1)
    }
}
