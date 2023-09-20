//
//  FeedImageCell.swift
//  Prototype
//
//  Created by Tsz-Lung on 20/09/2023.
//

import UIKit

class FeedImageCell: UITableViewCell {
    private(set) lazy var outmostStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 10
        sv.alignment = .leading
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private(set) lazy var locationContainer: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 6
        sv.alignment = .top
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private(set) lazy var pinBackgroundView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private(set) lazy var pinImageView: UIImageView = {
        let image = UIImage(named: "pin")
        let iv = UIImageView(image: image)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private(set) lazy var locationLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Location,\nLocation"
        lbl.font = .systemFont(ofSize: 15)
        lbl.numberOfLines = 0
        lbl.textColor = .systemGray3
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private(set) lazy var imageContainer: ShimmeringView = {
        let v = ShimmeringView()
        v.backgroundColor = .systemGray4
        v.layer.cornerRadius = 22
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private(set) lazy var feedImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private(set) lazy var descriptionLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Description Description Description Description Description Description Description Description Description Description Description Description Description Description Description Description Description Description Description Description Description Description Description Description Description Description Description"
        lbl.font = .systemFont(ofSize: 16)
        lbl.numberOfLines = 0
        lbl.textColor = .systemGray3
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        configureLayout()
        beginLoading()
    }
    
    required init?(coder: NSCoder) { nil }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        beginLoading()
    }
    
    private func beginLoading() {
        feedImageView.alpha = 0
        imageContainer.startShimmering()
    }
    
    private func configureLayout() {
        pinBackgroundView.addSubview(pinImageView)
        imageContainer.addSubview(feedImageView)
        
        locationContainer.addArrangedSubview(pinBackgroundView)
        locationContainer.addArrangedSubview(locationLabel)
        
        outmostStackView.addArrangedSubview(locationContainer)
        outmostStackView.addArrangedSubview(imageContainer)
        outmostStackView.addArrangedSubview(descriptionLabel)
        contentView.addSubview(outmostStackView)
        
        NSLayoutConstraint.activate([
            pinImageView.widthAnchor.constraint(equalToConstant: 10),
            pinImageView.heightAnchor.constraint(equalToConstant: 14),
            pinImageView.topAnchor.constraint(equalTo: pinBackgroundView.topAnchor, constant: 3),
            
            pinBackgroundView.leadingAnchor.constraint(equalTo: pinImageView.leadingAnchor),
            pinBackgroundView.trailingAnchor.constraint(equalTo: pinImageView.trailingAnchor),
            pinBackgroundView.topAnchor.constraint(equalTo: locationContainer.topAnchor),
            pinBackgroundView.bottomAnchor.constraint(equalTo: locationContainer.bottomAnchor),
            
            locationContainer.widthAnchor.constraint(equalTo: outmostStackView.widthAnchor),
            
            feedImageView.widthAnchor.constraint(equalTo: feedImageView.heightAnchor),
            
            imageContainer.leadingAnchor.constraint(equalTo: feedImageView.leadingAnchor),
            imageContainer.trailingAnchor.constraint(equalTo: feedImageView.trailingAnchor),
            imageContainer.topAnchor.constraint(equalTo: feedImageView.topAnchor),
            imageContainer.bottomAnchor.constraint(equalTo: feedImageView.bottomAnchor),
            imageContainer.widthAnchor.constraint(equalTo: outmostStackView.widthAnchor),
            
            outmostStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            outmostStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            outmostStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6)
                .set { $0.priority = .init(999) },
            outmostStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
                .set { $0.priority = .init(999) }
        ])
    }
    
    func fadeIn(_ image: UIImage?) {
        feedImageView.image = image
        
        UIView.animate(
            withDuration: 0.25,
            delay: 1.25,
            options: [],
            animations: {
                self.feedImageView.alpha = 1
            }, completion: { completed in
                if completed {
                    self.imageContainer.stopShimmering()
                }
            })
    }
}

private extension NSLayoutConstraint {
    func set(_ action: (NSLayoutConstraint) -> Void) -> NSLayoutConstraint {
        action(self)
        return self
    }
}
