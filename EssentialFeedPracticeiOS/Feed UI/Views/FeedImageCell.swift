//
//  FeedImageCell.swift
//  EssentialFeedPracticeiOS
//
//  Created by Tsz-Lung on 22/09/2023.
//

import UIKit

public final class FeedImageCell: UITableViewCell {
    static var identifier: String { "\(String(describing: Self.self))" }
    
    public let locationContainer = UIView()
    public let locationLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let feedImageContainer = ShimmeringView()
    public let feedImageView = UIImageView()
    public lazy var feedImageRetryButton: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    var onRetry: (() -> Void)?
    
    @objc private func retryButtonTapped() {
        onRetry?()
    }
}