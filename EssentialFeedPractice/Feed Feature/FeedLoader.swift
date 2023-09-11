//
//  FeedLoader.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 10/09/2023.
//

import Foundation

protocol FeedLoader {
    func load(completion: @escaping (Result<[FeedImage], Error>) -> Void)
}
