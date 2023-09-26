//
//  FeedRefreshViewController.swift
//  EssentialFeedPracticeiOS
//
//  Created by Tsz-Lung on 25/09/2023.
//

import UIKit

final class FeedRefreshViewController: NSObject {
    private(set) lazy var view = bound(UIRefreshControl())
    
    private let viewModel: FeedViewModel
    
    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }
    
    private func bound(_ view: UIRefreshControl) -> UIRefreshControl {
        viewModel.onLoading = { [weak view] isLoading in
            if isLoading {
                view?.beginRefreshing()
            } else {
                view?.endRefreshing()
            }
        }
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
    
    @objc func refresh() {
        viewModel.loadFeed()
    }
}
