//
//  RestorePasswordView.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 7/6/23.
//

import UIKit

final class RestorePasswordView: UIView {

    //MARK: - Properties
    
    let closeButton: UIButton = {
        let button = UIButton()
        button.toAutoLayout()
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.tintColor = .white
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        return button
    }()
    
    let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "lock.circle"))
        imageView.tintColor = .systemGreen
        imageView.layer.cornerRadius = 160/2
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.toAutoLayout()
        return imageView
    }()
    
    let instructionLabel: UILabel = {
        let label = UILabel()
        label.toAutoLayout()
        label.backgroundColor = .black
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.textAlignment = .justified
        label.numberOfLines = 0
        label.text = "To restore your forgotten password please enter the email address of the registered user. You will receive an email with further instructions.".localized()
        return label
    }()
    
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField .frame.height))
        textField.leftViewMode = .always
        textField.layer.cornerRadius = 10
        textField.clipsToBounds = true
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor.lightGray.cgColor
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
    
    let sendButton: UIButton = {
        let button = UIButton ()
        button.toAutoLayout()
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.backgroundColor = .systemGreen
        button.setTitle("Send".localized(), for: .normal)
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
        self.backgroundColor = .black
        self.addSubviews(closeButton, logoImageView, instructionLabel, emailTextField, sendButton)
        
        let constraints = [
            closeButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            closeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            closeButton.widthAnchor.constraint(equalTo: closeButton.heightAnchor),
            
            logoImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            logoImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 160),
            logoImageView.heightAnchor.constraint(equalToConstant: 160),
            
            instructionLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 50),
            instructionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            instructionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            
            emailTextField.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 50),
            emailTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            emailTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            sendButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 30),
            sendButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            sendButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            sendButton.heightAnchor.constraint(equalToConstant: 50)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
