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
    private var feed = FeedImageViewModel.prototypeFeed
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Feed"
        configureTable()
    }
    
    func configureTable() {
        tableView.register(FeedImageCell.self, forCellReuseIdentifier: "FeedImageCell")
        tableView.separatorStyle = .none
        tableView.tableHeaderView = .init(frame: CGRect(x: 0, y: 0, width: 0, height: 16))
        tableView.tableFooterView = .init(frame: CGRect(x: 0, y: 0, width: 0, height: 16))
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
        locationLabel.text = model.location
        feedImageView.image = UIImage(named: model.imageName)
    }
}
