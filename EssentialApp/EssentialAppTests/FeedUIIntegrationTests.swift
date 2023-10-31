//
//  FeedUIIntegrationTests.swift
//  EssentialFeedPracticeiOSTests
//
//  Created by Tsz-Lung on 21/09/2023.
//

import XCTest
import UIKit
import EssentialFeedPractice
import EssentialFeedPracticeiOS
import EssentialApp

final class FeedUIIntegrationTests: XCTestCase {
    func test_feedView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.simulateViewIsAppearing()
        
        XCTAssertEqual(sut.title, feedTitle)
    }
    
    func test_imageSelection_notifiesHandler() {
        let image0 = makeImage()
        let image1 = makeImage()
        var selectedImages = [FeedImage]()
        let (sut, loader) = makeSUT(selection: { selectedImages.append($0) })
        
        sut.simulateViewIsAppearing()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        
        sut.simulateTapOnFeedImage(at: 0)
        XCTAssertEqual(selectedImages, [image0])
        
        sut.simulateTapOnFeedImage(at: 1)
        XCTAssertEqual(selectedImages, [image0, image1])
    }
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expect no loading requests before view is loaded")
        
        sut.simulateViewIsAppearing()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expect a loading request once view is loaded")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Expect another loading request once user initiates a load")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 3, "Expect a third loading request once user initiates another load")
    }
    
    func test_loadMoreActions_requestMoreFromLoader() {
        let (sut, loader) = makeSUT()
        sut.simulateViewIsAppearing()
        
        XCTAssertEqual(loader.loadMoreCallCount, 0, "Expect no requests before load feed completion")
        
        loader.completeFeedLoading()
        XCTAssertEqual(loader.loadMoreCallCount, 0, "Expect no requests until load more action")
        
        sut.simulateLoadMoreFeedAction()
        XCTAssertEqual(loader.loadMoreCallCount, 1, "Expect a load more request once user initiated load more action")
        
        sut.simulateLoadMoreFeedAction()
        XCTAssertEqual(loader.loadMoreCallCount, 1, "Expect no request while loading more")
        
        loader.completeLoadMore(isLastPage: false, at: 0)
        sut.simulateLoadMoreFeedAction()
        XCTAssertEqual(loader.loadMoreCallCount, 2, "Expect request after load more completed with more pages")
        
        loader.completeLoadMoreWithError(at: 1)
        sut.simulateLoadMoreFeedAction()
        XCTAssertEqual(loader.loadMoreCallCount, 3, "Expect request after load more failure")
        
        loader.completeLoadMore(isLastPage: true, at: 2)
        sut.simulateLoadMoreFeedAction()
        XCTAssertEqual(loader.loadMoreCallCount, 3, "Expect no request after loading all pages")
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        let stub = UIRefreshControl.refreshingStub()
        stub.startIntercepting()
        
        sut.simulateViewIsAppearing()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect loading indicator once view is loaded")
        
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect no loading indicator once loading completes successfully")
        
        sut.simulateUserInitiatedReload()
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
        
        sut.simulateUserInitiatedReload()
        loader.completeFeedLoading(with: [image0, image1, image2, image3], at: 1)
        assertThat(sut, isRendering: [image0, image1, image2, image3])
    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderedStateOnError() {
        let image0 = makeImage()
        let (sut, loader) = makeSUT()
        
        sut.simulateViewIsAppearing()
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut, isRendering: [image0])
    }
    
    func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.simulateViewIsAppearing()
        
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeFeedLoading(at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    func test_loadFeedErrorView_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()
        
        sut.simulateViewIsAppearing()
        XCTAssertNil(sut.errorMessage)
        
        loader.completeFeedLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateUserInitiatedReload()
        XCTAssertNil(sut.errorMessage)
    }
    
    func test_loadFeedErrorView_dismissesRenderErrorMessageAfterUserDismissedIt() {
        let (sut, loader) = makeSUT()
        
        sut.simulateViewIsAppearing()
        XCTAssertNil(sut.errorMessage)
        
        loader.completeFeedLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateUserDismissedErrorView()
        XCTAssertNil(sut.errorMessage, "Expect no feed error message after user dismissed the feed error view")
    }
    
    // MARK: - Image view tests
    
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
    
    func test_feedImageView_reloadsCancelledImageLoadingWhenVisibleAgain() {
        let image = makeImage(url: URL(string: "https://url-0.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateViewIsAppearing()
        loader.completeFeedLoading(with: [image])
        
        let view = sut.simulateFeedImageViewNotVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image.url], "Expect an image URL request once the view becomes visible")
        XCTAssertEqual(loader.cancelledImageURLs, [image.url], "Expect a cancelled image URL request once the view is not visible anymore")
        
        sut.simulateFeedImageViewVisibleAgain(for: view!, at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image.url, image.url], "Expect a reload of cancelled image URL request once the view becomes visible again")
    }
    
    func test_feedImageView_doesNotLoadImageIfItIsAlreadyLoadingWhenVisibleAgain() {
        let image = makeImage(url: URL(string: "https://url-0.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateViewIsAppearing()
        loader.completeFeedLoading(with: [image])
        
        let view = sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image.url], "Expect an image URL request once the view becomes visible")
        
        sut.simulateFeedImageViewVisibleAgain(for: view!, at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image.url], "Expect no image URL request state change once the view becomes visible again")
    }
    
    func test_feedImageView_rendersImageWhileViewVisibleAgainOnDifferentPosition() {
        let image0 = makeImage(description: "desc0", location: "location0", url: URL(string: "https://url-0.com")!)
        let image1 = makeImage(description: "desc1", location: "location1", url: URL(string: "https://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateViewIsAppearing()
        loader.completeFeedLoading(with: [image0, image1])
        
        let view0 = sut.simulateFeedImageViewNotVisible(at: 0)
        let view1 = sut.simulateFeedImageViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url], "Expect 2 cancelled image URL requests once the views become not visible")
        
        sut.simulateFeedImageViewVisibleAgain(for: view1!, at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url], "Expect a new image URL request once the 2nd view becomes visible again on 1st position")
        
        let imageData = UIImage.makeData(withColor: .red)
        loader.completeImageLoading(with: imageData, at: 2)
        XCTAssertNil(view0?.renderedImage, "Expect no image rendered on 1st view once the 2nd image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, imageData, "Expect 2nd view rendered the loaded image once the 2nd image loading completes successfully")
        assertThat(view1, hasViewConfigureFor: image0, at: 0)
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
    
    func test_feedImageView_rendersImageLoadedFromURL() {
        let (sut, loader) = makeSUT()
        
        sut.simulateViewIsAppearing()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view0?.renderedImage, .none, "Expect no image for 1st view while loading 1st image")
        XCTAssertEqual(view1?.renderedImage, .none, "Expect no image for 2nd view while loading 2nd image")
        
        let imageData0 = UIImage.makeData(withColor: .red)
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expect image for 1st view once 1st image loading complete successfully")
        XCTAssertEqual(view1?.renderedImage, .none, "Expect no image state change for 2nd view once 1st image loading complete successfully")
        
        let imageData1 = UIImage.makeData(withColor: .blue)
        loader.completeImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expect no image state change for 1st view once 2nd image loading complete successfully")
        XCTAssertEqual(view1?.renderedImage, imageData1, "Expect image for 2nd view once 2nd image loading complete successfully")
    }
    
    func test_feedImageViewRetryAction_isVisibleOnImageLoadError() {
        let (sut, loader) = makeSUT()
        
        sut.simulateViewIsAppearing()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expect no retry action for 1st view while loading 1st image")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expect no retry action for 2nd view while loading 2nd image")
        
        let imageData0 = UIImage.makeData(withColor: .red)
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expect no retry action for 1st view once 1st image loading complete successfully")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expect no retry action state change for 2nd view once 1st image loading complete successfully")
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expect no retry action state change for 1st view once 2nd image loading complete with error")
        XCTAssertEqual(view1?.isShowingRetryAction, true, "Expect a retry action for 2nd view once 2nd image loading complete with error")
    }
    
    func test_feedImageViewRetryAction_isVisibleOnInvalidImageData() {
        let (sut, loader) = makeSUT()
        
        sut.simulateViewIsAppearing()
        loader.completeFeedLoading(with: [makeImage()])
        
        let view = sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(view?.isShowingRetryAction, false, "Expect no retry action while loading image")
        
        let invalidImageData = Data("invalid image data".utf8)
        loader.completeImageLoading(with: invalidImageData, at: 0)
        XCTAssertEqual(view?.isShowingRetryAction, true, "Expect a retry action once image loading complete with an invalid image data")
    }
    
    func test_feedImageViewRetryAction_retriesImageLoad() {
        let image0 = makeImage(url: URL(string: "https://url-0.com")!)
        let image1 = makeImage(url: URL(string: "https://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateViewIsAppearing()
        loader.completeFeedLoading(with: [image0, image1])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        
        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expect only 2 image URL requests before the retries")
        
        view0?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url], "Expect 3rd image URL request after 1st view retry action")
        
        view1?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url, image1.url], "Expect 4th image URL request after 2nd view retry action")
    }
    
    func test_feedImageViewRetryAction_retriesImageLoadForViewVisibleAgainOnDifferentPosition() {
        let image0 = makeImage(url: URL(string: "https://url-0.com")!)
        let image1 = makeImage(url: URL(string: "https://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateViewIsAppearing()
        loader.completeFeedLoading(with: [image0, image1])
        
        sut.simulateFeedImageViewNotVisible(at: 0)
        let view1 = sut.simulateFeedImageViewNotVisible(at: 1)!
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expect only 2 image URL requests after the views become not visible")
        
        sut.simulateFeedImageViewVisibleAgain(for: view1, at: 0)
        loader.completeImageLoadingWithError(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url], "Expect a 1st image URL request after 2nd view visible again on 1st position")
        
        view1.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url, image0.url], "Expect a 1st image URL retry request after 2nd view visible again on 1st position retry action")
    }
    
    func test_feedImageView_preloadsImageURLWhenNearVisible() {
        let image0 = makeImage(url: URL(string: "https://url-0.com")!)
        let image1 = makeImage(url: URL(string: "https://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateViewIsAppearing()
        loader.completeFeedLoading(with: [image0, image1])
        
        XCTAssertEqual(loader.loadedImageURLs, [], "Expect no image URL requests until view is near visible")
        
        sut.simulateFeedImageViewNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expect 1st image URL request once 1st view is near visible")
        
        sut.simulateFeedImageViewNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expect 2nd image URL request once 2nd view is near visible")
    }
    
    func test_feedImageView_cancelsImageURLForPreloadingWhenNotNearVisibleAnymore() {
        let image0 = makeImage(url: URL(string: "https://url-0.com")!)
        let image1 = makeImage(url: URL(string: "https://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateViewIsAppearing()
        loader.completeFeedLoading(with: [image0, image1])
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expect no cancelled image URL requests until view is not near visible")
        
        sut.simulateFeedImageViewNotNearVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expect 1st cancelled image URL request once 1st view is not near visible anymore")
        
        sut.simulateFeedImageViewNotNearVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url], "Expect 2nd cancelled image URL request once 2nd view is not near visible anymore")
    }
    
    func test_feedImageView_doesNotRenderImageWhenNotVisibleAnymore() {
        let (sut, loader) = makeSUT()
        
        sut.simulateViewIsAppearing()
        loader.completeFeedLoading(with: [makeImage()])
        
        let view = sut.simulateFeedImageViewNotVisible(at: 0)
        loader.completeImageLoading(with: anyImageData(), at: 0)
        
        XCTAssertNil(view?.renderedImage, "Expect no image rendered after the image loading successfully but the view becomes not visible anymore")
    }
    
    func test_loadImageDataCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        
        sut.simulateViewIsAppearing()
        loader.completeFeedLoading(with: [makeImage()])
        sut.simulateFeedImageViewVisible(at: 0)
        
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeImageLoading(with: self.anyImageData(), at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(selection: @escaping (FeedImage) -> Void = { _ in },
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedUIComposer.feedComposedWith(
            feedLoader: loader.loadPublisher,
            imageLoader: loader.loadImageDataPublisher,
            selection: selection)
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
    
    private func anyImageData() -> Data {
        UIImage.makeData(withColor: .red)
    }
}
