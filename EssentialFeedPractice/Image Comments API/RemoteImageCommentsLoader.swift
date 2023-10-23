//
//  RemoteImageCommentsLoader.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 23/10/2023.
//

import Foundation

public final class RemoteImageCommentsLoader {
    private let client: HTTPClient
    private let url: URL
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = Swift.Result<[ImageComment], Swift.Error>
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success((data, response)):
                completion(Result {
                    try ImageCommentsMapper.map(data, response: response)
                })
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}
