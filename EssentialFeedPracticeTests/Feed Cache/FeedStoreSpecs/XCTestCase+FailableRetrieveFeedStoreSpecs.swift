//
//  XCTestCase+FailableRetrieveFeedStoreSpecs.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 14/09/2023.
//

import XCTest
import EssentialFeedPractice

extension FailableRetrieveFeedStoreSpecs where Self: XCTestCase {
    func assertThatRetrieveDeliversFailureOnRetrievalError(on sut: FeedStore,
                                                           file: StaticString = #filePath,
                                                           line: UInt = #line) {
        expect(sut, toRetrieve: .failure(anyNSError()), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectsOnRetrievalError(on sut: FeedStore,
                                                            file: StaticString = #filePath,
                                                            line: UInt = #line) {
        expect(sut, toRetrieveTwice: .failure(anyNSError()), file: file, line: line)
    }
}
