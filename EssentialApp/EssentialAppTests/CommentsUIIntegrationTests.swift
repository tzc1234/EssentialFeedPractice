//
//  CommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Tsz-Lung on 30/10/2023.
//

import XCTest
import UIKit
import EssentialFeedPractice
import EssentialFeedPracticeiOS
import EssentialApp

final class CommentsUIIntegrationTests: FeedUIIntegrationTests {
    override func test_feedView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.simulateViewIsAppearing()
        
        XCTAssertEqual(sut.title, feedTitle)
    }
    
    override func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expect no loading requests before view is loaded")
        
        sut.simulateViewIsAppearing()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expect a loading request once view is loaded")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Expect another loading request once user initiates a load")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 3, "Expect a third loading request once user initiates another load")
    }
    
    override func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
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
    
    override func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
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
    
    override func test_loadFeedCompletion_doesNotAlterCurrentRenderedStateOnError() {
        let image0 = makeImage()
        let (sut, loader) = makeSUT()
        
        sut.simulateViewIsAppearing()
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut, isRendering: [image0])
    }
    
    override func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.simulateViewIsAppearing()
        
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeFeedLoading(at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    override func test_loadFeedErrorView_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()
        
        sut.simulateViewIsAppearing()
        XCTAssertNil(sut.errorMessage)
        
        loader.completeFeedLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertNil(sut.errorMessage)
    }
    
    override func test_loadFeedErrorView_dismissesRenderErrorMessageAfterUserDismissedIt() {
        let (sut, loader) = makeSUT()
        
        sut.simulateViewIsAppearing()
        XCTAssertNil(sut.errorMessage)
        
        loader.completeFeedLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateUserDismissedFeedErrorView()
        XCTAssertNil(sut.errorMessage, "Expect no feed error message after user dismissed the feed error view")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.commentsComposedWith(commentsLoader: loader.loadPublisher)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func assertThat(_ sut: ListViewController,
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
    
    private func assertThat(_ sut: ListViewController,
                            hasViewConfigureFor image: FeedImage,
                            at index: Int,
                            file: StaticString = #filePath,
                            line: UInt = #line) {
        let view = sut.feedImageView(at: index)
        
        assertThat(view, hasViewConfigureFor: image, at: index, file: file, line: line)
    }
    
    private func assertThat(_ view: FeedImageCell?,
                            hasViewConfigureFor image: FeedImage,
                            at index: Int,
                            file: StaticString = #filePath,
                            line: UInt = #line) {
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
}
