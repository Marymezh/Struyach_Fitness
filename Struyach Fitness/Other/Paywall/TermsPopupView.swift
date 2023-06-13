//
//  TermsPopupView.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 31/5/23.
//

import UIKit

final class TermsPopupView: UIView {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.toAutoLayout()
        return view
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Close".localized(), for: .normal)
        button.setTitleColor(.systemGreen, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.textAlignment = .center
        button.toAutoLayout()
        return button
    }()
    
    private let termsLabel: UILabel = {
        let label = UILabel()
        label.text = "Terms of Use"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .justified
        label.numberOfLines = 0
        label.toAutoLayout()
        return label
    }()
    
    init(termsText: String) {
        super.init(frame: .zero)
        
        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        addSubviews(containerView)
        
        containerView.addSubview(termsLabel)
        containerView.addSubview(closeButton)
        
        let constraints = [
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 300),
            
            termsLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            termsLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            termsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            closeButton.topAnchor.constraint(equalTo: termsLabel.bottomAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            closeButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        termsLabel.text = termsText
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func closeButtonTapped() {
        removeFromSuperview()
    }
}
