//
//  RemoteItemsMapper.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 24/10/2023.
//

import Foundation

enum RemoteItemsMapper {
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
    
    static func map(_ data: Data, response: HTTPURLResponse) throws -> [FeedImage] {
        guard response.statusCode == okCode, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteLoader.Error.invalidData
        }
        
        return root.images
    }
    
    private static let okCode = 200
}
