//
//  FeedImageCell.swift
//  EssentialFeedPracticeiOS
//
//  Created by Tsz-Lung on 22/09/2023.
//

import UIKit

public final class FeedImageCell: UITableViewCell {
    private lazy var outmostStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 10
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    public private(set) lazy var locationContainer: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 6
        sv.alignment = .top
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private lazy var pinBackgroundView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private lazy var pinImageView: UIImageView = {
        let image = UIImage(named: "pin", in: Bundle(for: Self.self), with: .none)
        let iv = UIImageView(image: image)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    public private(set) lazy var locationLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .preferredFont(forTextStyle: .subheadline)
        lbl.adjustsFontForContentSizeCategory = true
        lbl.numberOfLines = 0
        lbl.textColor = .secondaryLabel
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    public private(set) lazy var feedImageContainer: ShimmeringView = {
        let v = ShimmeringView()
        v.backgroundColor = .secondaryLabel
        v.layer.cornerRadius = 22
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    public private(set) lazy var feedImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isAccessibilityElement = true
        return iv
    }()
    
    public private(set) lazy var descriptionLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .preferredFont(forTextStyle: .body)
        lbl.adjustsFontForContentSizeCategory = true
        lbl.numberOfLines = 0
        lbl.textColor = .secondaryLabel
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    public private(set) lazy var feedImageRetryButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("↻", for: .normal)
        btn.setTitleColor(.systemBackground, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 60)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    var onRetry: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        configureLayout()
    }
    
    required init?(coder: NSCoder) { nil }
    
    private func configureLayout() {
        pinBackgroundView.addSubview(pinImageView)
        feedImageContainer.addSubview(feedImageView)
        feedImageContainer.addSubview(feedImageRetryButton)
        
        locationContainer.addArrangedSubview(pinBackgroundView)
        locationContainer.addArrangedSubview(locationLabel)
        
        outmostStackView.addArrangedSubview(locationContainer)
        outmostStackView.addArrangedSubview(feedImageContainer)
        outmostStackView.addArrangedSubview(descriptionLabel)
        contentView.addSubview(outmostStackView)
        
        NSLayoutConstraint.activate([
            pinImageView.widthAnchor.constraint(equalToConstant: 10),
            pinImageView.heightAnchor.constraint(equalToConstant: 14),
            pinImageView.topAnchor.constraint(equalTo: pinBackgroundView.topAnchor, constant: 3),
            
            pinBackgroundView.leadingAnchor.constraint(equalTo: pinImageView.leadingAnchor),
            pinBackgroundView.trailingAnchor.constraint(equalTo: pinImageView.trailingAnchor),
            
            feedImageView.widthAnchor.constraint(equalTo: feedImageView.heightAnchor),
            
            feedImageContainer.leadingAnchor.constraint(equalTo: feedImageView.leadingAnchor),
            feedImageContainer.trailingAnchor.constraint(equalTo: feedImageView.trailingAnchor),
            feedImageContainer.topAnchor.constraint(equalTo: feedImageView.topAnchor),
            feedImageContainer.bottomAnchor.constraint(equalTo: feedImageView.bottomAnchor),
            
            feedImageRetryButton.leadingAnchor.constraint(equalTo: feedImageContainer.leadingAnchor),
            feedImageRetryButton.trailingAnchor.constraint(equalTo: feedImageContainer.trailingAnchor),
            feedImageRetryButton.topAnchor.constraint(equalTo: feedImageContainer.topAnchor),
            feedImageRetryButton.bottomAnchor.constraint(equalTo: feedImageContainer.bottomAnchor),
            
            outmostStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            outmostStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            outmostStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6).prioritised(999),
            outmostStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6).prioritised(999)
        ])
    }
    
    @objc private func retryButtonTapped() {
        onRetry?()
    }
}
