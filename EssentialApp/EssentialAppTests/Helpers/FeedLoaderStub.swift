//
//  FeedLoaderStub.swift
//  EssentialAppTests
//
//  Created by Tsz-Lung on 12/10/2023.
//

import EssentialFeedPractice

final class FeedLoaderStub: FeedLoader {
    private let result: FeedLoader.Result
    
    init(result: FeedLoader.Result) {
        self.result = result
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(result)
    }
}
