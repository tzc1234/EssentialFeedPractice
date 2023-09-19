//
//  EssentialFeedPracticeAPIEndToEndTests.swift
//  EssentialFeedPracticeAPIEndToEndTests
//
//  Created by Tsz-Lung on 19/09/2023.
//

import XCTest
import EssentialFeedPractice

final class EssentialFeedPracticeAPIEndToEndTests: XCTestCase {
    func test_endToEndTestServerGETFeedResult_matchesFixedTestAccountData() {
        switch getFeedResult() {
        case let .success(feed):
            XCTAssertEqual(feed.count, 8, "Expect 8 items in the test account feed")
            XCTAssertEqual(feed[0], expectImage(at: 0))
            XCTAssertEqual(feed[1], expectImage(at: 1))
            XCTAssertEqual(feed[2], expectImage(at: 2))
            XCTAssertEqual(feed[3], expectImage(at: 3))
            XCTAssertEqual(feed[4], expectImage(at: 4))
            XCTAssertEqual(feed[5], expectImage(at: 5))
            XCTAssertEqual(feed[6], expectImage(at: 6))
            XCTAssertEqual(feed[7], expectImage(at: 7))
        case let .failure(error):
            XCTFail("Expect a success, got \(error) instead")
        default:
            XCTFail("Expect a received result, got nil instead")
        }
    }
    
    // MARK: - Helpers
    
    private func getFeedResult(file: StaticString = #filePath, line: UInt = #line) -> FeedLoader.Result? {
        let client = URLSessionHTTPClient()
        let loader = RemoteFeedLoader(client: client, url: testServerURL())
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
        let exp = expectation(description: "Wait for completion")
        var receivedResult: FeedLoader.Result?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10)
        return receivedResult
    }
    
    private func testServerURL() -> URL {
        URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
    }
    
    private func expectImage(at index: Int) -> FeedImage {
        FeedImage(
            id: id(at: index),
            description: description(at: index),
            location: location(at: index),
            url: imageURL(at: index))
    }
    
    private func id(at index: Int) -> UUID {
        UUID(uuidString: [
            "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6",
            "BA298A85-6275-48D3-8315-9C8F7C1CD109",
            "5A0D45B3-8E26-4385-8C5D-213E160A5E3C",
            "FF0ECFE2-2879-403F-8DBE-A83B4010B340",
            "DC97EF5E-2CC9-4905-A8AD-3C351C311001",
            "557D87F1-25D3-4D77-82E9-364B2ED9CB30",
            "A83284EF-C2DF-415D-AB73-2A9B8B04950B",
            "F79BD7F8-063F-46E2-8147-A67635C3BB01"
        ][index])!
    }
    
    private func description(at index: Int) -> String? {
        [
            "Description 1",
            nil,
            "Description 3",
            nil,
            "Description 5",
            "Description 6",
            "Description 7",
            "Description 8"
        ][index]
    }
    
    private func location(at index: Int) -> String? {
        [
            "Location 1",
            "Location 2",
            nil,
            nil,
            "Location 5",
            "Location 6",
            "Location 7",
            "Location 8"
        ][index]
    }
    
    private func imageURL(at index: Int) -> URL {
        URL(string: "https://url-\(index+1).com")!
    }
}
