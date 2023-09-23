//
//  FeedViewController+TestHelpers.swift
//  EssentialFeedPracticeiOSTests
//
//  Created by Tsz-Lung on 23/09/2023.
//

import Foundation
import EssentialFeedPracticeiOS

extension FeedViewController {
    func simulateViewIsAppearing() {
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }
    
    func numberOfRenderedFeedImageViews() -> Int {
        tableView.numberOfRows(inSection: feedImageSection)
    }
    
    func feedImageView(at row: Int) -> FeedImageCell? {
        let ds = tableView.dataSource
        let indexPath = IndexPath(row: row, section: feedImageSection)
        return ds?.tableView(tableView, cellForRowAt: indexPath) as? FeedImageCell
    }
    
    @discardableResult
    func simulateFeedImageViewVisible(at row: Int) -> FeedImageCell? {
        feedImageView(at: row)
    }
    
    func simulateFeedImageViewNotVisible(at row: Int) {
        guard let cell = simulateFeedImageViewVisible(at: row) else {
            return
        }
        
        let d = tableView.delegate
        let indexPath = IndexPath(row: row, section: feedImageSection)
        d?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    func simulateFeedImageViewNearVisible(at row: Int) {
        let pds = tableView.prefetchDataSource
        let indexPath = IndexPath(row: row, section: feedImageSection)
        pds?.tableView(tableView, prefetchRowsAt: [indexPath])
    }
    
    func simulateFeedImageViewNotNearVisible(at row: Int) {
        simulateFeedImageViewNearVisible(at: row)
        
        let pds = tableView.prefetchDataSource
        let indexPath = IndexPath(row: row, section: feedImageSection)
        pds?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
    }
    
    private var feedImageSection: Int { 0 }
}