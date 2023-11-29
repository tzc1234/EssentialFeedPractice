//
//  FeedCache.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 12/10/2023.
//

import Foundation

public protocol FeedCache {
    func save(_ feed: [FeedImage]) throws
}
