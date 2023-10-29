//
//  ListSnapshotTests.swift
//  EssentialFeedPracticeiOSTests
//
//  Created by Tsz-Lung on 27/10/2023.
//

import XCTest
@testable import EssentialFeedPractice
import EssentialFeedPracticeiOS

final class ListSnapshotTests: XCTestCase {
    func test_emptyList() {
        let sut = makeSUT()
        
        sut.display(emptyFeed())
        
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "EMPTY_LIST_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "EMPTY_LIST_dark")
    }
    
    func test_listWithErrorMessage() {
        let sut = makeSUT()
        
        sut.display(.error(message: "This is a\nmulti-line\nerror message"))
        
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "LIST_WITH_ERROR_MESSAGE_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "LIST_WITH_ERROR_MESSAGE_dark")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light, contentSize: .extraExtraExtraLarge)),
               named: "LIST_WITH_ERROR_MESSAGE_light_extraExtraExtraLarge")
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> ListViewController {
        let refresh = RefreshViewController()
        let sut = ListViewController(refreshController: refresh)
        sut.registerTableCell(UITableViewCell.self, forCellReuseIdentifier: "CELL")
        sut.tableView.showsVerticalScrollIndicator = false
        sut.tableView.showsHorizontalScrollIndicator = false
        sut.loadViewIfNeeded()
        return sut
    }
    
    private func emptyFeed() -> [CellController] {
        []
    }
}
