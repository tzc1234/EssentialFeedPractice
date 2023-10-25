//
//  FeedViewController.swift
//  EssentialFeedPracticeiOS
//
//  Created by Tsz-Lung on 22/09/2023.
//

import UIKit
import EssentialFeedPractice

public final class FeedViewController: UITableViewController {
    public let errorView = ErrorView()
    
    private var models = [FeedImageCellController]() {
        didSet { tableView.reloadData() }
    }
    
    private var onViewIsAppearing: ((FeedViewController) -> Void)?
    
    private let refreshController: FeedRefreshViewController
    
    public init(refreshController: FeedRefreshViewController) {
        self.refreshController = refreshController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { nil }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = refreshController.view
        configureTableView()
        onViewIsAppearing = { vc in
            vc.refreshController.refresh()
            vc.onViewIsAppearing = nil
        }
    }
    
    private func configureTableView() {
        tableView.register(FeedImageCellController.cellClass,
                           forCellReuseIdentifier: FeedImageCellController.cellIdentifier)
        tableView.prefetchDataSource = self
        tableView.separatorStyle = .none
        tableView.tableHeaderView = errorView.makeContainer()
        tableView.tableFooterView = .init(frame: CGRect(x: 0, y: 0, width: 0, height: 16))
        
        errorView.onHide = { [weak self] in
            self?.tableView.beginUpdates()
            self?.tableView.sizeTableHeaderToFit()
            self?.tableView.endUpdates()
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.sizeTableHeaderToFit()
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        onViewIsAppearing?(self)
    }
    
    public func display(_ cellControllers: [FeedImageCellController]) {
        models = cellControllers
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellController(forRowAt: indexPath).view(for: tableView)
    }
    
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).startImageDataLoad(for: cell)
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        models[indexPath.row]
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(forRowAt: indexPath)
    }
    
    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancelImageDataLoad()
    }
}

extension FeedViewController: UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { cellController(forRowAt: $0).preload() }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }
}

extension FeedViewController: ResourceErrorView {
    public func display(_ viewModel: ResourceErrorViewModel) {
        errorView.message = viewModel.message
    }
}
