//
//  SharedLocalisationTests.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 25/10/2023.
//

import XCTest
import EssentialFeedPractice

final class SharedLocalisationTests: XCTestCase {
    func test_localisedStrings_haveKeysAndValuesForAllSupportedLocalisations() {
        let table = "Shared"
        let bundle = Bundle(for: LoadResourcePresenter<Any, DummyView>.self)
        assertLocalisedKeyAndValuesExist(in: bundle, table)
    }
    
    private class DummyView: ResourceView {
        func display(_ viewModel: Any) {}
    }
}
