//
//  FeedViewControllerTests+Localisation.swift
//  EssentialFeedPracticeiOSTests
//
//  Created by Tsz-Lung on 01/10/2023.
//

import Foundation
import XCTest
import EssentialFeedPractice

extension FeedUIIntegrationTests {
    var loadError: String {
        LoadResourcePresenter<Any, DummyView>.loadError
    }
    
    private class DummyView: ResourceView {
        func display(_ viewModel: Any) {}
    }
    
    var feedTitle: String {
        FeedPresenter.title
    }
}
