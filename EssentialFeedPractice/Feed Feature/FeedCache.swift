//
//  FeedCache.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 12/10/2023.
//

import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}
