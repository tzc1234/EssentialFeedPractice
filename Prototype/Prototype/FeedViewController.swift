//
//  FeedViewController.swift
//  Prototype
//
//  Created by Tsz-Lung on 20/09/2023.
//

import UIKit

struct FeedImageViewModel {
    let description: String?
    let location: String?
    let imageName: String
}

class FeedViewController: UITableViewController {
    private lazy var refresh: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refresh
    }()
    
    private var feed = [FeedImageViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Feed"
        configureTable()
        handleRefresh()
    }
    
    private func configureTable() {
        tableView.refreshControl = refresh
        tableView.register(FeedImageCell.self, forCellReuseIdentifier: "FeedImageCell")
        tableView.separatorStyle = .none
        tableView.tableHeaderView = .init(frame: CGRect(x: 0, y: 0, width: 0, height: 16))
        tableView.tableFooterView = .init(frame: CGRect(x: 0, y: 0, width: 0, height: 16))
    }
    
    @objc private func handleRefresh() {
        refreshControl?.beginRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if self.feed.isEmpty {
                self.feed = FeedImageViewModel.prototypeFeed
                self.tableView.reloadData()
            }
            self.refreshControl?.endRefreshing()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        feed.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageCell") as! FeedImageCell
        cell.configure(feed[indexPath.row])
        return cell
    }
}

extension FeedImageCell {
    func configure(_ model: FeedImageViewModel) {
        descriptionLabel.text = model.description
        descriptionLabel.isHidden = model.description == nil
        locationLabel.text = model.location
        locationContainer.isHidden = model.location == nil
        feedImageView.image = UIImage(named: model.imageName)
        
        fadeIn(UIImage(named: model.imageName))
    }
}
