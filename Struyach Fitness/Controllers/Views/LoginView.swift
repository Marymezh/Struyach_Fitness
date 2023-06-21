//
//  LoginView.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 24/4/23.
//

import UIKit

final class LoginView: UIView {
    
    //MARK: - Properties
    
    weak var delegate: LanguageSwitchDelegate?
    
    private lazy var engButton: UIButton = {
        let button = UIButton()
        button.toAutoLayout()
        button.setTitle(Language.english.rawValue, for: .normal)
        button.addTarget(self, action: #selector(switchLanguage(_:)), for: .touchUpInside)
        button.tag = Language.english.rawValue.hashValue
        return button
    }()
    
    private lazy var rusButton: UIButton = {
        let button = UIButton()
        button.toAutoLayout()
        button.setTitle(Language.russian.rawValue, for: .normal)
        button.addTarget(self, action: #selector(switchLanguage(_:)), for: .touchUpInside)
        button.tag = Language.russian.rawValue.hashValue
        return button
    }()
    
    let autorizationView: UIView = {
        let autorizationView = UIView()
        autorizationView.backgroundColor = .lightGray
        autorizationView.layer.borderWidth = 0.5
        autorizationView.layer.borderColor = UIColor.lightGray.cgColor
        autorizationView.layer.cornerRadius = 10
        autorizationView.clipsToBounds = true
        autorizationView.toAutoLayout()
        return autorizationView
    }()
    
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField .frame.height))
        textField.leftViewMode = .always
        textField.tintColor = .systemGray
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.backgroundColor = .systemGray6
        textField.clipsToBounds = true
        textField.placeholder = "Email"
        textField.keyboardType = .emailAddress
        textField.toAutoLayout()
        return textField
    }()
    
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField .frame.height))
        textField.leftViewMode = .always
        textField.tintColor = .systemGray
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.backgroundColor = .systemGray6
        textField.clipsToBounds = true
        textField.placeholder = "Password".localized()
        textField.isSecureTextEntry = true
        textField.toAutoLayout()
        return textField
    }()
    
    let logInButton: UIButton = {
        let button = UIButton ()
        button.toAutoLayout()
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.backgroundColor = .systemGreen
        button.setTitle("Log In".localized(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    let createAccountButton: UIButton = {
        let button = UIButton ()
        button.toAutoLayout()
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.backgroundColor = .systemGray
        button.setTitle("Create new account".localized(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    let restorePasswordButton: UIButton = {
        let button = UIButton ()
        button.toAutoLayout()
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.backgroundColor = .systemGray2
        button.setTitle("Forgot password".localized(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    let privacyPolicyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Please read and agree to our Privacy Policy to proceed".localized()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .systemGreen
        label.textAlignment = .center
        label.isUserInteractionEnabled = true 
        label.toAutoLayout()
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        let attributedString = NSAttributedString(string: "Please read and agree to our Privacy Policy to proceed".localized(), attributes: underlineAttribute)
        privacyPolicyLabel.attributedText = attributedString
        
        self.addSubviews( engButton, rusButton, autorizationView, logInButton, createAccountButton, restorePasswordButton, privacyPolicyLabel)
        autorizationView.addSubviews(emailTextField, passwordTextField)
        
        let constraints = [
            engButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            engButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            
            rusButton.trailingAnchor.constraint(equalTo: engButton.leadingAnchor, constant: -5),
            rusButton.topAnchor.constraint(equalTo: engButton.topAnchor),
            
            autorizationView.topAnchor.constraint(equalTo: self.topAnchor, constant: 100),
            autorizationView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            autorizationView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            autorizationView.heightAnchor.constraint(equalToConstant: 100),
            
            emailTextField.topAnchor.constraint(equalTo: autorizationView.topAnchor),
            emailTextField.leadingAnchor.constraint(equalTo: autorizationView.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: autorizationView.trailingAnchor),
            emailTextField.heightAnchor.constraint(equalToConstant: 49.7),
            
            passwordTextField.bottomAnchor.constraint(equalTo: autorizationView.bottomAnchor),
            passwordTextField.leadingAnchor.constraint(equalTo: autorizationView.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: autorizationView.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 49.7),
            
            logInButton.topAnchor.constraint(equalTo: autorizationView.bottomAnchor, constant: 30),
            logInButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            logInButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            logInButton.heightAnchor.constraint(equalToConstant: 50),
            
            createAccountButton.topAnchor.constraint(equalTo: logInButton.bottomAnchor, constant: 10),
            createAccountButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            createAccountButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            createAccountButton.heightAnchor.constraint(equalTo: logInButton.heightAnchor),
            
            restorePasswordButton.topAnchor.constraint(equalTo: createAccountButton.bottomAnchor, constant: 10),
            restorePasswordButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            restorePasswordButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            restorePasswordButton.heightAnchor.constraint(equalTo: logInButton.heightAnchor),
            
            privacyPolicyLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16),
            privacyPolicyLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            privacyPolicyLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func configure(language: Language) {

        engButton.isSelected = (language == .english)
        rusButton.isSelected = (language == .russian)
        
        // Set the button labels based on selected state
        let normalAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.white    ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 16), .foregroundColor: UIColor.systemGreen]
        engButton.setAttributedTitle(NSAttributedString(string: "en", attributes: engButton.isSelected ? selectedAttributes : normalAttributes), for: .normal)
        rusButton.setAttributedTitle(NSAttributedString(string: "ru", attributes: rusButton.isSelected ? selectedAttributes : normalAttributes), for: .normal)
    }
    
    @objc func switchLanguage(_ sender: UIButton) {
        let language: Language = sender.tag == Language.english.rawValue.hashValue ? .english : .russian
   
        if language == .english && engButton.isSelected {
            return
        } else if language == .russian && rusButton.isSelected {
            return
        }
        delegate?.didSwitchLanguage(to: language)
    }
}
