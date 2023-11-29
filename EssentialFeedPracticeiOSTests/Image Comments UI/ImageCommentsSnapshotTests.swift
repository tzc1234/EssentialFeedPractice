//
//  ImageCommentsSnapshotTests.swift
//  EssentialFeedPracticeiOSTests
//
//  Created by Tsz-Lung on 27/10/2023.
//

import XCTest
@testable import EssentialFeedPractice
import EssentialFeedPracticeiOS

final class ImageCommentsSnapshotTests: XCTestCase {
    func test_listWithComments() {
        let sut = makeSUT()
        
        sut.display(comments())
        
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "IMAGE_COMMENTS_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "IMAGE_COMMENTS_dark")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light, contentSize: .extraExtraExtraLarge)),
               named: "IMAGE_COMMENTS_light_extraExtraExtraLarge")
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> ListViewController {
        let refresh = RefreshViewController()
        let sut = ListViewController(refreshController: refresh)
        sut.registerTableCell(ImageCommentCell.self)
        sut.tableView.showsVerticalScrollIndicator = false
        sut.tableView.showsHorizontalScrollIndicator = false
        sut.loadViewIfNeeded()
        return sut
    }
    
    private func comments() -> [CellController] {
        [
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    message: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                    date: "1000 years ago",
                    username: "a long long long long long username")
            ),
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    message: "The East Side Gallery\nis an open-air gallery in Berlin.",
                    date: "10 years ago",
                    username: "a username")
            ),
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    message: "nice",
                    date: "1 hour ago",
                    username: "a.")
            )
        ].map { CellController(id: UUID(), $0) }
    }
}
