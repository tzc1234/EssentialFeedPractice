//
//  ImageCommentsMapperTests.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 23/10/2023.
//

import XCTest
import EssentialFeedPractice

final class ImageCommentsMapperTests: XCTestCase {
    func test_map_throwsInvalidDataErrorOnNon2xxResponse() throws {
        let json = makeJSONData([])
        let simple = [100, 199, 300, 400, 500]
        
        try simple.forEach { statusCode in
            XCTAssertThrowsError(
                try ImageCommentsMapper.map(json, from: HTTPURLResponse(statusCode: statusCode)),
                "Expect an error throws on status code \(statusCode)"
            )
        }
    }
    
    func test_map_throwsInvalidDataErrorOn2xxHTTPResponseWithInvalidJSON() throws {
        let invalidJSON = Data("invalid data".utf8)
        let simple = [200, 201, 250, 280, 299]
        
        try simple.forEach { statusCode in
            XCTAssertThrowsError(
                try ImageCommentsMapper.map(invalidJSON, from: HTTPURLResponse(statusCode: statusCode)),
                "Expect an error throws on status code \(statusCode)"
            )
        }
    }
    
    func test_map_deliversEmptyFeedOn2xxResponseWithEmptyJSONList() throws {
        let emptyItemsJSON = makeJSONData([])
        let simple = [200, 201, 250, 280, 299]
        
        try simple.forEach { statusCode in
            let result = try ImageCommentsMapper.map(emptyItemsJSON, from: HTTPURLResponse(statusCode: statusCode))
            
            XCTAssertEqual(result, [])
        }
    }
    
    func test_map_deliversOneFeedImageOn2xxResponseWithOneItemJSON() throws {
        let items = [
            makeItem(
                message: "a message",
                createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
                username: "a username"
            )
        ]
        let oneItemJSON = makeJSONData(items.map(\.json))
        let imageComments = items.map(\.model)
        let simple = [200, 201, 250, 280, 299]
        
        try simple.forEach { statusCode in
            let result = try ImageCommentsMapper.map(oneItemJSON, from: HTTPURLResponse(statusCode: statusCode))
            
            XCTAssertEqual(result, imageComments)
        }
    }
    
    func test_map_deliversFeedOn2xxResponseWithMultipleItemsJSON() throws {
        let items = [
            makeItem(
                message: "a message",
                createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
                username: "a username"
            ),
            makeItem(
                message: "another message",
                createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
                username: "another username"
            )
        ]
        let itemsJSON = makeJSONData(items.map(\.json))
        let imageComments = items.map(\.model)
        let simple = [200, 201, 250, 280, 299]
        
        try simple.forEach { statusCode in
            let result = try ImageCommentsMapper.map(itemsJSON, from: HTTPURLResponse(statusCode: statusCode))
            
            XCTAssertEqual(result, imageComments)
        }
    }
    
    // MARK: - Helpers
    
    private func makeItem(id: UUID = UUID(),
                          message: String,
                          createdAt: (date: Date, iso8601String: String),
                          username: String) -> (model: ImageComment, json: [String: Any]) {
        let model = ImageComment(id: id, message: message, createdAt: createdAt.date, username: username)
        let json: [String: Any] = [
            "id": id.uuidString,
            "message": message,
            "created_at": createdAt.iso8601String,
            "author": [
                "username": username
            ]
        ]
        return (model, json)
    }
}
