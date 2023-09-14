//
//  XCTestCase+FailableInsertFeedStoreSpecs.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 14/09/2023.
//

import XCTest
import EssentialFeedPractice

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
    func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore,
                                                       file: StaticString = #filePath,
                                                       line: UInt = #line) {
        let feed = uniqueFeed().locals
        let timestamp = Date()
        
        let insertionError = insert((feed, timestamp), into: sut)
        
        XCTAssertNotNil(insertionError, file: file, line: line)
    }
    
    func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: FeedStore,
                                                          file: StaticString = #filePath,
                                                          line: UInt = #line) {
        let feed = uniqueFeed().locals
        let timestamp = Date()
        
        insert((feed, timestamp), into: sut)
        
        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }
}
