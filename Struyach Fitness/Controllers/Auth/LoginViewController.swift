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
        view.addSubview(loginView)
        loginView.logInButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        loginView.createAccountButton.addTarget(self, action: #selector(createAccountTapped), for: .touchUpInside)
        
        let constraints = [
            loginView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            loginView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loginView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loginView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
   
    //MARK: - Buttons handling methods
    
    @objc private func loginTapped() {
        guard let email = loginView.emailTextField.text, !email.isEmpty else {
            self.showAlert(title: "Warning".localized(), message: "Check your email".localized())
            return}
        guard let password = loginView.passwordTextField.text, !password.isEmpty, password.count > 6 else {
            self.showAlert(title: "Warning".localized(), message: "Check your password".localized())
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
    
    private func checkIfAdmin(email: String, password: String) {
        DatabaseManager.shared.getUser(email: email) {[weak self] user in
            guard let self = self else {return}
            if let user = user {
                if user.isAdmin == true {
                    self.logIn(email: email, password: password)
                } else {
                    self.showAlert(title: "Warning".localized(), message: "You are not authorized to sign in as an admin!".localized())
                }
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
                    UserDefaults.standard.set(email, forKey: "email")
                    let vc = TabBarController()
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                }
            case .failure(let error):
                let message = String(format: "Unable to log in: %@".localized(), error.localizedDescription)
                self.showAlert(title: "Warning", message: message)
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Retry".localized(), style: .cancel)
        alert.addAction(cancelAction)
        alert.view.tintColor = .systemGreen
        self.present(alert, animated: true, completion: nil)
    }
}
