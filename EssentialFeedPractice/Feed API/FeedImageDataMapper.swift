//
//  FeedImageDataMapper.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 24/10/2023.
//

import Foundation

public enum FeedImageDataMapper {
    public enum Error: Swift.Error {
        case invalidData
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> Data {
        guard isOK(response) && !data.isEmpty else {
            throw Error.invalidData
        }
        
        return data
    }
    
    private static func isOK(_ response: HTTPURLResponse) -> Bool {
        response.statusCode == 200
    }
}
