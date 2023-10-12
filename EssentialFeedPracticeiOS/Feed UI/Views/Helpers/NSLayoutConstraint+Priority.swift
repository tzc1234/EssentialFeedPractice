//
//  NSLayoutConstraint+Priority.swift
//  EssentialFeedPracticeiOS
//
//  Created by Tsz-Lung on 12/10/2023.
//

import UIKit

extension NSLayoutConstraint {
    func prioritised(_ priority: Float) -> NSLayoutConstraint {
        self.priority = .init(priority)
        return self
    }
}
