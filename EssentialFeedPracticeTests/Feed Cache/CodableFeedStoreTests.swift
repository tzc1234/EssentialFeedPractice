//
//  CodableFeedStoreTests.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 13/09/2023.
//

import XCTest
import EssentialFeedPractice

class CodableFeedStore {
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            feed.map(\.local)
        }
    }
    
    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let imageURL: URL
        
        init(_ model: LocalFeedImage) {
            self.id = model.id
            self.description = model.description
            self.location = model.location
            self.imageURL = model.imageURL
        }
        
        var local: LocalFeedImage {
            .init(id: id, description: description, location: location, imageURL: imageURL)
        }
    }
    
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func retrieve(completion: @escaping FeedStore.RetrieveCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            completion(.success(.none))
            return
        }
        
        let decoded = try! JSONDecoder().decode(Cache.self, from: data)
        completion(.success(.some((decoded.localFeed, decoded.timestamp))))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertCompletion) {
        let encoded = try! JSONEncoder().encode(Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp))
        try! encoded.write(to: storeURL)
        completion(.success(()))
    }
}

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
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValue() {
        let sut = makeSUT()
        let feed = uniqueFeed().locals
        let timestamp = Date()
        
        insert((feed, timestamp), into: sut)
        
        expect(sut, toRetrieve: .success(.some((feed, timestamp))))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueFeed().locals
        let timestamp = Date()
        
        insert((feed, timestamp), into: sut)
        
        expect(sut, toRetrieveTwice: .success(.some((feed, timestamp))))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), into sut: CodableFeedStore,
                        file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache insertion")
        sut.insert(cache.feed, timestamp: cache.timestamp) { result in
            switch result {
            case .success:
                break
            case .failure:
                XCTFail("Expect a success", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    private func expect(_ sut: CodableFeedStore,
                        toRetrieveTwice expectedResult: Result<FeedStore.CachedFeed?, Error>,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    private func expect(_ sut: CodableFeedStore,
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
