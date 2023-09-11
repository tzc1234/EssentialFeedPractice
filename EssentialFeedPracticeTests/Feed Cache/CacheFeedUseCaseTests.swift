//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 10/09/2023.
//

import XCTest
import EssentialFeedPractice

final class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStore() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()
        let feed = uniqueFeed()
        
        sut.save(feed.models) { _ in }
        
        XCTAssertEqual(store.messages, [.deletion])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let feed = uniqueFeed()
        let deletionError = anyNSError()
        
        sut.save(feed.models) { _ in }
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.messages, [.deletion])
    }
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let feed = uniqueFeed()
        
        sut.save(feed.models) { _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.messages, [.deletion, .insertion(feed.locals, timestamp)])
    }
    
    func test_save_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(deletionError)) {
            store.completeDeletion(with: deletionError)
        }
    }
    
    func test_save_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(insertionError)) {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        }
    }
    
    func test_save_succeedsOnSuccessfulCacheInsertion() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success(())) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
    }
    
    func test_save_doesNotDeliverDeletionErrorWhenSUTInstanceIsDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store)
        
        var receivedResult: LocalFeedLoader.SaveResult?
        sut?.save(uniqueFeed().models, completion: { receivedResult = $0 })
        sut = nil
        store.completeDeletion(with: anyNSError())
        
        XCTAssertNil(receivedResult)
    }
    
    func test_save_doesNotDeliverInsertionErrorWhenSUTInstanceIsDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store)
        
        var receivedResult: LocalFeedLoader.SaveResult?
        sut?.save(uniqueFeed().models, completion: { receivedResult = $0 })
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())
        
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
                        toCompleteWith expectedResult: LocalFeedLoader.SaveResult,
                        action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for save completion")
        sut.save(uniqueFeed().models) { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success, .success):
                break
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
