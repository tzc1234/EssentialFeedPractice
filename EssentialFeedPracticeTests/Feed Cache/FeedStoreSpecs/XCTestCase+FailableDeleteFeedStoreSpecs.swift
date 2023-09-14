//
//  XCTestCase+FailableDeleteFeedStoreSpecs.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 14/09/2023.
//

import XCTest
import EssentialFeedPractice

extension FailableDeleteFeedStoreSpecs where Self: XCTestCase {
    func assertThatDeleteDeliversErrorOnDeletionError(on sut: FeedStore,
                                                      file: StaticString = #filePath,
                                                      line: UInt = #line) {
        insert((uniqueFeed().locals, Date()), into: sut)
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNotNil(deletionError, file: file, line: line)
    }
    
    func assertThatDeleteHasNoSideEffectsOnDeletionError(on sut: FeedStore,
                                                         file: StaticString = #filePath,
                                                         line: UInt = #line) {
        let feed = uniqueFeed().locals
        let timestamp = Date()
        insert((feed, timestamp), into: sut)
        
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .success((feed, timestamp)), file: file, line: line)
    }
}
