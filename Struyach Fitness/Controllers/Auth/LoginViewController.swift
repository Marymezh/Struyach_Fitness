//
//  LoginViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit
import Contacts

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
        showPrivacyPolicy()
        
    }
    //MARK: - Setup methods
    
    private func setupNavBar () {
        title = "Log In".localized()
        navigationController?.navigationBar.backgroundColor = .black
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.alpha = 0.9
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }

    private func setupSubviews() {
        view.backgroundColor = .black
        loginView.toAutoLayout()
        loginView.logInButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        loginView.createAccountButton.addTarget(self, action: #selector(createAccountTapped), for: .touchUpInside)
        loginView.restorePasswordButton.addTarget(self, action: #selector(restorePasswordTapped), for: .touchUpInside)
        
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
                AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to log in: There is no user record corresponding to this email. Check your email".localized(), cancelAction: "Retry".localized())
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
#if Client
                let userId = email
                    .replacingOccurrences(of: "@", with: "_")
                    .replacingOccurrences(of: ".", with: "_")
                IAPManager.shared.logInRevenueCat(userId: userId) { error in
                    print(error.localizedDescription)
                }
                #endif
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
    
    private func showPrivacyPolicy() {
        if !hasAgreedToPrivacyPolicy {
        let alertController = UIAlertController(title: "Privacy policy".localized(), message: privacyPolicy, preferredStyle: .alert)
            
        let agreeAction = UIAlertAction(title: "Agree".localized(), style: .default) { _ in
                // User has agreed to the privacy policy, so save the agreement status and proceed to the initial view controller
                UserDefaults.standard.set(true, forKey: "HasAgreedToPrivacyPolicy")
                self.dismiss(animated: true)
            }
            
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .destructive) { _ in
                // User has chosen to cancel, handle this as needed
                // For example, you can display an alert or exit the app
            let cancelAlertController = UIAlertController(title: "Cancellation".localized(), message: "You must agree to the privacy policy to use this app.".localized(), preferredStyle: .alert)
                
            let exitAction = UIAlertAction(title: "Exit".localized(), style: .destructive) { _ in
                    // Exit the app
                    UserDefaults.standard.set(false, forKey: "HasAgreedToPrivacyPolicy")
                    exit(0)
                }
                
            let tryAgainAction = UIAlertAction(title: "Try Again".localized(), style: .default) { _ in
                    // Show the privacy policy again
                    self.showPrivacyPolicy()
                }
                cancelAlertController.addAction(exitAction)
                cancelAlertController.addAction(tryAgainAction)
                cancelAlertController.view.tintColor = .customDarkGray
                
                self.present(cancelAlertController, animated: true, completion: nil)
            }
            
            alertController.addAction(agreeAction)
            alertController.addAction(cancelAction)
        
        alertController.view.tintColor = .customDarkGray
        alertController.modalPresentationStyle = .popover
            
        present(alertController, animated: true, completion: nil)
        }
    }
}
