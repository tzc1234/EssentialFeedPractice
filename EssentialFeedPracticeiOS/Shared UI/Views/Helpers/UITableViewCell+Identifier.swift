//
//  UITableViewCell+Identifier.swift
//  EssentialFeedPracticeiOS
//
//  Created by Tsz-Lung on 27/10/2023.
//

import UIKit

extension UITableViewCell {
    public static var identifier: String {
        "\(String(describing: Self.self))"
    }
}
