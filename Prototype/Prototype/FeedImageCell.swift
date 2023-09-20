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
    
    private(set) lazy var imageContainerView: UIView = {
        let v = UIView()
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
    }
    
    required init?(coder: NSCoder) { nil }
    
    private func configureLayout() {
        pinBackgroundView.addSubview(pinImageView)
        imageContainerView.addSubview(feedImageView)
        
        locationContainer.addArrangedSubview(pinBackgroundView)
        locationContainer.addArrangedSubview(locationLabel)
        
        outmostStackView.addArrangedSubview(locationContainer)
        outmostStackView.addArrangedSubview(imageContainerView)
        outmostStackView.addArrangedSubview(descriptionLabel)
        contentView.addSubview(outmostStackView)
        
        let outmostTop = outmostStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6)
        outmostTop.priority = .init(999)
        let outmostBottom = outmostStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        outmostBottom.priority = .init(999)
        
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
            
            imageContainerView.leadingAnchor.constraint(equalTo: feedImageView.leadingAnchor),
            imageContainerView.trailingAnchor.constraint(equalTo: feedImageView.trailingAnchor),
            imageContainerView.topAnchor.constraint(equalTo: feedImageView.topAnchor),
            imageContainerView.bottomAnchor.constraint(equalTo: feedImageView.bottomAnchor),
            imageContainerView.widthAnchor.constraint(equalTo: outmostStackView.widthAnchor),
            
            outmostStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            outmostStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            outmostTop,
            outmostBottom
        ])
    }
}
