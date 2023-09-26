//
//  FeedViewModel.swift
//  EssentialFeedPracticeiOS
//
//  Created by Tsz-Lung on 26/09/2023.
//

import Foundation
import EssentialFeedPractice

final class FeedViewModel {
    typealias Observer<T> = (T) -> Void
    
    var onLoading: Observer<Bool>?
    var onFeedLoad: Observer<[FeedImage]>?
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func loadFeed() {
        onLoading?(true)
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.onLoading?(false)
        }
    }
}
