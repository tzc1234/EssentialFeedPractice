//
//  ListViewController+TestHelpers.swift
//  EssentialFeedPracticeiOSTests
//
//  Created by Tsz-Lung on 23/09/2023.
//

import UIKit
import EssentialFeedPracticeiOS

extension ListViewController {
    func simulateViewIsAppearing() {
        setFrameToPreventConstraintWarnings()
        
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    private func setFrameToPreventConstraintWarnings() {
        tableView.frame = CGRect(x: 0, y: 0, width: 390, height: 1)
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
    
    func numberOfRows(in section: Int) -> Int {
        tableView.numberOfSections > section ? tableView.numberOfRows(inSection: section) : 0
    }
    
    func cell(atRow row: Int, inSection section: Int) -> UITableViewCell? {
        guard numberOfRows(in: section) > row else {
            return nil
        }
        
        let ds = tableView.dataSource
        let indexPath = IndexPath(row: row, section: section)
        return ds?.tableView(tableView, cellForRowAt: indexPath)
    }
}

extension ListViewController {
    func renderedFeedImageData(at index: Int) -> Data? {
        simulateFeedImageViewVisible(at: index)?.renderedImage
    }
    
    func numberOfRenderedFeedImageViews() -> Int {
        numberOfRows(in: feedImageSection)
    }
    
    func feedImageView(at row: Int) -> FeedImageCell? {
        cell(atRow: row, inSection: feedImageSection) as? FeedImageCell
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
    
    func simulateTapOnFeedImage(at row: Int) {
        let d = tableView.delegate
        let indexPath = IndexPath(row: row, section: feedImageSection)
        d?.tableView?(tableView, didSelectRowAt: indexPath)
    }
    
    func simulateLoadMoreFeedAction() {
        guard let view = loadMoreFeedCell() else { return }
        
        let d = tableView.delegate
        let indexPath = IndexPath(row: 0, section: feedLoadMoreSection)
        d?.tableView?(tableView, willDisplay: view, forRowAt: indexPath)
    }
    
    var isShowingLoadingMoreFeedIndicator: Bool {
        loadMoreFeedCell()?.isLoading == true
    }
    
    var loadMoreErrorMessage: String? {
        loadMoreFeedCell()?.message
    }
    
    private func loadMoreFeedCell() -> LoadMoreCell? {
        cell(atRow: 0, inSection: feedLoadMoreSection) as? LoadMoreCell
    }
    
    func simulateTapOnLoadMoreFeedError() {
        let d = tableView.delegate
        let indexPath = IndexPath(row: 0, section: feedLoadMoreSection)
        d?.tableView?(tableView, didSelectRowAt: indexPath)
    }
    
    private var feedImageSection: Int { 0 }
    private var feedLoadMoreSection: Int { 1 }
}

extension ListViewController {
    func commentView(at row: Int) -> ImageCommentCell? {
        cell(atRow: row, inSection: commentsSection) as? ImageCommentCell
    }
    
    func numberOfRenderedCommentViews() -> Int {
        numberOfRows(in: commentsSection)
    }
    
    func commentMessage(at row: Int) -> String? {
        commentView(at: row)?.messageText
    }
    
    private var commentsSection: Int { 0 }
}
