//
//  ImageCommentsEndpointTests.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 30/10/2023.
//

import XCTest
import EssentialFeedPractice

final class ImageCommentsEndpointTests: XCTestCase {
    func test_imageComments_endpointURL() {
        let baseURL = URL(string: "https://base-url.com")!
        let uuid = UUID(uuidString: "2239CBA2-CB35-4392-ADC0-24A37D38E010")!
        
        let received = ImageCommentsEndpoint.get(uuid).url(baseURL: baseURL)
        let expected = URL(string: "https://base-url.com/v1/image/2239CBA2-CB35-4392-ADC0-24A37D38E010/comments")!
        
        XCTAssertEqual(received, expected)
    }
}
