//
//  ErrorView.swift
//  EssentialFeedPracticeiOS
//
//  Created by Tsz-Lung on 03/10/2023.
//

import UIKit

public final class ErrorView: UIView {
    public private(set) lazy var button: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return btn
    }()
    
    public var message: String? {
        get { button.title(for: .normal) }
        set { button.setTitle(newValue, for: .normal) }
    }
    
    @objc private func buttonTapped() {
        button.setTitle(nil, for: .normal)
    }
}
