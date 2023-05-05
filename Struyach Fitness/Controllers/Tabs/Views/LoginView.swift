//
//  LoginView.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 24/4/23.
//

import UIKit

final class LoginView: UIView {
    
    //MARK: - Properties
    
    let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "struyach-eng-black"))
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.toAutoLayout()
        return imageView
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
    
    init() {
        super.init(frame: .zero)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        
        self.addSubviews(logoImageView, autorizationView, logInButton, createAccountButton)
        autorizationView.addSubviews(emailTextField, passwordTextField)
        
        let constraints = [
            logoImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            logoImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 274),
            logoImageView.heightAnchor.constraint(equalToConstant: 261),
            
            autorizationView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 10),
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
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
