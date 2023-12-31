//
//  FeedImageCellController.swift
//  EssentialFeedPracticeiOS
//
//  Created by Tsz-Lung on 25/09/2023.
//

import UIKit
import EssentialFeedPractice

public protocol FeedImageCellControllerDelegate {
    var hasNoImageRequest: Bool { get }
    func didRequestImage()
    func didCancelImageRequest()
}

public final class FeedImageCellController: NSObject {
    private var cell: FeedImageCell?
    
    private let viewModel: FeedImageViewModel
    private let delegate: FeedImageCellControllerDelegate
    private let selection: (() -> Void)
    
    public init(viewModel: FeedImageViewModel,
                delegate: FeedImageCellControllerDelegate,
                selection: @escaping (() -> Void)) {
        self.viewModel = viewModel
        self.delegate = delegate
        self.selection = selection
    }
    
    private func startLoading(for cell: UITableViewCell) {
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
        cell.locationContainer.isHidden = (viewModel.location == nil)
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.isHidden = (viewModel.description == nil)
        cell.descriptionLabel.text = viewModel.description
        cell.feedImageRetryButton.isHidden = true
        cell.feedImageView.setImage(nil)
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
    
    private func preload() {
        delegate.didRequestImage()
    }
    
    deinit {
        cancelLoading()
    }
    
    private func cancelLoading() {
        releaseCellForReuse()
        delegate.didCancelImageRequest()
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
}

extension FeedImageCellController: ResourceView {
    public typealias ResourceViewModel = UIImage
    
    public func display(_ viewModel: UIImage) {
        cell?.feedImageView.setImage(viewModel)
    }
}

extension FeedImageCellController: ResourceLoadingView {
    public func display(_ viewModel: ResourceLoadingViewModel) {
        cell?.feedImageContainer.isShimmering = viewModel.isLoading
    }
}

extension FeedImageCellController: ResourceErrorView {
    public func display(_ viewModel: ResourceErrorViewModel) {
        cell?.feedImageRetryButton.isHidden = viewModel.message == nil
    }
}

extension FeedImageCellController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FeedImageCell.identifier) as! FeedImageCell
        setup(cell)
        startImageDataLoad()
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selection()
    }
}

extension FeedImageCellController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        startLoading(for: cell)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelLoading()
    }
}

extension FeedImageCellController: UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        preload()
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        cancelLoading()
    }
}
