//
//  FeedImageCellController.swift
//  EssentialFeedPracticeiOS
//
//  Created by Tsz-Lung on 25/09/2023.
//

import UIKit
import EssentialFeedPractice

final class FeedImageCellController {
    static let cellClass: AnyClass = FeedImageCell.self
    static let cellIdentifier = FeedImageCell.identifier
    
    private var cell: FeedImageCell?
    private var task: FeedImageDataLoaderTask?
    
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func view(for tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FeedImageCell.identifier) as! FeedImageCell
        self.cell = cell
        configureCell(with: model)
        
        cell.onRetry = { [weak self] in
            self?.startTask()
        }
        startTask()
        
        return cell
    }
    
    private func configureCell(with model: FeedImage) {
        cell?.locationContainer.isHidden = (model.location == nil)
        cell?.locationLabel.text = model.location
        cell?.descriptionLabel.isHidden = (model.description == nil)
        cell?.descriptionLabel.text = model.description
    }
    
    func startTask(for cell: UITableViewCell) {
        if isAlreadyReferencingTheSame(cell) {
            return
        }
        
        if let cell = cell as? FeedImageCell {
            self.cell = cell
        }
        
        startTask()
    }
    
    private func isAlreadyReferencingTheSame(_ cell: UITableViewCell) -> Bool {
        self.cell === cell
    }
    
    private func startTask() {
        cell?.feedImageView.image = nil
        cell?.feedImageRetryButton.isHidden = true
        cell?.feedImageContainer.isShimmering = true
        
        task = imageLoader.loadImage(from: model.url) { [weak self] result in
            let data = try? result.get()
            let image = data.map(UIImage.init) ?? nil
            self?.cell?.feedImageView.image = image
            self?.cell?.feedImageRetryButton.isHidden = image != nil
            self?.cell?.feedImageContainer.isShimmering = false
        }
    }
    
    func preLoad() {
        task = imageLoader.loadImage(from: model.url) { _ in }
    }
    
    deinit {
        cancelTask()
    }
    
    private func cancelTask() {
        task?.cancel()
        task = nil
    }
}
