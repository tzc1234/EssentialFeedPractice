//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 14/09/2023.
//

import XCTest
import EssentialFeedPractice

extension FeedStoreSpecs where Self: XCTestCase {
    // MARK: - Retrieve
    
    func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore,
                                                     file: StaticString = #filePath,
                                                     line: UInt = #line) {
        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStore,
                                                        file: StaticString = #filePath,
                                                        line: UInt = #line) {
        expect(sut, toRetrieveTwice: .success(.none), file: file, line: line)
    }
    
    func assertThatRetrieveDeliversFoundValueOnNonEmptyCache(on sut: FeedStore,
                                                             file: StaticString = #filePath,
                                                             line: UInt = #line) {
        let feed = uniqueFeed().locals
        let timestamp = Date()
        
        insert((feed, timestamp), into: sut)
        
        expect(sut, toRetrieve: .success((feed, timestamp)), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore,
                                                           file: StaticString = #filePath,
                                                           line: UInt = #line) {
        let feed = uniqueFeed().locals
        let timestamp = Date()
        
        insert((feed, timestamp), into: sut)
        
        expect(sut, toRetrieveTwice: .success((feed, timestamp)), file: file, line: line)
    }
    
    // MARK: - Insert
    
    func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore,
                                                     file: StaticString = #filePath,
                                                     line: UInt = #line) {
        let insertionError = insert((uniqueFeed().locals, Date()), into: sut)
        
        XCTAssertNil(insertionError, file: file, line: line)
    }
    
    func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: FeedStore,
                                                        file: StaticString = #filePath,
                                                        line: UInt = #line) {
        insert((uniqueFeed().locals, Date()), into: sut)
        
        let insertionError = insert((uniqueFeed().locals, Date()), into: sut)
        
        XCTAssertNil(insertionError, file: file, line: line)
    }
    
    func assertThatInsertOverridesPreviouslyInsertedCacheValue(on sut: FeedStore,
                                                               file: StaticString = #filePath,
                                                               line: UInt = #line) {
        insert((uniqueFeed().locals, Date()), into: sut)
        
        let latestFeed = uniqueFeed().locals
        let latestTimestamp = Date()
        insert((latestFeed, latestTimestamp), into: sut)
        
        expect(sut, toRetrieve: .success((latestFeed, latestTimestamp)), file: file, line: line)
    }
    
    // MARK: - Delete
    
    func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore,
                                                     file: StaticString = #filePath,
                                                     line: UInt = #line) {
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, file: file, line: line)
    }
    
    func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore,
                                                      file: StaticString = #filePath,
                                                      line: UInt = #line) {
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }
    
    func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore,
                                                        file: StaticString = #filePath,
                                                        line: UInt = #line) {
        insert((uniqueFeed().locals, Date()), into: sut)
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, file: file, line: line)
    }
    
    func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore,
                                                        file: StaticString = #filePath,
                                                        line: UInt = #line) {
        insert((uniqueFeed().locals, Date()), into: sut)
        
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }
    
    // MARK: - Helpers
    
    @discardableResult
    func deleteCache(from sut: FeedStore) -> Error? {
        do {
            try sut.deleteCachedFeed()
            return nil
        } catch {
            return error
        }
    }
    
    @discardableResult
    func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), into sut: FeedStore) -> Error? {
        do {
            try sut.insert(cache.feed, timestamp: cache.timestamp)
            return nil
        } catch {
            return error
        }
    }
    
    func expect(_ sut: FeedStore,
                toRetrieveTwice expectedResult: Result<FeedStore.CachedFeed?, Error>,
                file: StaticString = #filePath,
                line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    func expect(_ sut: FeedStore,
                toRetrieve expectedResult: Result<FeedStore.CachedFeed?, Error>,
                file: StaticString = #filePath,
                line: UInt = #line) {
        let receivedResult = Result { try sut.retrieve() }
    
        switch (receivedResult, expectedResult) {
        case (.success(.none), .success(.none)), (.failure, .failure):
            break
        case let (.success(.some(receivedCache)), .success(.some(expectedCache))):
            XCTAssertEqual(receivedCache.feed, expectedCache.feed, file: file, line: line)
            XCTAssertEqual(receivedCache.timestamp, expectedCache.timestamp, file: file, line: line)
        default:
            XCTFail("Expect \(expectedResult), got \(receivedResult) instead", file: file, line: line)
        }
    }
}
