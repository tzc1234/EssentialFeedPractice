//
//  ImageCommentsLocalisationTests.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 26/10/2023.
//

import XCTest
import EssentialFeedPractice

final class ImageCommentsLocalisationTests: XCTestCase {
    func test_localisedStrings_haveKeysAndValuesForAllSupportedLocalisations() {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        assertLocalisedKeyAndValuesExist(in: bundle, table)
    }
}
