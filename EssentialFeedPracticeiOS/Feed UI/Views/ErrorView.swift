//
//  ErrorView.swift
//  EssentialFeedPracticeiOS
//
//  Created by Tsz-Lung on 03/10/2023.
//

import UIKit

public final class ErrorView: UIButton {
    public var message: String? {
        get { title(for: .normal) }
        set { setTitle(newValue, for: .normal) }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) { nil }
    
    private func configure() {
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc private func buttonTapped() {
        setTitle(nil, for: .normal)
    }
}
