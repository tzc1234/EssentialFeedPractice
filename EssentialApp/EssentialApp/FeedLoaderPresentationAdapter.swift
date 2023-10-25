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
    var presenter: LoadResourcePresenter<[FeedImage], FeedViewAdapter>?
    private var cancellable: AnyCancellable?
    
    private let feedLoader: () -> AnyPublisher<[FeedImage], Error>
    
    init(feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>) {
        self.feedLoader = feedLoader
    }
}

extension FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh() {
        presenter?.didStartLoading()
        cancellable = feedLoader()
            .dispatchOnMainQueue()
            .sink { [weak presenter] completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    presenter?.didFinishLoading(with: error)
                }
            } receiveValue: { [weak presenter] feed in
                presenter?.didFinishLoading(with: feed)
            }
    }
}
