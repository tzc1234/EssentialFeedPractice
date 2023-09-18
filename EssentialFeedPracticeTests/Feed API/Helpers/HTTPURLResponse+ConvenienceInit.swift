//
//  HTTPURLResponse+ConvenienceInit.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 18/09/2023.
//

import Foundation

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
