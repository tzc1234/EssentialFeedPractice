//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 10/09/2023.
//

import XCTest
import EssentialFeedPractice

class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date = Date.init) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ feed: [FeedImage], completion: @escaping (Result<Void, Error>) -> Void) {
        store.deleteCachedFeed { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success:
                self.store.insert(feed, timestamp: self.currentDate(), completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

class FeedStore {
    private(set) var messages = [Message]()
    private var deletionCompletions = [(Result<Void, Error>) -> Void]()
    private var insertionCompletions = [(Result<Void, Error>) -> Void]()
    
    enum Message: Equatable {
        case deletion
        case insertion([FeedImage], Date)
    }
    
    func deleteCachedFeed(completion: @escaping (Result<Void, Error>) -> Void) {
        messages.append(.deletion)
        deletionCompletions.append(completion)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](.failure(error))
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](.success(()))
    }
    
    func insert(_ feed: [FeedImage], timestamp: Date, completion: @escaping (Result<Void, Error>) -> Void) {
        messages.append(.insertion(feed, timestamp))
        insertionCompletions.append(completion)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](.success(()))
    }
}

final class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStore() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()
        let feed = [uniqueItem()]
        
        sut.save(feed) { _ in }
        
        XCTAssertEqual(store.messages, [.deletion])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let feed = [uniqueItem()]
        let deletionError = anyNSError()
        
        sut.save(feed) { _ in }
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.messages, [.deletion])
    }
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let feed = [uniqueItem()]
        
        sut.save(feed) { _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.messages, [.deletion, .insertion(feed, timestamp)])
    }
    
    func test_save_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        let feed = [uniqueItem()]
        let deletionError = anyNSError()
        
        let exp = expectation(description: "Wait for save completion")
        sut.save(feed) { result in
            switch result {
            case .success:
                XCTFail("Expect a failure, succeeded instead")
            case let .failure(error):
                XCTAssertEqual(error as NSError, deletionError)
            }
            exp.fulfill()
        }
        store.completeDeletion(with: deletionError)
        wait(for: [exp], timeout: 1)
    }
    
    func test_save_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let feed = [uniqueItem()]
        let insertionError = anyNSError()
        
        let exp = expectation(description: "Wait for save completion")
        sut.save(feed) { result in
            switch result {
            case .success:
                XCTFail("Expect a failure, succeeded instead")
            case let .failure(error):
                XCTAssertEqual(error as NSError, insertionError)
            }
            exp.fulfill()
        }
        store.completeDeletionSuccessfully()
        store.completeInsertion(with: insertionError)
        wait(for: [exp], timeout: 1)
    }
    
    func test_save_succeedsOnSuccessfulCacheInsertion() {
        let (sut, store) = makeSUT()
        let feed = [uniqueItem()]
        
        let exp = expectation(description: "Wait for save completion")
        sut.save(feed) { result in
            switch result {
            case .success:
                break
            case .failure:
                XCTFail("Expect a success, failed instead")
            }
            exp.fulfill()
        }
        store.completeDeletionSuccessfully()
        store.completeInsertionSuccessfully()
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func uniqueItem() -> FeedImage {
        .init(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        URL(string: "https://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any", code: 0)
    }
}
