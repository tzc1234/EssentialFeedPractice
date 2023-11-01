//
//  LoadMoreCell.swift
//  EssentialFeedPracticeiOS
//
//  Created by Tsz-Lung on 31/10/2023.
//

import UIKit

public class LoadMoreCell: UITableViewCell {
    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(spinner)
        
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])
        
        return spinner
    }()
    
    private lazy var messageLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .tertiaryLabel
        lbl.font = .preferredFont(forTextStyle: .footnote)
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        lbl.adjustsFontForContentSizeCategory = true
        lbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(lbl)
        
        NSLayoutConstraint.activate([
            lbl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            lbl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            lbl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            lbl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        return lbl
    }()
    
    public var isLoading: Bool {
        get { spinner.isAnimating }
        set {
            if newValue {
                spinner.startAnimating()
            } else {
                spinner.stopAnimating()
            }
        }
    }
    
    public var message: String? {
        get { messageLabel.text }
        set { messageLabel.text = newValue }
    }
}
