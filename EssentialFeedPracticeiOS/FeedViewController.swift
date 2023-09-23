//
//  FeedViewController.swift
//  EssentialFeedPracticeiOS
//
//  Created by Tsz-Lung on 22/09/2023.
//

import UIKit
import EssentialFeedPractice

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func loadImage(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private lazy var _refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(load), for: .valueChanged)
        return refresh
    }()
    
    private var models = [FeedImage]() {
        didSet {
            tableView.reloadData()
        }
    }
    private var imageLoaderTask = [IndexPath: FeedImageDataLoaderTask]()
    
    private let feedLoader: FeedLoader
    private let imageLoader: FeedImageDataLoader
    
    public init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
        self.feedLoader = feedLoader
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { nil }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = _refreshControl
        configureTableView()
    }
    
    private func configureTableView() {
        tableView.register(FeedImageCell.self, forCellReuseIdentifier: "cell")
        tableView.prefetchDataSource = self
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.models = feed
            }
            self?.refreshControl?.endRefreshing()
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! FeedImageCell
        let model = models[indexPath.row]
        cell.locationContainer.isHidden = (model.location == nil)
        cell.locationLabel.text = model.location
        cell.descriptionLabel.isHidden = (model.description == nil)
        cell.descriptionLabel.text = model.description
        cell.feedImageView.image = nil
        cell.feedImageRetryButton.isHidden = true
        
        cell.feedImageContainer.isShimmering = true
        let loadImage = { [weak self] in
            guard let self else { return }
            
            self.startTask(for: cell, at: indexPath)
        }
        
        cell.onRetry = loadImage
        loadImage()
        
        return cell
    }
    
    private func startTask(for cell: FeedImageCell, at indexPath: IndexPath) {
        let url = models[indexPath.row].url
        imageLoaderTask[indexPath] = imageLoader.loadImage(from: url) { [weak cell] result in
            let data = try? result.get()
            let image = data.map(UIImage.init) ?? nil
            cell?.feedImageView.image = image
            cell?.feedImageRetryButton.isHidden = image != nil
            cell?.feedImageContainer.isShimmering = false
        }
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelTask(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let model = models[indexPath.row]
            imageLoaderTask[indexPath] = imageLoader.loadImage(from: model.url) { _ in }
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelTask)
    }
    
    private func cancelTask(forRowAt indexPath: IndexPath) {
        imageLoaderTask[indexPath]?.cancel()
        imageLoaderTask[indexPath] = nil
    }
}
