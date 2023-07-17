//
//  CreateAccountViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit
import Photos

final class CreateAccountViewController: UIViewController {
    
    //MARK: - Properties
    
    private let activityView = ActivityView()
    private let signUpView = SignUpView()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupGuestureRecognizer()
        signUpView.userNameTextField.delegate = self
        signUpView.emailTextField.delegate = self
        signUpView.passwordTextField.delegate = self
        signUpView.confirmPasswordTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        signUpView.signUpButton.isEnabled = false
        signUpView.signUpButton.alpha = 0.5
    }
    
    //MARK: - Setup methods
    
    private func setupSubviews() {
        view.backgroundColor = .black
        signUpView.toAutoLayout()
        signUpView.signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        signUpView.userNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        signUpView.emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        signUpView.passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        signUpView.confirmPasswordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        #if Admin
        signUpView.secretCodeTextField.isHidden = false
        #endif
        activityView.toAutoLayout()
        activityView.isHidden = true
        
        view.addSubviews(signUpView, activityView)
        let constraints = [
            signUpView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            signUpView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            signUpView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            signUpView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            activityView.topAnchor.constraint(equalTo: view.topAnchor),
            activityView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            activityView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            activityView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupGuestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(avatarImageViewTapped))
        signUpView.avatarImageView.addGestureRecognizer(tap)
    }
    
    //MARK: - Buttons hangling methods
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        checkTextFields()
    }
    
    private func checkTextFields() {
        guard let email = signUpView.emailTextField.text, !email.isEmpty,
              let password = signUpView.confirmPasswordTextField.text, !password.isEmpty,
              password == signUpView.passwordTextField.text,
              let name = signUpView.userNameTextField.text, !name.isEmpty else {
            signUpView.signUpButton.isEnabled = false
            signUpView.signUpButton.alpha = 0.5
            return
        }
        signUpView.signUpButton.isEnabled = true
        signUpView.signUpButton.alpha = 1
    }
    
    @objc private func avatarImageViewTapped() {
        activityView.showActivityIndicator()
        print ("avatar tapped")
        askForPermission()
    }
    
    
    @objc private func signUpTapped() {
        guard let email = signUpView.emailTextField.text, !email.isEmpty,
              let password = signUpView.confirmPasswordTextField.text, !password.isEmpty,
              password == signUpView.passwordTextField.text,
              let name = signUpView.userNameTextField.text, !name.isEmpty,
              let enteredCode = signUpView.secretCodeTextField.text,
              let imageData = signUpView.avatarImageView.image?.jpegData(compressionQuality: 1) else {
            return
        }
        
        //check secretCode for admin sign up
        #if Admin
        SecurityCodeChecker.shared.check(enteredCode: enteredCode) { [weak self] success in
            guard let self = self else {return}
            if success {
                self.createNewUser(name: name, email: email, password: password, imageData: imageData, isAdmin: true)
            } else {
                AlertManager.shared.showAlert(title: "Error".localized(), message: "The secret code is wrong, you can not be registered as an admin!".localized(), cancelAction: "Retry".localized())
                signUpView.signUpButton.isEnabled = true
                signUpView.signUpButton.alpha = 1
            }
        }
        #else
        // register new user without checking the code 
        self.createNewUser(name: name, email: email, password: password, imageData: imageData, isAdmin: false)
        #endif
    }
    
    //create User
    private func createNewUser(name: String, email: String, password: String, imageData: Data, isAdmin: Bool) {
        self.signUpView.signUpButton.isEnabled = false
        self.signUpView.signUpButton.alpha = 0.5
        AuthManager.shared.signUp(email: email, password: password) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success:
                self.signUpView.signUpButton.isEnabled = true
                self.signUpView.signUpButton.alpha = 1
                self.activityView.showActivityIndicator()
                #if Client
                let userId = email
                    .replacingOccurrences(of: "@", with: "_")
                    .replacingOccurrences(of: ".", with: "_")
                IAPManager.shared.logInRevenueCat(userId: userId)  { error in
                    print(error.localizedDescription)
                }
                #endif
                let currentLanguage = LanguageManager.shared.getCurrentLanguage().rawValue
                StorageManager.shared.setUserProfilePicture(email: email, image: imageData) {imageRef in
                    guard let imageRef = imageRef else {return}
                    let newUser = User(name: name, email: email, profilePictureRef: imageRef, weightliftingRecords: nil, gymnasticRecords: nil, isAdmin: isAdmin, fcmToken: nil, emailIsHidden: false, likedWorkouts: nil, likedPosts: nil, userLanguage: currentLanguage)
                    DatabaseManager.shared.insertUser(user: newUser) { [weak self] success, error in
                        guard let self = self else {return}
                        print ("inserting new user in the Firestore Database")
                        guard success, error == nil else {
                            if let error = error {
                                self.activityView.hide()
                                let message = String(format: "Unable to create new user: %@".localized(), error.localizedDescription)
                                AlertManager.shared.showActionSheet(title: "Error".localized(), message: message, cancelHandler: nil, confirmActionTitle: "Retry".localized()) { action in
                                    self.signUpTapped()
                                }
                            }
                            return}
                        
                        // User insertion succeeded, continue with the login flow
                        UserDefaults.standard.set(email, forKey: "email")
                        
                        DispatchQueue.main.async {
                            let vc = TabBarController()
                            vc.modalPresentationStyle = .fullScreen
                            self.present(vc, animated: true)
                            self.activityView.hide()
                        }
                    }
                }
            case .failure(let error):
                self.signUpView.signUpButton.isEnabled = true
                self.signUpView.signUpButton.alpha = 1
                
                var errorMessage = "Unable to create new user".localized()
                switch error {
                case .emailAlreadyExists:
                    errorMessage = "A user with this email already exists".localized()
                case .passwordTooShort:
                    errorMessage = "Password is too short. Use at least 6 symbols".localized()
                case .unknownError:
                    errorMessage = "\(error.localizedDescription)"
                }
                AlertManager.shared.showAlert(title: "Error".localized(), message: errorMessage, cancelAction: "Cancel".localized())
                self.activityView.hide()
            }
        }
    }
}

//MARK: - UITextField Delegate

extension CreateAccountViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == signUpView.confirmPasswordTextField {
            if textField.text != signUpView.passwordTextField.text {
                AlertManager.shared.showAlert(title: "Error".localized(), message: "Passwords don't match!".localized(), cancelAction: "Retry".localized())
                textField.text = ""
            }
        }
    }
}

//MARK: - UIImagePickerControllerDelegate and UINavigationControllerDelegate 

extension CreateAccountViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
       
    private func askForPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            presentImagePicker()
        case .denied, .restricted:
            AlertManager.shared.showAlert(title: "Permission Denied".localized(), message: "Please allow access to the photo library in Phone Settings to choose an avatar.".localized(), cancelAction: "Ok")
            activityView.hide()
        case .limited:
            presentImagePicker()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                DispatchQueue.main.async {
                    if status == .authorized {
                        self?.presentImagePicker()
                    } else {
                        self?.activityView.hide()
                    }
                }
            }
        @unknown default:
            activityView.hide()
        }
    }
    
        private func presentImagePicker() {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.navigationBar.tintColor = UIColor.systemGreen
            picker.allowsEditing = true
            picker.delegate = self
            picker.sourceType = .photoLibrary
            picker.view.tintColor = .contrastGreen
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







