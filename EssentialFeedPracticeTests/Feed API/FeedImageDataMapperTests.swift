//
//  FeedImageDataMapperTests.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 06/10/2023.
//

import XCTest
import EssentialFeedPractice

final class FeedImageDataMapperTests: XCTestCase {
    func test_map_throwsErrorOnNon200HTTPResponse() throws {
        let simple = [199, 201, 300, 400, 500]
        
        try simple.forEach { code in
            XCTAssertThrowsError(
                try FeedImageDataMapper.map(anyData(), from: HTTPURLResponse(statusCode: code)),
                "Expect an error throws on status code \(code)"
            )
        }
    }
    
    func test_map_throwsErrorOn200HTTPResponseWithEmptyData() {
        let emptyData = Data()
        
        XCTAssertThrowsError(try FeedImageDataMapper.map(emptyData, from: HTTPURLResponse(statusCode: 200)))
    }
    
    func test_map_deliversDataOn200HTTPResponse() throws {
        let validData = Data("valid data".utf8)
        
        let result = try FeedImageDataMapper.map(validData, from: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, validData)
    }
}
