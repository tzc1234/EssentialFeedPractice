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
    }
    
    private static let okCode = 200
    
    static func map(_ data: Data, response: HTTPURLResponse) throws -> [RemoteFeedImage] {
        guard response.statusCode == okCode, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.items
    }
}
