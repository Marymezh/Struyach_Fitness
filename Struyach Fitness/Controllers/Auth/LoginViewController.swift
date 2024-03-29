//
//  LoginViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit
import AuthenticationServices
import FirebaseAuth

final class LoginViewController: UIViewController {
    
    private let loginView = LoginView()
    private let activityView = ActivityView()
    private let privacyPolicy = K.privacyPolicy.localized()
    private let hasAgreedToPrivacyPolicy = UserDefaults.standard.bool(forKey: "HasAgreedToPrivacyPolicy")
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupSubviews()
        setupGestureRecognizer()
        AuthManager.shared.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    deinit {
           print ("login vc is deallocated")
       }
    
    //MARK: - Setup methods
    
    private func setupNavBar() {
        title = "Log In".localized()
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.tintColor = .systemGreen
        navigationItem.largeTitleDisplayMode = .never
        
        let infoIconImage = UIImage(systemName: "info.circle")
        let infoButton = UIBarButtonItem(image: infoIconImage, style: .plain, target: self, action: #selector(infoButtonTapped))
        infoButton.tintColor = .systemGreen
        navigationItem.rightBarButtonItem = infoButton
    }
    
    private func setupSubviews() {
        view.backgroundColor = .black
        loginView.toAutoLayout()
        loginView.configure(language: LanguageManager.shared.currentLanguage)
        loginView.delegate = self
        loginView.logInButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        loginView.createAccountButton.addTarget(self, action: #selector(createAccountTapped), for: .touchUpInside)
        loginView.restorePasswordButton.addTarget(self, action: #selector(restorePasswordTapped), for: .touchUpInside)
        loginView.appleSignInButton.addTarget(self, action: #selector(appleSignInButtonTapped), for: .touchUpInside)
        loginView.privacyPolicyCheckbox.addTarget(self, action: #selector(privacyPolicyCheckboxTapped), for: .touchUpInside)
        
#if Admin
        loginView.appleSignInButton.isHidden = true
#endif
        
        if hasAgreedToPrivacyPolicy == false {
            disableButtons()
        } else {
            enableButtons()
            loginView.privacyPolicyLabel.isHidden = true
            loginView.privacyPolicyCheckbox.isHidden = true
        }
        
        activityView.toAutoLayout()
        view.addSubviews(loginView, activityView)
        
        let constraints = [
            loginView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            loginView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loginView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loginView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityView.topAnchor.constraint(equalTo: view.topAnchor),
            activityView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            activityView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            activityView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func disableButtons() {
        loginView.logInButton.isEnabled = false
        loginView.logInButton.alpha = 0.5
        loginView.createAccountButton.isEnabled = false
        loginView.createAccountButton.alpha = 0.5
        loginView.restorePasswordButton.isEnabled = false
        loginView.restorePasswordButton.alpha = 0.5
        loginView.appleSignInButton.isEnabled = false
        loginView.appleSignInButton.alpha = 0.5
    }
    
    private func enableButtons() {
        loginView.logInButton.isEnabled = true
        loginView.logInButton.alpha = 1
        loginView.createAccountButton.isEnabled = true
        loginView.createAccountButton.alpha = 1
        loginView.restorePasswordButton.isEnabled = true
        loginView.restorePasswordButton.alpha = 1
        loginView.appleSignInButton.isEnabled = true
        loginView.appleSignInButton.alpha = 1
    }
    
    
    //MARK: - Buttons handling methods
    
    @objc private func loginTapped() {
        self.activityView.showActivityIndicator()
        guard let email = loginView.emailTextField.text, !email.isEmpty else {
            AlertManager.shared.showAlert(title: "Warning".localized(), message: "Enter your email".localized(), cancelAction: "Retry".localized())
            self.activityView.hide()
            return}
        guard let password = loginView.passwordTextField.text, !password.isEmpty, password.count > 6 else {
            AlertManager.shared.showAlert(title: "Warning".localized(), message: "Check your password".localized(), cancelAction: "Retry".localized())
            self.activityView.hide()
            return}
#if Admin
        LoginAdminWithCheck(email: email, password: password)
#else
        logIn(email: email, password: password)
#endif
    }
    
    @objc private func createAccountTapped() {
        let createAccountVC = CreateAccountViewController()
        createAccountVC.title = "Create Account".localized()
        createAccountVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.tintColor = .systemGreen
        navigationController?.pushViewController(createAccountVC, animated: true)
    }
    
    @objc private func restorePasswordTapped() {
        let restorePasswordVC: UIViewController
        if let email = loginView.emailTextField.text, !email.isEmpty {
            restorePasswordVC = RestorePasswordViewController(email: email)
        } else {
            restorePasswordVC = RestorePasswordViewController(email: nil)
        }
        restorePasswordVC.title = "Restore Password".localized()
        navigationController?.present(restorePasswordVC, animated: true, completion: nil)
    }
    
    @objc private func appleSignInButtonTapped() {
        AuthManager.shared.signUpWithApple()
    }
    
    private func LoginAdminWithCheck(email: String, password: String) {
        AuthManager.shared.signIn(email: email, password: password) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success:
                self.veryfyIsAdmin(email: email) { isAdmin in
                    if isAdmin {
                        DispatchQueue.main.async {
                            self.activityView.hide()
                            UserDefaults.standard.set(email, forKey: "email")
                            let vc = TabBarController()
                            vc.modalPresentationStyle = .fullScreen
                            self.present(vc, animated: true)
                        }
                    } else {
                        AlertManager.shared.showAlert(title: "Warning".localized(), message: "You are not authorized to sign in as an admin!".localized(), cancelAction: "Retry".localized())
                        self.activityView.hide()
                    }
                }
            case .failure(let error):
                print (error.localizedDescription)
                self.activityView.hide()
                AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to log in: wrong e-mail or password.".localized(), cancelAction: "Retry".localized())
            }
        }
    }
    
    private func veryfyIsAdmin(email: String, completion: @escaping (Bool) -> Void) {
        DatabaseManager.shared.getUser(email: email) {user in
            if let user = user, user.isAdmin == true {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    private func logIn(email: String, password: String) {
        AuthManager.shared.signIn(email: email, password: password) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success:
                let userId = email
                    .replacingOccurrences(of: "@", with: "_")
                    .replacingOccurrences(of: ".", with: "_")
                IAPManager.shared.logInRevenueCat(userId: userId) { error in
                    print(error.localizedDescription)
                }
                DispatchQueue.main.async {
                    self.activityView.hide()
                    UserDefaults.standard.set(email, forKey: "email")
                    let vc = TabBarController()
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                }
            case .failure(let error):
                print (error.localizedDescription)
                self.activityView.hide()
                AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to log in: wrong e-mail or password.".localized(), cancelAction: "Retry".localized())
            }
        }
    }
    
    private func setupGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showPrivacyPolicy))
        loginView.privacyPolicyLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc private func privacyPolicyCheckboxTapped() {
        loginView.privacyPolicyCheckbox.isSelected.toggle()
        UserDefaults.standard.set(loginView.privacyPolicyCheckbox.isSelected, forKey: "HasAgreedToPrivacyPolicy")
        if loginView.privacyPolicyCheckbox.isSelected {
            enableButtons()
        } else {
            disableButtons()
        }
    }
    
    @objc private func showPrivacyPolicy() {
        if !hasAgreedToPrivacyPolicy {
            let alertController = UIAlertController(title: "Privacy policy".localized(), message: privacyPolicy, preferredStyle: .alert)
            
            let agreeAction = UIAlertAction(title: "Ok", style: .default) {[weak self] _ in
                guard let self = self else {return}
                
                self.dismiss(animated: true)
                
            }
            alertController.addAction(agreeAction)
            alertController.view.tintColor = .contrastGreen
            alertController.modalPresentationStyle = .popover
            
            present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc private func infoButtonTapped() {
        let appDescription = K.appDescription.localized()
        let aboutThisAppVC = AboutViewController(text: appDescription)
        aboutThisAppVC.title = "About this app".localized()
        aboutThisAppVC.imageView.image = UIImage(named: "coach")
        navigationController?.pushViewController(aboutThisAppVC, animated: true)
    }
}

extension LoginViewController: LanguageSwitchDelegate {
    func didSwitchLanguage(to language: Language) {
        LanguageManager.shared.setCurrentLanguage(language)
        DispatchQueue.main.async {
            let signInVC = LoginViewController()
            let window = UIApplication.shared.windows.first
            UIView.transition(with: window!, duration: 0.5, options: [.transitionCrossDissolve, .allowAnimatedContent], animations: {
                let navVC = UINavigationController(rootViewController: signInVC)
                window?.rootViewController = navVC
            }, completion: nil)
        }
    }
}

extension LoginViewController: AuthManagerDelegate {
    func didCompleteAppleSignIn(with result: AuthDataResult) {
        activityView.showActivityIndicator()
        print ("running did complete app sign in with result")
        let user = result.user
        let name = "Anonymous user".localized()
        guard let email = user.email  else {
            self.activityView.hide()
            AlertManager.shared.showAlert(title: "Error".localized(), message: "Can't fetch user email from Apple ID. Please try to sign up with email and password".localized(), cancelAction: "Cancel".localized())
            return}
        print ("user: \(result.user), userName: \(name), userEmail: \(email) ")
        DatabaseManager.shared.getUser(email: email) { user in
            print("get user when sighning with apple id")
            print (email)
            if let user = user {
                print("logging in with existing apple id user")
                let userId = user.email
                    .replacingOccurrences(of: "@", with: "_")
                    .replacingOccurrences(of: ".", with: "_")
                IAPManager.shared.logInRevenueCat(userId: userId) { error in
                    self.activityView.hide()
                    AlertManager.shared.showAlert(title: "Error".localized(), message: "Can't register user for in-app purchases".localized(), cancelAction: "Cancel".localized())
                }
                DispatchQueue.main.async {
                    self.activityView.hide()
                    UserDefaults.standard.set(email, forKey: "email")
                    let vc = TabBarController()
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                }
            } else {
                // there is no user with this email in the database
                print("creating new user and logging in")
                let userId = email
                    .replacingOccurrences(of: "@", with: "_")
                    .replacingOccurrences(of: ".", with: "_")
                IAPManager.shared.logInRevenueCat(userId: userId)  { error in
                    self.activityView.hide()
                    AlertManager.shared.showAlert(title: "Error".localized(), message: "Can't register user for in-app purchases".localized(), cancelAction: "Cancel".localized())
                }
                let currentLanguage = LanguageManager.shared.getCurrentLanguage().rawValue
                let newUser = User(name: name, email: email, profilePictureRef: nil, weightliftingRecords: nil, gymnasticRecords: nil, isAdmin: false, fcmToken: nil, emailIsHidden: false, likedWorkouts: nil, likedPosts: nil, userLanguage: currentLanguage)
                DatabaseManager.shared.insertUser(user: newUser) { [weak self] success, error in
                    guard let self = self else {return}
                    print ("inserting new user in the Firestore Database")
                    guard success, error == nil else {
                        if let error = error {
                            self.activityView.hide()
                            let message = String(format: "Unable to create new user: %@".localized(), error.localizedDescription)
                            AlertManager.shared.showActionSheet(title: "Error".localized(), message: message, cancelHandler: nil, confirmActionTitle: "Retry".localized()) { action in
                                self.didCompleteAppleSignIn(with: result)
                            }
                        }
                        return}
                    
                    // User insertion succeeded, continue with the login flow
                    UserDefaults.standard.set(email, forKey: "email")
                    
                    DispatchQueue.main.async {
                        self.activityView.hide()
                        let vc = TabBarController()
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true)
                        
                    }
                }
            }
        }
    }
}
    

