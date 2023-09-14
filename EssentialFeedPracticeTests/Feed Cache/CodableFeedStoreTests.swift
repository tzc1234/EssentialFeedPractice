//
//  CodableFeedStoreTests.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 13/09/2023.
//

import XCTest
import EssentialFeedPractice

final class CodableFeedStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieve: .success(.none))
    }
    
    func test_retrieve_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieveTwice: .success(.none))
    }
    
    func test_retrieve_deliversFoundValueOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueFeed().locals
        let timestamp = Date()
        
        insert((feed, timestamp), into: sut)
        
        expect(sut, toRetrieve: .success((feed, timestamp)))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueFeed().locals
        let timestamp = Date()
        
        insert((feed, timestamp), into: sut)
        
        expect(sut, toRetrieveTwice: .success((feed, timestamp)))
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieve: .failure(anyNSError()))
    }
    
    func test_retrieve_hasNoSideEffectsOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        let insertionError = insert((uniqueFeed().locals, Date()), into: sut)
        
        XCTAssertNil(insertionError)
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        insert((uniqueFeed().locals, Date()), into: sut)
        
        let insertionError = insert((uniqueFeed().locals, Date()), into: sut)
        
        XCTAssertNil(insertionError)
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValue() {
        let sut = makeSUT()
        insert((uniqueFeed().locals, Date()), into: sut)
        
        let latestFeed = uniqueFeed().locals
        let latestTimestamp = Date()
        insert((latestFeed, latestTimestamp), into: sut)
        
        expect(sut, toRetrieve: .success((latestFeed, latestTimestamp)))
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueFeed().locals
        let timestamp = Date()
        
        let insertionError = insert((feed, timestamp), into: sut)
        
        XCTAssertNotNil(insertionError)
    }
    
    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueFeed().locals
        let timestamp = Date()
        
        insert((feed, timestamp), into: sut)
        
        expect(sut, toRetrieve: .success(.none))
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError)
        
        expect(sut, toRetrieve: .success(.none))
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .success(.none))
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        insert((uniqueFeed().locals, Date()), into: sut)
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        insert((uniqueFeed().locals, Date()), into: sut)
        
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .success(.none))
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let stub = FileManager.removeItemAlwaysFailingStub()
        stub.startIntercepting()
        let sut = makeSUT()
        insert((uniqueFeed().locals, Date()), into: sut)
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNotNil(deletionError)
    }
    
    func test_delete_hasNoSideEffectsOnDeletionError() {
        let stub = FileManager.removeItemAlwaysFailingStub()
        stub.startIntercepting()
        let sut = makeSUT()
        let feed = uniqueFeed().locals
        let timestamp = Date()
        insert((feed, timestamp), into: sut)
        
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .success((feed, timestamp)))
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        var completionOperationOrder = [XCTestExpectation]()
        
        let op1 = expectation(description: "Operation 1")
        sut.insert(uniqueFeed().locals, timestamp: .now) { _ in
            completionOperationOrder.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Operation 2")
        sut.deleteCachedFeed { _ in
            completionOperationOrder.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Operation 3")
        sut.insert(uniqueFeed().locals, timestamp: .now) { _ in
            completionOperationOrder.append(op3)
            op3.fulfill()
        }
        
        waitForExpectations(timeout: 5)
        
        XCTAssertEqual(completionOperationOrder, [op1, op2, op3])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(storeURL: URL? = nil,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    @discardableResult
    private func deleteCache(from sut: FeedStore) -> Error? {
        var deletionError: Error?
        let exp = expectation(description: "Wait for deletion")
        sut.deleteCachedFeed { result in
            switch result {
            case .success:
                break
            case let .failure(error):
                deletionError = error
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        return deletionError
    }
    
    @discardableResult
    private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), into sut: FeedStore) -> Error? {
        var retrievalError: Error?
        let exp = expectation(description: "Wait for cache insertion")
        sut.insert(cache.feed, timestamp: cache.timestamp) { result in
            switch result {
            case .success:
                break
            case let .failure(error):
                retrievalError = error
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        return retrievalError
    }
    
    private func expect(_ sut: FeedStore,
                        toRetrieveTwice expectedResult: Result<FeedStore.CachedFeed?, Error>,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    private func expect(_ sut: FeedStore,
                        toRetrieve expectedResult: Result<FeedStore.CachedFeed?, Error>,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
        sut.retrieve { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success(.none), .success(.none)), (.failure, .failure):
                break
            case let (.success(.some(receivedCache)), .success(.some(expectedCache))):
                XCTAssertEqual(receivedCache.feed, expectedCache.feed, file: file, line: line)
                XCTAssertEqual(receivedCache.timestamp, expectedCache.timestamp, file: file, line: line)
            default:
                XCTFail("Expect \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func testSpecificStoreURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            .appending(path: "\(String(describing: self)).store")
    }
}

private extension FileManager {
    static func removeItemAlwaysFailingStub() -> Stub {
        .init(source: #selector(FileManager.removeItem(at:)), destination: #selector(Stub.removeItem))
    }
    
    class Stub: NSObject {
        private let source: Selector
        private let destination: Selector

        init(source: Selector, destination: Selector) {
            self.source = source
            self.destination = destination
        }

        @objc func removeItem(at URL: URL) throws {
            throw anyNSError()
        }

        func startIntercepting() {
            method_exchangeImplementations(
                class_getInstanceMethod(FileManager.self, source)!,
                class_getInstanceMethod(Stub.self, destination)!
            )
        }

        deinit {
            method_exchangeImplementations(
                class_getInstanceMethod(Stub.self, destination)!,
                class_getInstanceMethod(FileManager.self, source)!
            )
        }
    }
}
