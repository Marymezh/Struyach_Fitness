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
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupSubviews()
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
        checkIfAdmin(email: email, password: password)
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
    
    private func checkIfAdmin(email: String, password: String) {
        DatabaseManager.shared.getUser(email: email) {[weak self] user in
            guard let self = self else {return}
            if let user = user {
                if user.isAdmin == true {
                    self.logIn(email: email, password: password)
                } else {
                    AlertManager.shared.showAlert(title: "Warning".localized(), message: "You are not authorized to sign in as an admin!".localized(), cancelAction: "Retry".localized())
                    self.activityView.hide()
                }
            } else {
                AlertManager.shared.showAlert(title: "Error".localized(), message: "No such user! Check your e-mail".localized(), cancelAction: "Retry".localized())
                self.activityView.hide()
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
             //   guard let userUID = AuthManager.shared.userUID else {return}
                let safeUserId = userId
                    .replacingOccurrences(of: "@", with: "_")
                    .replacingOccurrences(of: ".", with: "_")
                IAPManager.shared.logInRevenueCat(userId: safeUserId) { error in
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
                AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to log in: There is no user record corresponding to this email. Check your email".localized(), cancelAction: "Retry".localized())
            }
        }
    }
}
