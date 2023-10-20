//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeedPracticeiOS
//
//  Created by Tsz-Lung on 28/09/2023.
//

import Combine
import EssentialFeedPractice
import EssentialFeedPracticeiOS

final class FeedLoaderPresentationAdapter {
    var presenter: FeedPresenter?
    private var cancellable: AnyCancellable?
    
    private let feedLoader: () -> FeedLoader.Publisher
    
    init(feedLoader: @escaping () -> FeedLoader.Publisher) {
        self.feedLoader = feedLoader
    }
}

extension FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        cancellable = feedLoader()
            .dispatchOnMainQueue()
            .sink { [weak presenter] completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    presenter?.didFinishLoadingFeed(with: error)
                }
            } receiveValue: { [weak presenter] feed in
                presenter?.didFinishLoadingFeed(with: feed)
            }
    }
}
