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
    
    private let backgroundView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.alpha = 0.3
        view.toAutoLayout()
        return view
    }()
    
    let closeButton: UIButton = {
        let button = UIButton()
        button.toAutoLayout()
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.tintColor = .white
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        return button
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = ColorManager.shared.appColor
        label.font = UIFont.boldSystemFont(ofSize: 26)
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
        button.backgroundColor = ColorManager.shared.appColor
        button.layer.cornerRadius = 8
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 8
        button.layer.shadowOffset = CGSize(width: 1, height: 1)
        button.clipsToBounds = false
        button.layer.shadowOpacity = 0.5
        button.setTitle("Loading price and terms...".localized(), for: .normal)
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
        label.numberOfLines = 0
        label.toAutoLayout()
        return label
    }()
    
    let codeTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField .frame.height))
        textField.leftViewMode = .always
        textField.tintColor = .systemGray
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.backgroundColor = .systemGray6
        textField.clipsToBounds = true
        textField.layer.cornerRadius = 5
        textField.placeholder = "Enter promo code".localized()
        textField.isHidden = true
        textField.toAutoLayout()
        return textField
    }()
    
    let redeemCodeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "Redeem promo code".localized()
        label.textAlignment = .center
        label.numberOfLines = 1
        label.isUserInteractionEnabled = true
        label.isHidden = true
        label.toAutoLayout()
        return label
    }()
    
    let termsLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .justified
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.toAutoLayout()
        return label
    }()
    
    let termsLinkLabel: UILabel = {
        let label = UILabel()
        label.textColor = ColorManager.shared.appColor
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 1
        label.toAutoLayout()
        return label
    }()
   
    //MARK: - Lifecycle
    
    init() {
        super.init(frame: .zero)
        setupSubviews()
        setupGestureRecognizer()
        randomizeBackgroungImages()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: setup
    
    private func setupSubviews() {
        backgroundColor = .black
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        let codeAttributedString = NSAttributedString(string: "Redeem promo code".localized(), attributes: underlineAttribute)
        let termsAttributedString = NSAttributedString(string: "Terms of Use".localized(), attributes: underlineAttribute)
        
        
        redeemCodeLabel.attributedText = codeAttributedString
        termsLinkLabel.attributedText = termsAttributedString
        codeTextField.delegate = self
        addSubviews(backgroundView, closeButton, titleLabel, descriptionLabel, payButton, priceLabel, codeTextField, redeemCodeLabel, termsLabel, termsLinkLabel)
        
        let constraints = [
            backgroundView.topAnchor.constraint(equalTo: self.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            closeButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            closeButton.widthAnchor.constraint(equalTo: closeButton.heightAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: smallInset),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: smallInset),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -smallInset),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: smallInset),
            descriptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: smallInset),
            descriptionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -smallInset),
            
            payButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: bigInset),
            payButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            payButton.widthAnchor.constraint(lessThanOrEqualToConstant: 300),
            
            priceLabel.topAnchor.constraint(equalTo: payButton.bottomAnchor, constant: smallInset),
            priceLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: smallInset),
            priceLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -smallInset),
            
            codeTextField.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: smallInset),
            codeTextField.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            codeTextField.widthAnchor.constraint(equalToConstant: 220),
            codeTextField.heightAnchor.constraint(equalToConstant: 35),
            
            redeemCodeLabel.topAnchor.constraint(equalTo: codeTextField.bottomAnchor, constant: smallInset),
            redeemCodeLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: smallInset),
            redeemCodeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -smallInset),
            redeemCodeLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 30),
            
            termsLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: smallInset),
            termsLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -smallInset),
            termsLabel.bottomAnchor.constraint(equalTo: termsLinkLabel.topAnchor, constant: -15),
            
            termsLinkLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: smallInset),
            termsLinkLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -smallInset),
            termsLinkLabel.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -5)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func randomizeBackgroungImages () {
        let backgroundImages = ImageStorage.imageArray
        let randomIndex = Int.random(in: 0..<backgroundImages.count)
        if let backgroundImage = backgroundImages[randomIndex]
        {
            backgroundView.image = backgroundImage
        }
    }
    
    private func setupGestureRecognizer() {
        let redeemGesture = UITapGestureRecognizer(target: self, action: #selector(openAppStore))
        redeemCodeLabel.addGestureRecognizer(redeemGesture)
        let termsLinkTapGesture = UITapGestureRecognizer(target: self, action: #selector(openTermsOfUse))
        termsLinkLabel.addGestureRecognizer(termsLinkTapGesture)
    }
    
    @objc func openTermsOfUse() {
        if let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func openAppStore() {
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        
        print("Open App Store to redeem code")
        
        if let code = codeTextField.text, !code.isEmpty {
            if let url = URL(string: "https://apps.apple.com/redeem?ctx=offercodes&id=6448619309&code=\(code)") {
                UIApplication.shared.open(url, options: [:]) {[weak self] success in
                    guard let self = self else {return}
                    if !success {
                        self.codeTextField.text = "Failed to open URL".localized()
                    }
                }
            } else {
                self.codeTextField.text = "Invalid URL".localized()
            }
        } else {
            codeTextField.text = "This field can not be empty!".localized()
        }
    }

    @objc private func appWillResignActive() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        print("app active again")
        IAPManager.shared.syncPurchases { result in
            switch result {
            case .success:
                print ("Purchases synchronized")
                break
            case .failure(let error):
    
                print("Failed to sync purchases: \(error)")
            }
        }
    }
}

extension PaywallView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
            textField.text = ""
        }
}
