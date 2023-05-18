//
//  CreateAccountViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit

final class CreateAccountViewController: UIViewController {
    
    //MARK: - Properties
    
    private let activityView = ActivityView()
    private let signUpView = SignUpView()
    
    //MARK: - Lifecycle
    
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
    
    //MARK: - Setup methods
    
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
        #if Admin
        signUpView.secretCodeTextField.isHidden = false
        #endif
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
    
    //MARK: - Buttons hangling methods
    
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
              let enteredCode = signUpView.secretCodeTextField.text,
              let imageData = signUpView.avatarImageView.image?.jpegData(compressionQuality: 0.5) else {return
        }
        
        //check secretCode for admin sign up
        #if Admin
        SecurityCodeChecker.shared.check(enteredCode: enteredCode) { [weak self] success in
            guard let self = self else {return}
            if success {
                self.createNewUser(name: name, email: email, password: password, imageData: imageData, isAdmin: true)
            } else {
                self.showErrorAlert(text: "The secret code is wrong, you can not be registered as an admin!".localized())
            }
        }
        #else
        // register new user without checking the code 
        self.createNewUser(name: name, email: email, password: password, imageData: imageData, isAdmin: false)
        #endif
    }
    //create User
    private func createNewUser(name: String, email: String, password: String, imageData: Data, isAdmin: Bool) {
        
        AuthManager.shared.signUp(email: email, password: password) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success:
                self.activityView.showActivityIndicator()
                #if Client
                let userId = email
              //  guard let userUID = AuthManager.shared.userUID else {return}
                let safeUserId = userId
                    .replacingOccurrences(of: "@", with: "_")
                    .replacingOccurrences(of: ".", with: "_")
                IAPManager.shared.logInRevenueCat(userId: safeUserId)  { error in
                    print(error.localizedDescription)
                }
                #endif
                
                StorageManager.shared.setUserProfilePicture(email: email, image: imageData) {imageRef in
                    guard let imageRef = imageRef else {return}
                    let newUser = User(name: name, email: email, profilePictureRef: imageRef, personalRecords: nil, isAdmin: isAdmin)
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
                var errorMessage = "Unable to create new user".localized()
                switch error {
                case .emailAlreadyExists:
                    errorMessage = "A user with this email already exists".localized()
                case .passwordTooShort:
                    errorMessage = "Password is too short. Use at least 6 symbols".localized()
                case .unknownError:
                    errorMessage = "\(error.localizedDescription)"
                }
                self.showErrorAlert(text: errorMessage)
            }
        }
    }
    
    private func showErrorAlert(text: String) {
        let alert = UIAlertController(title: "Error".localized(), message: text, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel)
        alert.view.tintColor = .red
        alert.addAction(cancelAction)
        navigationController?.present(alert, animated: true)
    }
}
//MARK: - UITextField Delegate

extension CreateAccountViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == signUpView.confirmPasswordTextField {
            if textField.text != signUpView.passwordTextField.text {
                showErrorAlert(text: "Passwords don't match!".localized())
                textField.text = ""
            }
        }
    }
}

//MARK: - UIImagePickerControllerDelegate and UINavigationControllerDelegate 

extension CreateAccountViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func showImagePickerController() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        picker.sourceType = .photoLibrary
        navigationItem.backButtonTitle = "Cancel".localized()
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
