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
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ feed: [FeedImage]) {
        store.deleteCachedFeed { [weak self] result in
            switch result {
            case .success:
                self?.store.insert(feed)
            case .failure:
                break
            }
        }
    }
}

class FeedStore {
    private(set) var messages = [Message]()
    private var deletionCompletions = [(Result<Void, Error>) -> Void]()
    
    enum Message: Equatable {
        case deletion
        case insertion
    }
    
    func deleteCachedFeed(completion: @escaping (Result<Void, Error>) -> Void) {
        messages.append(.deletion)
        deletionCompletions.append(completion)
    }
    
    func insert(_ feed: [FeedImage]) {
        messages.append(.insertion)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](.failure(error))
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](.success(()))
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
        
        sut.save(feed)
        
        XCTAssertEqual(store.messages, [.deletion])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let feed = [uniqueItem()]
        let deletionError = anyNSError()
        
        sut.save(feed)
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.messages, [.deletion])
    }
    
    func test_save_requestsNewCacheInsertionOnSuccessfulDeletion() {
        let (sut, store) = makeSUT()
        let feed = [uniqueItem()]
        
        sut.save(feed)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.messages, [.deletion, .insertion])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
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
