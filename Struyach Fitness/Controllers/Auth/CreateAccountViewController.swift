//
//  CreateAccountViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit

class CreateAccountViewController: UIViewController {
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.toAutoLayout()
        indicator.isHidden = true
        indicator.color = .systemGreen
        return indicator
    }()
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.7
        view.isHidden = true
        view.toAutoLayout()
        return view
    }()
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "person.circle"))
        imageView.layer.cornerRadius = 160/2
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.tintColor = .systemGreen
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
    
    private let confirmPasswordTextField: UITextField = {
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
        setupNavbar()
        setupSubviews()
        setupGuestureRecognizer()
        userNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
    }
    
    private func setupNavbar() {
        navigationController?.navigationBar.backgroundColor = .black
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.alpha = 0.9
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    private func setupSubviews() {
        view.backgroundColor = .black
        view.addSubviews(avatarImageView,
                         autorizationView,
                         signUpButton, backgroundView, activityIndicator)
        autorizationView.addSubviews(userNameTextField,
                                     emailTextField,
                                     passwordTextField,
                                     confirmPasswordTextField)
        view.bringSubviewToFront(backgroundView)
        view.bringSubviewToFront(activityIndicator)
        
        let constraints = [
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            avatarImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 160),
            avatarImageView.heightAnchor.constraint(equalToConstant: 160),
            
            autorizationView.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 20),
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
            
            backgroundView.topAnchor.constraint(equalTo: self.view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupGuestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(avatarImageViewTapped))
        avatarImageView.addGestureRecognizer(tap)
    }
    
    @objc private func avatarImageViewTapped() {
        
        backgroundView.isHidden = false
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        print ("avatar tapped")
        showImagePickerController()
    }
    
    @objc private func signUpTapped() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = confirmPasswordTextField.text, !password.isEmpty,
              password == passwordTextField.text,
              let name = userNameTextField.text, !name.isEmpty,
              let imageData = self.avatarImageView.image?.jpegData(compressionQuality: 0.5) else {return
        }
        
        //create User
        AuthManager.shared.signUp(email: email, password: password) { [weak self] result in
       
            guard let self = self else {return}

            switch result {
            case .success:
                self.backgroundView.isHidden = false
                self.activityIndicator.isHidden = false
                self.activityIndicator.startAnimating()
                StorageManager.shared.setUserProfilePicture(email: email, image: imageData) {imageRef in
                    guard let imageRef = imageRef else {return}
                    let newUser = User(name: name, email: email, profilePictureRef: imageRef, personalRecords: nil)
                    DatabaseManager.shared.insertUser(user: newUser) { inserted in
                        guard inserted else {
                            print ("cant insert new user")
                            return}
                        UserDefaults.standard.set(name, forKey: "userName")
                        UserDefaults.standard.set(email, forKey: "email")
                        
                        StorageManager.shared.downloadUrl(path: imageRef) { url in
                            guard let url = url else {return}
                            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                                guard let data = data, error == nil else { return }
                                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                let fileURL = documentsDirectory.appendingPathComponent("userImage.jpg")
                                do {
                                    try data.write(to: fileURL)
                                } catch {
                                    self.showErrorAlert(text: error.localizedDescription)
                                }
                            }
                            task.resume()
                        }
                        
                        DispatchQueue.main.async {
                            let vc = TabBarController()
                            vc.modalPresentationStyle = .fullScreen
                            self.present(vc, animated: true)
                            self.backgroundView.isHidden = true
                            self.activityIndicator.isHidden = true
                            self.activityIndicator.stopAnimating()
                        }
                    }
                }
            case .failure(let error):
                var errorMessage = "Unable to create new user."
                switch error {
                case .emailAlreadyExists:
                    errorMessage = "A user with this email already exists."
                case .passwordTooShort:
                    errorMessage = "Password is too short. Use at least 6 symbols."
                case .unknownError:
                    errorMessage = "Please check your Internet connection."
                }
                self.showErrorAlert(text: errorMessage)
            }
        }
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

extension CreateAccountViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func showImagePickerController() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        picker.sourceType = .photoLibrary
        navigationController?.present(picker, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        navigationController?.dismiss(animated: true)
        backgroundView.isHidden = true
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        navigationController?.dismiss(animated: true)
        backgroundView.isHidden = true
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        guard let image = info[.editedImage] as? UIImage else {return}
        self.avatarImageView.image = image
    }
}
