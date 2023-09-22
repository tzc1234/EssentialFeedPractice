//
//  FeedViewControllerTests.swift
//  EssentialFeedPracticeiOSTests
//
//  Created by Tsz-Lung on 21/09/2023.
//

import XCTest
import UIKit
import EssentialFeedPractice
import EssentialFeedPracticeiOS

final class FeedViewControllerTests: XCTestCase {
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expect no loading requests before view is loaded")
        
        sut.simulateViewIsAppearing()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expect a loading request once view is loaded")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Expect another loading request once user initiates a load")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 3, "Expect a third loading request once user initiates another load")
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        let stub = UIRefreshControl.refreshingStub()
        stub.startIntercepting()
        
        sut.simulateViewIsAppearing()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect loading indicator once view is loaded")
        
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect no loading indicator once loading completes successfully")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect loading indicator once user initiates a reload")
        
        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect no loading indicator once user initiated loading completes with error")
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: nil, location: "another location")
        let image2 = makeImage(description: "another description", location: nil)
        let image3 = makeImage(description: nil, location: nil)
        let (sut, loader) = makeSUT()
        
        sut.simulateViewIsAppearing()
        assertThat(sut, isRendering: [])
        
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: [image0, image1, image2, image3], at: 1)
        assertThat(sut, isRendering: [image0, image1, image2, image3])
    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderedStateOnError() {
        let image0 = makeImage()
        let (sut, loader) = makeSUT()
        
        sut.simulateViewIsAppearing()
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut, isRendering: [image0])
    }
    
    func test_feedImageView_loadsImageURLWhenVisible() {
        let image0 = makeImage(url: URL(string: "https://url-0.com")!)
        let image1 = makeImage(url: URL(string: "https://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateViewIsAppearing()
        loader.completeFeedLoading(with: [image0, image1])
        XCTAssertEqual(loader.loadedImageURLs, [], "Expect no image URL requests until views become visible")
        
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expect an image URL request once the 1st view becomes visible")
        
        sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expect a 2nd image URL request once the 2nd view also becomes visible")
    }
    
    func test_feedImageView_cancelsImageLoadingWhenNotVisibleAnymore() {
        let image0 = makeImage(url: URL(string: "https://url-0.com")!)
        let image1 = makeImage(url: URL(string: "https://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateViewIsAppearing()
        loader.completeFeedLoading(with: [image0, image1])
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expect no cancelled URL requests until image is not visible")
        
        sut.simulateFeedImageViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expect a cancelled image URL request once the 1st image is not visible anymore")
        
        sut.simulateFeedImageViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url], "Expect a 2nd cancelled image URL request once the 2nd image is also not visible anymore")
    }
    
    func test_feedImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
        let (sut, loader) = makeSUT()
        
        sut.simulateViewIsAppearing()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view0?.isShowingLoadingIndicator, true, "Expect loading indicator for 1st view while loading 1st image")
        XCTAssertEqual(view1?.isShowingLoadingIndicator, true, "Expect loading indicator for 2nd view while loading 2nd image")
        
        loader.completeImageLoading(at: 0)
        XCTAssertEqual(view0?.isShowingLoadingIndicator, false, "Expect no loading indicator for 1st view once 1st image loading completes successfully")
        XCTAssertEqual(view1?.isShowingLoadingIndicator, true, "Expect no loading indicator state change for 2nd view once 1st image loading completes successfully")
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingLoadingIndicator, false, "Expect no loading indicator state change for 1st view once 2nd image loading completes with error")
        XCTAssertEqual(view1?.isShowingLoadingIndicator, false, "Expect no loading indicator for 2nd view once 2nd image loading completes with error")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(feedLoader: loader, imageLoader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func assertThat(_ sut: FeedViewController, 
                            isRendering feed: [FeedImage],
                            file: StaticString = #filePath,
                            line: UInt = #line) {
        guard sut.numberOfRenderedFeedImageViews() == feed.count else {
            XCTFail(
                "Expect \(feed.count) image views rendered, got \(sut.numberOfRenderedFeedImageViews()) image views instead",
                file: file,
                line: line)
            return
        }
        
        feed.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfigureFor: image, at: index, file: file, line: line)
        }
    }
    
    private func assertThat(_ sut: FeedViewController, 
                            hasViewConfigureFor image: FeedImage, 
                            at index: Int,
                            file: StaticString = #filePath,
                            line: UInt = #line) {
        let view = sut.feedImageView(at: index)
        
        let shouldLocationBeVisible = image.location != nil
        XCTAssertEqual(
            view?.isShowingLocation,
            shouldLocationBeVisible,
            "Expect shouldLocationBeVisible to be \(shouldLocationBeVisible) for image view at \(index)",
            file: file,
            line: line)
        
        let shouldDescriptionBeVisible = image.description != nil
        XCTAssertEqual(
            view?.isShowingDescription,
            shouldDescriptionBeVisible,
            "Expect shouldDescriptionBeVisible to be \(shouldDescriptionBeVisible) for image view at \(index)", 
            file: file,
            line: line)
        
        XCTAssertEqual(
            view?.locationText,
            image.location,
            "Expect location to be \(String(describing: image.location)) for image view at \(index)",
            file: file,
            line: line)
        
        XCTAssertEqual(
            view?.descriptionText,
            image.description,
            "Expect description to be \(String(describing: image.description)) for image view at \(index)",
            file: file,
            line: line)
    }
    
    private func makeImage(description: String? = nil,
                           location: String? = nil,
                           url: URL = anyURL()) -> FeedImage {
        FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    
    private class LoaderSpy: FeedLoader, FeedImageDataLoader {
        // MARK: - FeedLoader
        
        private var feedRequests = [(FeedLoader.Result) -> Void]()
        
        var loadFeedCallCount: Int {
            feedRequests.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            feedRequests.append(completion)
        }
        
        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            feedRequests[index](.success(feed))
        }
        
        func completeFeedLoadingWithError(at index: Int = 0) {
            feedRequests[index](.failure(anyNSError()))
        }
        
        // MARK: - FeedImageDataLoader
        
        private(set) var cancelledImageURLs = [URL]()
        private(set) var imageRequests = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        var loadedImageURLs: [URL] {
            imageRequests.map(\.url)
        }
        
        private struct Task: FeedImageDataLoaderTask {
            let afterCancel: () -> Void
            
            func cancel() {
                afterCancel()
            }
        }
        
        func loadImage(from url: URL, 
                       completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            imageRequests.append((url, completion))
            return Task { [weak self] in
                self?.cancelledImageURLs.append(url)
            }
        }
        
        func completeImageLoading(at index: Int = 0) {
            imageRequests[index].completion(.success(anyData()))
        }
        
        func completeImageLoadingWithError(at index: Int = 0) {
            imageRequests[index].completion(.failure(anyNSError()))
        }
    }
}

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
    
    private var feedImageSection: Int { 0 }
}

