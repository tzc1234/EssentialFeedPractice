//
//  RemoteFeedItemsMapper.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 18/09/2023.
//

import Foundation

enum RemoteFeedItemsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedImage]
        
        var feed: [FeedImage] {
            items.map(\.feedImage)
        }
    }
    
    private struct RemoteFeedImage: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var feedImage: FeedImage {
            FeedImage(id: id, description: description, location: location, url: image)
        }
    }
    
    static func map(_ data: Data, response: HTTPURLResponse) throws -> [FeedImage] {
        guard response.statusCode == okCode, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.feed
    }
    
    private static let okCode = 200
}
