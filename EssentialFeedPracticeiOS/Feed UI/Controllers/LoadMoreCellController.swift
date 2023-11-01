//
//  LoadMoreCellController.swift
//  EssentialFeedPracticeiOS
//
//  Created by Tsz-Lung on 31/10/2023.
//

import UIKit
import EssentialFeedPractice

public final class LoadMoreCellController: NSObject {
    private let cell = LoadMoreCell()
    
    private let callback: () -> Void
    
    public init(callback: @escaping () -> Void) {
        self.callback = callback
    }
}

extension LoadMoreCellController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell
    }
}

extension LoadMoreCellController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, willDisplay: UITableViewCell, forRowAt indexPath: IndexPath) {
        reloadIfNeeded()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        reloadIfNeeded()
    }
    
    private func reloadIfNeeded() {
        guard !cell.isLoading else { return }
        
        callback()
    }
}

extension LoadMoreCellController: ResourceLoadingView {
    public func display(_ viewModel: ResourceLoadingViewModel) {
        cell.isLoading = viewModel.isLoading
    }
}

extension LoadMoreCellController: ResourceErrorView {
    public func display(_ viewModel: ResourceErrorViewModel) {
        cell.message = viewModel.message
    }
}
