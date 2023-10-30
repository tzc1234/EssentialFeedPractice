//
//  ListViewController+TestHelpers.swift
//  EssentialFeedPracticeiOSTests
//
//  Created by Tsz-Lung on 23/09/2023.
//

import Foundation
import EssentialFeedPracticeiOS

extension ListViewController {
    func simulateViewIsAppearing() {
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }
    
    var errorMessage: String? {
        errorView.message
    }
    
    func simulateUserDismissedErrorView() {
        errorView.simulate(event: .touchUpInside)
    }
}

extension ListViewController {
    func renderedFeedImageData(at index: Int) -> Data? {
        simulateFeedImageViewVisible(at: index)?.renderedImage
    }
    
    func numberOfRenderedFeedImageViews() -> Int {
        tableView.numberOfSections > feedImageSection ? tableView.numberOfRows(inSection: feedImageSection) : 0
    }
    
    func feedImageView(at row: Int) -> FeedImageCell? {
        guard numberOfRenderedFeedImageViews() > row else {
            return nil
        }
        
        let ds = tableView.dataSource
        let indexPath = IndexPath(row: row, section: feedImageSection)
        return ds?.tableView(tableView, cellForRowAt: indexPath) as? FeedImageCell
    }
    
    @discardableResult
    func simulateFeedImageViewVisible(at row: Int) -> FeedImageCell? {
        feedImageView(at: row)
    }
    
    @discardableResult
    func simulateFeedImageViewNotVisible(at row: Int) -> FeedImageCell? {
        guard let cell = simulateFeedImageViewVisible(at: row) else {
            return nil
        }
        
        let d = tableView.delegate
        let indexPath = IndexPath(row: row, section: feedImageSection)
        d?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
        return cell
    }
    
    func simulateFeedImageViewVisibleAgain(for cell: FeedImageCell, at row: Int) {
        let d = tableView.delegate
        let indexPath = IndexPath(row: row, section: feedImageSection)
        d?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
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

extension ListViewController {
    func commentView(at row: Int) -> ImageCommentCell? {
        guard numberOfRenderedCommentViews() > row else {
            return nil
        }
        
        let ds = tableView.dataSource
        let indexPath = IndexPath(row: row, section: commentsSection)
        return ds?.tableView(tableView, cellForRowAt: indexPath) as? ImageCommentCell
    }
    
    func numberOfRenderedCommentViews() -> Int {
        tableView.numberOfSections > commentsSection ? tableView.numberOfRows(inSection: commentsSection) : 0
    }
    
    private var commentsSection: Int { 0 }
}
