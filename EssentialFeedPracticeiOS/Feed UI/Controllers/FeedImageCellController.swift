//
//  FeedImageCellController.swift
//  EssentialFeedPracticeiOS
//
//  Created by Tsz-Lung on 25/09/2023.
//

import UIKit

protocol FeedImageCellControllerDelegate {
    var hasNoImageRequest: Bool { get }
    func didRequestImage()
    func didCancelImageRequest()
}

final class FeedImageCellController {
    static let cellClass: AnyClass = FeedImageCell.self
    static let cellIdentifier = FeedImageCell.identifier
    
    private var cell: FeedImageCell?
    
    private let delegate: FeedImageCellControllerDelegate
    
    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func view(for tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier) as! FeedImageCell
        setup(cell)
        startImageDataLoad()
        return cell
    }
    
    func startImageDataLoad(for cell: UITableViewCell) {
        guard shouldStartANewImageDataLoad(for: cell) else {
            return
        }
        
        if let cell = cell as? FeedImageCell {
            setup(cell)
        }
        
        startImageDataLoad()
    }
    
    private func setup(_ cell: FeedImageCell) {
        self.cell = cell
        cell.onRetry = { [weak self] in
            self?.startImageDataLoad()
        }
    }
    
    private func shouldStartANewImageDataLoad(for cell: UITableViewCell) -> Bool {
        isNotReferencingThis(cell) || delegate.hasNoImageRequest
    }
    
    private func isNotReferencingThis(_ cell: UITableViewCell) -> Bool {
        self.cell !== cell
    }
    
    private func startImageDataLoad() {
        delegate.didRequestImage()
    }
    
    func preload() {
        delegate.didRequestImage()
    }
    
    deinit {
        cancelImageDataLoad()
    }
    
    func cancelImageDataLoad() {
        releaseCellForReuse()
        delegate.didCancelImageRequest()
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
}

extension FeedImageCellController: FeedImageView {
    func display(_ viewModel: FeedImageViewModel<UIImage>) {
        configureCell(with: viewModel)
    }
    
    private func configureCell(with viewModel: FeedImageViewModel<UIImage>) {
        cell?.locationContainer.isHidden = (viewModel.location == nil)
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.isHidden = (viewModel.description == nil)
        cell?.descriptionLabel.text = viewModel.description
        cell?.feedImageView.image = viewModel.image
        cell?.feedImageRetryButton.isHidden = !viewModel.shouldRetry
    }
}

extension FeedImageCellController: FeedImageLoadingView {
    func display(_ viewModel: FeedImageLoadingViewModel) {
        cell?.feedImageContainer.isShimmering = viewModel.isLoading
    }
}
