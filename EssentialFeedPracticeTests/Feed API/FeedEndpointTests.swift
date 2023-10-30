//
//  FeedEndpointTests.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 30/10/2023.
//

import XCTest
import EssentialFeedPractice

final class FeedEndpointTests: XCTestCase {
    func test_feed_endpointURL() {
        let baseURL = URL(string: "https://base-url.com")!
        
        let received = FeedEndpoint.get.url(baseURL: baseURL)
        let expected = URL(string: "https://base-url.com/v1/feed")
        
        XCTAssertEqual(received, expected)
    }
}
