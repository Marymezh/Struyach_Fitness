//
//  LoginView.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 10/2/23.
//

import UIKit

class LoginView: UIView {

    private let logoImageView: UIImageView = {
        #if Admin
        let imageView = UIImageView(image: UIImage(named: "struyach-eng-black"))
        #else
        let imageView = UIImageView(image: UIImage(named: "struyach-eng-white"))
        #endif
        
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.toAutoLayout()
        return imageView
    }()
    
    private let autorizationView: UIView = {
        let autorizationView = UIView()
        autorizationView.backgroundColor = .lightGray
        autorizationView.layer.borderWidth = 0.5
        autorizationView.layer.borderColor = UIColor.lightGray.cgColor
        autorizationView.layer.cornerRadius = 10
        autorizationView.clipsToBounds = true
        autorizationView.toAutoLayout()
        return autorizationView
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = .black
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField .frame.height))
        textField.leftViewMode = .always
        textField.tintColor = .systemGray
        textField.autocapitalizationType = .none
        textField.backgroundColor = .systemGray6
        textField.clipsToBounds = true
        textField.placeholder = "Email"
        textField.returnKeyType = UIReturnKeyType.done
        textField.toAutoLayout()
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = .black
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField .frame.height))
        textField.leftViewMode = .always
        textField.tintColor = UIColor(named:"myColorSet")
        textField.autocapitalizationType = .none
        textField.backgroundColor = .systemGray6
        textField.clipsToBounds = true
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.returnKeyType = UIReturnKeyType.done
        textField.toAutoLayout()
        return textField
    }()
    
    private lazy var logInButton: UIButton = {
        let button = UIButton ()
        button.toAutoLayout()
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.backgroundColor = .systemGray
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        return button
    }()
    
    @objc private func loginTapped() {
        
    }
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton ()
        button.toAutoLayout()
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.backgroundColor = .systemGray2
        button.setTitle("Sign up", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(signupTapped), for: .touchUpInside)
        return button
    }()
    
    @objc private func signupTapped() {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI() 
        
    }
    
    private func setupUI() {
        self.addSubviews(logoImageView, autorizationView, logInButton, signUpButton)
        autorizationView.addSubviews(emailTextField, passwordTextField)
        
        let constraints = [
            logoImageView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 5),
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
            
            signUpButton.topAnchor.constraint(equalTo: logInButton.bottomAnchor, constant: 10),
            signUpButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            signUpButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            signUpButton.heightAnchor.constraint(equalTo: logInButton.heightAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }

}
