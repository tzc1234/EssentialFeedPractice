//
//  FeedImageCellController.swift
//  EssentialFeedPracticeiOS
//
//  Created by Tsz-Lung on 25/09/2023.
//

import UIKit

final class FeedImageCellController {
    static let cellClass: AnyClass = FeedImageCell.self
    static let cellIdentifier = FeedImageCell.identifier
    
    private var cell: FeedImageCell?
    
    private let viewModel: FeedImageViewModel<UIImage>
    
    init(viewModel: FeedImageViewModel<UIImage>) {
        self.viewModel = viewModel
    }
    
    func view(for tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier) as! FeedImageCell
        configure(cell)
        setupBindings()
        
        cell.onRetry = { [weak self] in
            self?.startImageDataLoad()
        }
        startImageDataLoad()
        
        return cell
    }
    
    private func setupBindings() {
        viewModel.onLoading = { [weak self] isLoading in
            self?.cell?.feedImageContainer.isShimmering = isLoading
        }
        
        viewModel.onImageLoad = { [weak self] image in
            self?.cell?.feedImageView.image = image
        }
        
        viewModel.onShouldRetryImageLoad = { [weak self] shouldRetry in
            self?.cell?.feedImageRetryButton.isHidden = !shouldRetry
        }
    }
    
    func startImageDataLoad(for cell: UITableViewCell) {
        if isAlreadyReferencingTheSame(cell) && viewModel.isImageDataTaskExisted {
            return
        }
        
        if let cell = cell as? FeedImageCell {
            configure(cell)
        }
        
        startImageDataLoad()
    }
    
    private func isAlreadyReferencingTheSame(_ cell: UITableViewCell) -> Bool {
        self.cell === cell
    }
    
    private func configure(_ cell: FeedImageCell) {
        self.cell = cell
        cell.locationContainer.isHidden = (viewModel.location == nil)
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.isHidden = (viewModel.description == nil)
        cell.descriptionLabel.text = viewModel.description
    }
    
    private func startImageDataLoad() {
        viewModel.loadImageData()
    }
    
    func preLoad() {
        viewModel.loadImageData()
    }
    
    deinit {
        cancelImageDataLoad()
    }
    
    func cancelImageDataLoad() {
        viewModel.cancelImageDataLoad()
    }
}
