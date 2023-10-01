//
//  UIControl+TestHelpers.swift
//  EssentialFeedPracticeiOSTests
//
//  Created by Tsz-Lung on 23/09/2023.
//

import UIKit

extension UIControl {
    func simulate(event: UIControl.Event) {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: event)?.forEach { action in
                (target as NSObject).perform(Selector(action))
            }
        }
    }
}
