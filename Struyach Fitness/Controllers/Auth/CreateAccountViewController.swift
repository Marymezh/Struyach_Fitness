//
//  CreateAccountViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit

class CreateAccountViewController: UIViewController {
    
    private let activityView = ActivityView()
    private let signUpView = SignUpView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavbar()
        setupSubviews()
        setupGuestureRecognizer()
        signUpView.userNameTextField.delegate = self
        signUpView.emailTextField.delegate = self
        signUpView.passwordTextField.delegate = self
        signUpView.confirmPasswordTextField.delegate = self
    }
    
    private func setupNavbar() {
        navigationController?.navigationBar.backgroundColor = .black
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.alpha = 0.9
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    private func setupSubviews() {
        view.backgroundColor = .black
        
        signUpView.toAutoLayout()
        signUpView.signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        
        activityView.toAutoLayout()
        activityView.isHidden = true
        
        view.addSubviews(signUpView, activityView)
        let constraints = [
            signUpView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            signUpView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            signUpView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            signUpView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            activityView.topAnchor.constraint(equalTo: self.view.topAnchor),
            activityView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            activityView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            activityView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupGuestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(avatarImageViewTapped))
        signUpView.avatarImageView.addGestureRecognizer(tap)
    }
    
    @objc private func avatarImageViewTapped() {
        
        activityView.showActivityIndicator()
        print ("avatar tapped")
        showImagePickerController()
    }
    
    @objc private func signUpTapped() {
        guard let email = signUpView.emailTextField.text, !email.isEmpty,
              let password = signUpView.confirmPasswordTextField.text, !password.isEmpty,
              password == signUpView.passwordTextField.text,
              let name = signUpView.userNameTextField.text, !name.isEmpty,
              let imageData = signUpView.avatarImageView.image?.jpegData(compressionQuality: 0.5) else {return
        }
        
        //create User
        AuthManager.shared.signUp(email: email, password: password) { [weak self] result in
            
            guard let self = self else {return}
            
            switch result {
            case .success:
                self.activityView.showActivityIndicator()
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
                            self.activityView.hide()
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
        if textField == signUpView.confirmPasswordTextField {
            if textField.text != signUpView.passwordTextField.text {
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
        activityView.hide()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        navigationController?.dismiss(animated: true)
        activityView.hide()
        guard let image = info[.editedImage] as? UIImage else {return}
        signUpView.avatarImageView.image = image
    }
}
