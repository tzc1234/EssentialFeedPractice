//
//  UIImageView+Animations.swift
//  EssentialFeedPracticeiOS
//
//  Created by Tsz-Lung on 10/10/2023.
//

import UIKit

extension UIImageView {
    func setImage(_ newImage: UIImage?) {
        image = newImage
        
        guard newImage != nil else { return }
        
        alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
}
