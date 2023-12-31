//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 14/09/2023.
//

import XCTest
import CoreData
import EssentialFeedPractice

final class CoreDataFeedStoreTests: XCTestCase, FailableFeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversFoundValueOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveDeliversFoundValueOnNonEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let stub = NSManagedObjectContext.alwaysFailingFetchStub()
        stub.startIntercepting()
        let sut = makeSUT()
        
        assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnRetrievalError() {
        let stub = NSManagedObjectContext.alwaysFailingFetchStub()
        stub.startIntercepting()
        let sut = makeSUT()
        
        assertThatRetrieveHasNoSideEffectsOnRetrievalError(on: sut)
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValue() {
        let sut = makeSUT()
        
        assertThatInsertOverridesPreviouslyInsertedCacheValue(on: sut)
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let stub = NSManagedObjectContext.alwaysFailingSaveStub()
        stub.startIntercepting()
        let sut = makeSUT()
        
        assertThatInsertDeliversErrorOnInsertionError(on: sut)
    }
    
    func test_insert_hasNoSideEffectsOnInsertionError() {
        let stub = NSManagedObjectContext.alwaysFailingSaveStub()
        stub.startIntercepting()
        let sut = makeSUT()
        
        assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        
        assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let stub = NSManagedObjectContext.alwaysFailingSaveStub()
        let sut = makeSUT()
        insert((uniqueFeed().locals, Date()), into: sut)
        stub.startIntercepting()
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNotNil(deletionError)
    }
    
    func test_delete_hasNoSideEffectsOnDeletionError() {
        let stub = NSManagedObjectContext.alwaysFailingSaveStub()
        let sut = makeSUT()
        let feed = uniqueFeed().locals
        let timestamp = Date()
        insert((feed, timestamp), into: sut)
        stub.startIntercepting()
        
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .success((feed, timestamp)))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let sut = try! CoreDataFeedStore(storeURL: URL(filePath: "/dev/null"))
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}

private extension NSManagedObjectContext {
    static func alwaysFailingFetchStub() -> Stub {
        Stub(methodPairs: [
            .init(
                source: #selector(NSManagedObjectContext.execute(_:)),
                destination: #selector(Stub.execute(_:))
            )
        ])
    }
    
    static func alwaysFailingSaveStub() -> Stub {
        Stub(methodPairs: [
            .init(
                source: #selector(NSManagedObjectContext.save),
                destination: #selector(Stub.save)
            )
        ])
    }
    
    class Stub: MethodSwizzlingStub<NSManagedObjectContext> {
        @objc func execute(_: Any) throws {
            throw anyNSError()
        }
        
        @objc func save() throws {
            throw anyNSError()
        }
    }
}
