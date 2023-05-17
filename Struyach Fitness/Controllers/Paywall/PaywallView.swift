//
//  PaywallView.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 25/4/23.
//

import UIKit
import SwiftUI

final class PaywallView: UIView {
    
    //MARK: - Properties
    
    private var smallInset: CGFloat { return 16 }
    private var bigInset: CGFloat { return 32 }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.systemGreen
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.toAutoLayout()
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .justified
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.toAutoLayout()
        return label
    }()
    
    let payButton: UIButton = {
        let button = UIButton(type: .system)
        button.toAutoLayout()
        button.backgroundColor = UIColor.systemGreen
        button.layer.cornerRadius = 8
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return button
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.toAutoLayout()
        return label
    }()
    
    let cancellationLabel: UILabel = {
        let label = UILabel()
        label.toAutoLayout()
        label.text = "This is an auto-renewable subscription. It will be charged to your Appstore account after trial and before each pay period. You can cancel anytime by going into your Settings -> Apple ID -> Subscriptions. Restore purchases if previously subscribed.".localized()
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        label.textAlignment = .justified
        label.font = UIFont.systemFont(ofSize: 12)
        label.isUserInteractionEnabled = false
        label.numberOfLines = 0
        return label
    }()
    
    private let termsLabel: UILabel = {
        let label = UILabel()
        label.toAutoLayout()
        label.text = "Terms of use".localized()
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(openTermsOfUse))
           
    
    let restorePurchasesButton: UIButton = {
        let button = UIButton()
        button.setTitle("Restore purchases".localized(), for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.toAutoLayout()
        return button
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .bottom
        stackView.toAutoLayout()
        return stackView
    }()
    
    //MARK: - Lifecycle
    
    init() {
        super.init(frame: .zero)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: setup
    
    private func setupSubviews() {
        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        let underlineAttributedString = NSAttributedString(string: "Terms of use".localized(), attributes: underlineAttribute)
        termsLabel.attributedText = underlineAttributedString
        termsLabel.addGestureRecognizer(tapGesture)
        
        addSubviews(titleLabel, descriptionLabel, payButton, priceLabel, cancellationLabel, stackView)
  
        stackView.addArrangedSubview(termsLabel)
        stackView.addArrangedSubview(restorePurchasesButton)
        
        let constraints = [
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: bigInset),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: smallInset),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -smallInset),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: bigInset),
            descriptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: smallInset),
            descriptionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -smallInset),
            
            payButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: bigInset),
            payButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            payButton.widthAnchor.constraint(lessThanOrEqualToConstant: 300),
            
            priceLabel.topAnchor.constraint(equalTo: payButton.bottomAnchor, constant: smallInset),
            priceLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: smallInset),
            priceLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -smallInset),
            
            cancellationLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: bigInset),
            cancellationLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: smallInset),
            cancellationLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -smallInset),
            
            stackView.topAnchor.constraint(equalTo: cancellationLabel.bottomAnchor, constant: smallInset),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: smallInset),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -smallInset),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -bigInset),

            payButton.heightAnchor.constraint(equalToConstant: 60),
            
            restorePurchasesButton.heightAnchor.constraint(equalToConstant: 40),
            termsLabel.heightAnchor.constraint(equalToConstant: 40)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc private func openTermsOfUse() {
        if let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
            UIApplication.shared.open(url)
        }
    }
    
}
