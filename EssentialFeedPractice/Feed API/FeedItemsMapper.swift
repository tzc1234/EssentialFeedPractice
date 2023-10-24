//
//  FeedItemsMapper.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 18/09/2023.
//

import Foundation

public enum FeedItemsMapper {
    private struct Root: Decodable {
        private let items: [RemoteFeedImage]
        
        private struct RemoteFeedImage: Decodable {
            let id: UUID
            let description: String?
            let location: String?
            let image: URL
        }
        
        var images: [FeedImage] {
            items.map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image) }
        }
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [FeedImage] {
        guard response.statusCode == okCode, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.images
    }
    
    private static let okCode = 200
}
