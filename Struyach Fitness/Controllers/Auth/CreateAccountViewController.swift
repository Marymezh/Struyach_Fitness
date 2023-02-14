//
//  CreateAccountViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit

class CreateAccountViewController: UIViewController {

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
    
    private let userNameTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = .black
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
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = .black
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
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = .black
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField .frame.height))
        textField.leftViewMode = .always
        textField.tintColor = .systemGray
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.backgroundColor = .systemGray6
        textField.clipsToBounds = true
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.toAutoLayout()
        return textField
    }()
    
    private let confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = .black
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
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton ()
        button.toAutoLayout()
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.backgroundColor = .systemGreen
        button.setTitle("Create", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        #if Admin
        view.backgroundColor = .black
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        #else
        view.backgroundColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        #endif
        
        setupSubviews()
        userNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
    }
    
    @objc private func signUpTapped() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = confirmPasswordTextField.text, !password.isEmpty,
              password == passwordTextField.text,
              let name = userNameTextField.text, !name.isEmpty else {return
   //         showErrorAlert(text: "Passwords are not matching")
        }
        
        //create User
        AuthManager.shared.signUp(email: email, password: password) { [weak self] success in
            if success {
                let newUser = User(name: name, email: email, profilePictureUrl: nil)
                DatabaseManager.shared.insertUser(user: newUser) { inserted in
                    guard inserted else {return}
                    
                    UserDefaults.standard.set(name, forKey: "userName")
                    UserDefaults.standard.set(email, forKey: "email")
                    DispatchQueue.main.async {
                        let vc = TabBarController()
                        vc.modalPresentationStyle = .fullScreen
                        self?.present(vc, animated: true)
                    }
                }
            } else {
                self?.showErrorAlert(text: "Can't create new account")
            }
        }
        //Update database
        
        
    }
    
    private func setupSubviews() {
        view.addSubviews(logoImageView,
                         autorizationView,
                         signUpButton)
        autorizationView.addSubviews(userNameTextField,
                                     emailTextField,
                                     passwordTextField,
                                     confirmPasswordTextField)
        
        let constraints = [
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 274),
            logoImageView.heightAnchor.constraint(equalToConstant: 261),
            
            autorizationView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 10),
            autorizationView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            autorizationView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
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
            signUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            signUpButton.heightAnchor.constraint(equalToConstant: 50),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func showErrorAlert(text: String) {
        let alert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.view.tintColor = .red
        alert.addAction(cancelAction)
        navigationController?.present(alert, animated: true)
    }
}

extension CreateAccountViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == confirmPasswordTextField {
            if textField.text != passwordTextField.text {
                showErrorAlert(text: "Passwords don't match!")
                textField.text = ""
            }
        }
    }
}
