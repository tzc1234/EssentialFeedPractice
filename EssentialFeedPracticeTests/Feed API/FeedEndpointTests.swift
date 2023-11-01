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
        
        XCTAssertEqual(received.scheme, "https", "scheme")
        XCTAssertEqual(received.host(), "base-url.com", "host")
        XCTAssertEqual(received.path(), "/v1/feed", "path")
        let query = received.query() ?? ""
        XCTAssertTrue(query.contains("limit=10"), "query")
    }
}
