//
//  ImageCommentsMapper.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 23/10/2023.
//

import Foundation

enum ImageCommentsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedImage]
    }
    
    private static let okCode = 200
    
    static func map(_ data: Data, response: HTTPURLResponse) throws -> [RemoteFeedImage] {
        guard response.statusCode == okCode, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteImageCommentsLoader.Error.invalidData
        }
        
        return root.items
    }
}
