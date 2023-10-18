//
//  FeedSnapshotTests.swift
//  EssentialFeedPracticeiOSTests
//
//  Created by Tsz-Lung on 18/10/2023.
//

import XCTest
import EssentialFeedPracticeiOS

final class FeedSnapshotTests: XCTestCase {
    func test_emptyFeed() {
        let sut = makeSUT()
        
        sut.display(emptyFeed())
        
        record(snapshot: sut.snapshot(), named: "EMPTY_FEED")
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> FeedViewController {
        let refresh = FeedRefreshViewController(delegate: RefreshDelegateDummy())
        let sut = FeedViewController(refreshController: refresh)
        sut.loadViewIfNeeded()
        return sut
    }
    
    private class RefreshDelegateDummy: FeedRefreshViewControllerDelegate {
        func didRequestFeedRefresh() {}
    }
    
    private func emptyFeed() -> [FeedImageCellController] {
        []
    }
    
    private func record(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line) {
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
            return
        }
        
        let snapshotURL = URL(filePath: String(describing: file))
            .deletingLastPathComponent()
            .appending(component: "snapshots")
            .appending(component: "\(name).png")
        
        do {
            try FileManager.default.createDirectory(
                at: snapshotURL.deletingLastPathComponent(),
                withIntermediateDirectories: true)
            try snapshotData.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to record snapshot with error \(error)", file: file, line: line)
        }
    }
}

extension UIViewController {
    func snapshot() -> UIImage {
        view.bounds = .init(origin: .zero, size: CGSize(width: 390, height: 844))
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { action in
            view.layer.render(in: action.cgContext)
        }
    }
}
