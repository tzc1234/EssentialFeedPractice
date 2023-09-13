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
    
    private let storeURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appending(path: "image-feed.store")
    
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
        
        let storeURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appending(path: "image-feed.store")
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    override func tearDown() {
        super.tearDown()
        
        let storeURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appending(path: "image-feed.store")
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "Wait for cache retrieval")
        sut.retrieve { result in
            switch result {
            case .success(.none):
                break
            default:
                XCTFail("Expect an empty result")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    func test_retrieve_hasNoSideEffectOnEmptyCache() {
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "Wait for cache retrieval")
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.success(.none), .success(.none)):
                    break
                default:
                    XCTFail("Expect both are empty result, got \(firstResult) and \(secondResult) instead")
                }
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1)
    }
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValue() {
        let sut = CodableFeedStore()
        let feed = uniqueFeed().locals
        let timestamp = Date()
        
        let exp = expectation(description: "Wait for cache retrieval")
        sut.insert(feed, timestamp: timestamp) { insertResult in
            if case let .failure(error) = insertResult {
                XCTAssertNil(error)
            }
            
            sut.retrieve { retrieveResult in
                switch retrieveResult {
                case let .success(.some(receivedCache)):
                    XCTAssertEqual(receivedCache.feed, feed)
                    XCTAssertEqual(receivedCache.timestamp, timestamp)
                default:
                    XCTFail("Expect feed: \(feed) and timestamp: \(timestamp), got \(retrieveResult) instead")
                }
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1)
    }
}
