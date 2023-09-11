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
        
        let exp = expectation(description: "Wait for load completion")
        sut.load() { result in
            switch result {
            case .success:
                XCTFail("Expect a failure")
            case let .failure(error):
                XCTAssertEqual(error as NSError, retrievalError)
            }
            exp.fulfill()
        }
        store.completeRetrieval(with: retrievalError)
        wait(for: [exp], timeout: 1)
    }
    
    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut, store) = makeSUT()
        let emptyFeed = [FeedImage]()
        
        let exp = expectation(description: "Wait for load completion")
        sut.load() { result in
            switch result {
            case let .success(feed):
                XCTAssertEqual(feed, [])
            case .failure:
                XCTFail("Expect a success")
            }
            exp.fulfill()
        }
        store.completeRetrieval(with: emptyFeed)
        wait(for: [exp], timeout: 1)
    }
    
    func test_load_deliversNoImagesOnExpiredCache() {
        let now = Date()
        let expiredDate = now.adding(days: -7).adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { now })
        let feed = uniqueFeed()
        
        let exp = expectation(description: "Wait for load completion")
        sut.load() { result in
            switch result {
            case let .success(feed):
                XCTAssertEqual(feed, [])
            case .failure:
                XCTFail("Expect a success")
            }
            exp.fulfill()
        }
        store.completeRetrieval(with: feed.models, timestamp: expiredDate)
        wait(for: [exp], timeout: 1)
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

private extension Date {
    func adding(days: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        calendar.date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        self + 1
    }
}
