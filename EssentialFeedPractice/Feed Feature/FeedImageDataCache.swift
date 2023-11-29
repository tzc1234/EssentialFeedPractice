//
//  FeedImageDataCache.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 12/10/2023.
//

import Foundation

public protocol FeedImageDataCache {
    func save(_ data: Data, for url: URL) throws
}