extension FeedImageCell {
    var isShowingLocation: Bool {
        !locationContainer.isHidden
    }
    
    var isShowingDescription: Bool {
        !descriptionLabel.isHidden
    }
    
    var locationText: String? {
        locationLabel.text
    }
    
    var descriptionText: String? {
        descriptionLabel.text
    }
    
    var isShowingLoadingIndicator: Bool {
        feedImageContainer.isShimmering
    }
}

private extension UIRefreshControl {
    static func refreshingStub() -> Stub {
        Stub(methodPairs: [
            .init(
                source: #selector(getter: Stub.isRefreshing),
                destination: #selector(getter: UIRefreshControl.isRefreshing)
            ),
            .init(
                source: #selector(Stub.beginRefreshing),
                destination: #selector(UIRefreshControl.beginRefreshing)
            ),
            .init(
                source: #selector(Stub.endRefreshing),
                destination: #selector(UIRefreshControl.endRefreshing)
            )
        ])
    }
    
    class Stub: MethodSwizzlingStub<UIRefreshControl> {
        @objc private(set) var isRefreshing = false
        
        @objc func beginRefreshing() {
            isRefreshing = true
        }
        
        @objc func endRefreshing() {
            isRefreshing = false
        }
    }
    
    func simulatePullToRefresh() {
        allTargets.forEach{ target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                (target as NSObject).perform(Selector(action))
            }
        }
    }
}
