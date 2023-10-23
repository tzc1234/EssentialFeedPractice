//
//  RemoteFeedLoader.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 18/09/2023.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
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
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success((data, response)):
                completion(Result {
                    try RemoteFeedItemsMapper.map(data, response: response)
                })
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}
