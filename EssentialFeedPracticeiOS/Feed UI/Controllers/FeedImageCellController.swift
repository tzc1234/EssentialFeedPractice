//
//  FeedImageCellController.swift
//  EssentialFeedPracticeiOS
//
//  Created by Tsz-Lung on 25/09/2023.
//

import UIKit
import EssentialFeedPractice

final class FeedImageCellController {
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
    
    func startTask(for cell: UITableViewCell? = nil) {
        if let cell, isTheSameCellAlreadyReferencing(cell) {
            return
        }
        
        self.cell?.feedImageView.image = nil
        self.cell?.feedImageRetryButton.isHidden = true
        self.cell?.feedImageContainer.isShimmering = true
        
        task = imageLoader.loadImage(from: model.url) { [weak self] result in
            let data = try? result.get()
            let image = data.map(UIImage.init) ?? nil
            self?.cell?.feedImageView.image = image
            self?.cell?.feedImageRetryButton.isHidden = image != nil
            self?.cell?.feedImageContainer.isShimmering = false
        }
    }
    
    private func isTheSameCellAlreadyReferencing(_ cell: UITableViewCell) -> Bool {
        self.cell === cell
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
