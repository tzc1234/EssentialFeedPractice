//
//  ImageCommentCell+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Tsz-Lung on 30/10/2023.
//

import UIKit
import EssentialFeedPracticeiOS

extension ImageCommentCell {
    var messageText: String? {
        messageLabel.text
    }
    
    var usernameText: String? {
        usernameLabel.text
    }
    
    var dateText: String? {
        dateLabel.text
    }
}
