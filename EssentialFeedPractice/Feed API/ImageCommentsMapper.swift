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
    
    static func map(_ data: Data, response: HTTPURLResponse) throws -> [RemoteFeedImage] {
        guard isOK(response), let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteImageCommentsLoader.Error.invalidData
        }
        
        return root.items
    }
    
    private static func isOK(_ response: HTTPURLResponse) -> Bool {
        (200...299).contains(response.statusCode)
    }
}
