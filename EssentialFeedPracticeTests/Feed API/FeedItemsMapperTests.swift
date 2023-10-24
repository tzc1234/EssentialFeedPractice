//
//  FeedItemsMapperTests.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 18/09/2023.
//

import XCTest
import EssentialFeedPractice

final class FeedItemsMapperTests: XCTestCase {
    func test_map_throwsErrorOnNon200Response() throws {
        let json = makeJSONData([])
        let simple = [100, 199, 201, 300, 400, 500]
        
        try simple.forEach { statusCode in
            XCTAssertThrowsError(
                try FeedItemsMapper.map(json, from: HTTPURLResponse(statusCode: statusCode)),
                "Expect an error throws on status code \(statusCode)")
        }
    }
    
    func test_map_throwsErrorOn200ResponseWithInvalidJSON() throws {
        let invalidJSON = Data("invalid json".utf8)
        
        XCTAssertThrowsError(
            try FeedItemsMapper.map(invalidJSON, from: HTTPURLResponse(statusCode: 200)),
            "Expect an error throws on invalid json"
        )
    }
    
    func test_map_deliversEmptyFeedOn200ResponseWithEmptyItemsJSON() throws {
        let emptyItemsJSON = makeJSONData([])
        
        let result = try FeedItemsMapper.map(emptyItemsJSON, from: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, [])
    }
    
    func test_map_deliversOneFeedImageOn200ResponseWithOneItemJSON() throws {
        let items = [makeFeedItem(url: URL(string: "https://an-url.com")!)]
        let feed = items.map(\.model)
        let oneItemJSON = makeJSONData(items.map(\.json))
        
        let result = try FeedItemsMapper.map(oneItemJSON, from: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, feed)
    }
    
    func test_map_deliversFeedOn200ResponseWithMultipleItemsJSON() throws {
        let items = [
            makeFeedItem(url: URL(string: "https://an-url.com")!),
            makeFeedItem(
                description: "an description",
                location: "a location",
                url: URL(string: "https://another-url.com")!)
        ]
        let feed = items.map(\.model)
        let itemsJSON = makeJSONData(items.map(\.json))
        
        let result = try FeedItemsMapper.map(itemsJSON, from: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, feed)
    }
    
    // MARK: - Helpers
    
    private func makeFeedItem(id: UUID = UUID(),
                              description: String? = nil,
                              location: String? = nil,
                              url: URL) -> (model: FeedImage, json: [String: Any]) {
        let image = FeedImage(id: id, description: description, location: location, url: url)
        let json: [String: Any] = [
            "id": image.id.uuidString,
            "description": image.description,
            "location": image.location,
            "image": image.url.absoluteString
        ].compactMapValues { $0 }
        return (image, json)
    }
    
    private func makeJSONData(_ items: [[String: Any]]) -> Data {
        let json: [String: Any] = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
}
