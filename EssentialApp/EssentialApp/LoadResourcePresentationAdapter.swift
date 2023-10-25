//
//  LoadResourcePresentationAdapter.swift
//  EssentialFeedPracticeiOS
//
//  Created by Tsz-Lung on 28/09/2023.
//

import Combine
import EssentialFeedPractice
import EssentialFeedPracticeiOS

final class LoadResourcePresentationAdapter<Resource, View: ResourceView> {
    var presenter: LoadResourcePresenter<Resource, View>?
    private var cancellable: AnyCancellable?
    
    private let loader: () -> AnyPublisher<Resource, Error>
    
    init(loader: @escaping () -> AnyPublisher<Resource, Error>) {
        self.loader = loader
    }
    
    func loadResource() {
        presenter?.didStartLoading()
        cancellable = loader()
            .dispatchOnMainQueue()
            .sink { [weak presenter] completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    presenter?.didFinishLoading(with: error)
                }
            } receiveValue: { [weak presenter] resource in
                presenter?.didFinishLoading(with: resource)
            }
    }
}

extension LoadResourcePresentationAdapter: FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh() {
        loadResource()
    }
}
