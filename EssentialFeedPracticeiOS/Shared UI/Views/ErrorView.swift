//
//  ErrorView.swift
//  EssentialFeedPracticeiOS
//
//  Created by Tsz-Lung on 03/10/2023.
//

import UIKit

public final class ErrorView: UIButton {
    public var message: String? {
        get { isVisible ? title(for: .normal) : nil }
        set { setMessageAnimated(newValue) }
    }
    
    private var isVisible: Bool {
        alpha > 0
    }
    
    public var onHide: (() -> Void)?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) { nil }
    
    private func configure() {
        titleLabel?.numberOfLines = 0
        titleLabel?.textAlignment = .center
        setTitleColor(.white, for: .normal)
        backgroundColor = .errorBackground
        addTarget(self, action: #selector(hideMessageAnimated), for: .touchUpInside)
        
        hideMessage()
    }
    
    private func setMessageAnimated(_ message: String?) {
        if let message {
            showAnimated(message)
        } else {
            hideMessageAnimated()
        }
    }
    
    private func showAnimated(_ message: String?) {
        setTitle(message, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 18)
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
    
    @objc private func hideMessageAnimated() {
        UIView.animate(
            withDuration: 0.25,
            animations: { self.alpha = 0 },
            completion: { completed in
                if completed {
                    self.hideMessage()
                }
            })
    }
    
    private func hideMessage() {
        alpha = 0
        setTitle(nil, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 0)
        onHide?()
    }
}

extension UIColor {
    static var errorBackground: UIColor {
        UIColor(red: 0.99951404330000004, green: 0.41759261489999999, blue: 0.4154433012, alpha: 1)
    }
}
