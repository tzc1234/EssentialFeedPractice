//
//  FeedViewController.swift
//  EssentialFeedPracticeiOS
//
//  Created by Tsz-Lung on 22/09/2023.
//

import UIKit
import EssentialFeedPractice

public final class FeedViewController: UITableViewController {
    private var models = [FeedImage]() {
        didSet {
            tableView.reloadData()
        }
    }
    private var cellControllers = [IndexPath: FeedImageCellController]()
    
    private let refreshController: FeedRefreshViewController
    private let feedLoader: FeedLoader
    private let imageLoader: FeedImageDataLoader
    
    public init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
        self.refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        self.feedLoader = feedLoader
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { nil }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = refreshController.view
        refreshController.onRefresh = { [weak self] feed in
            self?.models = feed
        }
        configureTableView()
    }
    
    private func configureTableView() {
        tableView.register(FeedImageCell.self, forCellReuseIdentifier: FeedImageCell.identifier)
        tableView.prefetchDataSource = self
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        refreshController.refresh()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellController(forRowAt: indexPath).view(for: tableView)
    }
    
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).startTask(for: cell)
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        if let cellControllers = cellControllers[indexPath] {
            return cellControllers
        }
        
        let model = models[indexPath.row]
        let cellController = FeedImageCellController(model: model, imageLoader: imageLoader)
        cellControllers[indexPath] = cellController
        return cellController
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        removeCellController(forRowAt: indexPath)
    }
    
    private func removeCellController(forRowAt indexPath: IndexPath) {
        cellControllers[indexPath] = nil
    }
}

extension FeedViewController: UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { cellController(forRowAt: $0).preLoad() }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(removeCellController)
    }
}
