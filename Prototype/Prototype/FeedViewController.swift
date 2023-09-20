//
//  FeedViewController.swift
//  Prototype
//
//  Created by Tsz-Lung on 20/09/2023.
//

import UIKit

class FeedViewController: UITableViewController {
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
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageCell") as! FeedImageCell
        return cell
    }
}
