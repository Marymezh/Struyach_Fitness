//
//  SignUpView.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 24/4/23.
//

import UIKit

class SignUpView: UIView {
    
    //MARK: - Properties
    
    let avatarImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "person.circle"))
        imageView.layer.cornerRadius = 160/2
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.tintColor = .systemGreen
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
    
    let userNameTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField .frame.height))
        textField.leftViewMode = .always
        textField.tintColor = .systemGray
        textField.autocapitalizationType = .words
        textField.backgroundColor = .systemGray6
        textField.clipsToBounds = true
        textField.placeholder = "Full name"
        textField.toAutoLayout()
        return textField
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
        textField.placeholder = "Password (minimum 6 symbols)"
        textField.isSecureTextEntry = true
        textField.toAutoLayout()
        return textField
    }()
    
    let confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField .frame.height))
        textField.leftViewMode = .always
        textField.tintColor = .systemGray
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.backgroundColor = .systemGray6
        textField.clipsToBounds = true
        textField.placeholder = "Confirm password"
        textField.isSecureTextEntry = true
        textField.toAutoLayout()
        return textField
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton ()
        button.toAutoLayout()
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.backgroundColor = .systemGreen
        button.setTitle("Create", for: .normal)
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

        self.addSubviews(avatarImageView,
                         autorizationView,
                         signUpButton)
        autorizationView.addSubviews(userNameTextField,
                                     emailTextField,
                                     passwordTextField,
                                     confirmPasswordTextField)
        
        let constraints = [
            avatarImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            avatarImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 160),
            avatarImageView.heightAnchor.constraint(equalToConstant: 160),
            
            autorizationView.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 20),
            autorizationView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            autorizationView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            autorizationView.heightAnchor.constraint(equalToConstant: 200),
            
            userNameTextField.topAnchor.constraint(equalTo: autorizationView.topAnchor),
            userNameTextField.leadingAnchor.constraint(equalTo: autorizationView.leadingAnchor),
            userNameTextField.trailingAnchor.constraint(equalTo: autorizationView.trailingAnchor),
            userNameTextField.heightAnchor.constraint(equalToConstant: 49.7),
            
            emailTextField.topAnchor.constraint(equalTo: userNameTextField.bottomAnchor, constant: 0.5),
            emailTextField.leadingAnchor.constraint(equalTo: autorizationView.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: autorizationView.trailingAnchor),
            emailTextField.heightAnchor.constraint(equalToConstant: 49.7),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 0.5),
            passwordTextField.leadingAnchor.constraint(equalTo: autorizationView.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: autorizationView.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 49.7),
            
            confirmPasswordTextField.bottomAnchor.constraint(equalTo: autorizationView.bottomAnchor),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: autorizationView.leadingAnchor),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: autorizationView.trailingAnchor),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 49.7),
            
            signUpButton.topAnchor.constraint(equalTo: autorizationView.bottomAnchor, constant: 30),
            signUpButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            signUpButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            signUpButton.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }

}
