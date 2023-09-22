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
    
    private let loader: FeedLoader
    
    public init(loader: FeedLoader) {
        self.loader = loader
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { nil }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        tableView.register(FeedImageCell.self, forCellReuseIdentifier: "cell")
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.models = feed
            case .failure:
                break
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
        return cell
    }
}
