//
//  FeedViewControllerTests.swift
//  EssentialFeedPracticeiOSTests
//
//  Created by Tsz-Lung on 21/09/2023.
//

import XCTest
import UIKit
import EssentialFeedPractice

final class FeedViewController: UITableViewController {
    private let loader: FeedLoader
    
    init(loader: FeedLoader) {
        self.loader = loader
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}

final class FeedViewControllerTests: XCTestCase {
    func test_init_doesNotLoadFeed() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewIsAppearing_loadsFeed() {
        let (sut, loader) = makeSUT()
        
        sut.simulateViewIsAppearing()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    func test_pullToRefresh_loadsFeed() {
        let (sut, loader) = makeSUT()
        sut.simulateViewIsAppearing()
        
        sut.refreshControl?.simulatePullToRefresh()
        XCTAssertEqual(loader.loadCallCount, 2)
        
        sut.refreshControl?.simulatePullToRefresh()
        XCTAssertEqual(loader.loadCallCount, 3)
    }
    
    func test_viewIsAppearing_showsLoadingIndicator() {
        let (sut, _) = makeSUT()
        let stub = UIRefreshControl.MethodSwizzlingStub()
        stub.startIntercepting()
        
        sut.simulateViewIsAppearing()
        
        XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
    }
    
    func test_viewIsAppearing_hidesLoadingIndicatorOnLoaderCompletion() {
        let (sut, loader) = makeSUT()
        let stub = UIRefreshControl.MethodSwizzlingStub()
        stub.startIntercepting()
        
        sut.simulateViewIsAppearing()
        loader.completeFeedLoading()
        
        XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
    }
    
    func test_pullToRefresh_showsLoadingIndicator() {
        let (sut, _) = makeSUT()
        let stub = UIRefreshControl.MethodSwizzlingStub()
        stub.startIntercepting()
        
        sut.refreshControl?.simulatePullToRefresh()
        
        XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private class LoaderSpy: FeedLoader {
        private var completions = [(FeedLoader.Result) -> Void]()
        
        var loadCallCount: Int {
            completions.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeFeedLoading(at index: Int = 0) {
            completions[index](.success([]))
        }
    }
}

extension UIViewController {
    func simulateViewIsAppearing() {
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
}

private extension UIRefreshControl {
    class MethodSwizzlingStub: NSObject {
        struct MethodPair {
            let source: Selector
            let destination: Selector
        }
        
        @objc private(set) var isRefreshing = false
        
        private let destinationClass = UIRefreshControl.self
        private let methodPairs = [
            MethodPair(
                source: #selector(getter: isRefreshing),
                destination: #selector(getter: UIRefreshControl.isRefreshing)
            ),
            MethodPair(
                source: #selector(beginRefreshing),
                destination: #selector(UIRefreshControl.beginRefreshing)
            ),
            MethodPair(
                source: #selector(endRefreshing),
                destination: #selector(UIRefreshControl.endRefreshing)
            )
        ]
        
        override init() {}

        @objc func beginRefreshing() {
            isRefreshing = true
        }
        
        @objc func endRefreshing() {
            isRefreshing = false
        }
        
        func startIntercepting() {
            methodPairs.forEach { pair in
                method_exchangeImplementations(
                    class_getInstanceMethod(Self.self, pair.source)!,
                    class_getInstanceMethod(destinationClass, pair.destination)!
                )
            }
        }

        deinit {
            methodPairs.forEach { pair in
                method_exchangeImplementations(
                    class_getInstanceMethod(destinationClass, pair.destination)!,
                    class_getInstanceMethod(Self.self, pair.source)!
                )
            }
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
