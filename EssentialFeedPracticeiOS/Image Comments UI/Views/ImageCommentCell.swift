//
//  ImageCommentCell.swift
//  EssentialFeedPracticeiOS
//
//  Created by Tsz-Lung on 27/10/2023.
//

import UIKit

public final class ImageCommentCell: UITableViewCell {
    private lazy var outmostStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 8
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private lazy var usernameDateStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 6
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    public private(set) lazy var messageLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .preferredFont(forTextStyle: .body)
        lbl.adjustsFontForContentSizeCategory = true
        lbl.numberOfLines = 0
        lbl.textColor = .label
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    public private(set) lazy var usernameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .preferredFont(forTextStyle: .headline)
        lbl.adjustsFontForContentSizeCategory = true
        lbl.numberOfLines = 1
        lbl.textColor = .label
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        lbl.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return lbl
    }()
    
    public private(set) lazy var dateLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .preferredFont(forTextStyle: .subheadline)
        lbl.adjustsFontForContentSizeCategory = true
        lbl.numberOfLines = 1
        lbl.textColor = .secondaryLabel
        lbl.textAlignment = .right
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.setContentHuggingPriority(.defaultLow, for: .horizontal)
        lbl.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        configureLayout()
    }
    
    required init?(coder: NSCoder) { nil }
    
    private func configureLayout() {
        usernameDateStackView.addArrangedSubview(usernameLabel)
        usernameDateStackView.addArrangedSubview(dateLabel)
        
        outmostStackView.addArrangedSubview(usernameDateStackView)
        outmostStackView.addArrangedSubview(messageLabel)
        contentView.addSubview(outmostStackView)
        
        NSLayoutConstraint.activate([
            outmostStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            outmostStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            outmostStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            outmostStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        ])
    }
}
