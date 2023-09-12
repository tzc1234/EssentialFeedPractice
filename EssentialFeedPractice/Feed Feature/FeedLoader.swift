//
//  FeedLoader.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 10/09/2023.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    
    func load(completion: @escaping (Result) -> Void)
}
