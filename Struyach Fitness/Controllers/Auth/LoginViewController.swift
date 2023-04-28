//
//  LoginViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit

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
        title = "Log In"
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
            self.showAlert(title: "Warning", message: "Check your email")
            return}
        guard let password = loginView.passwordTextField.text, !password.isEmpty, password.count > 6 else {
            self.showAlert(title: "Warning", message: "Check your password")
            return}
        
        AuthManager.shared.signIn(email: email, password: password) { [weak self] success in
            guard let self = self else {return}
            
            if success {
                DispatchQueue.main.async {
                    UserDefaults.standard.set(email, forKey: "email")
                    let vc = TabBarController()
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                }
            } else {
                self.showAlert(title: "Warning", message: "Unable to log in")
            }
        }
    }
    
    @objc private func createAccountTapped() {
        let createAccountVC = CreateAccountViewController()
        createAccountVC.title = "Create Account"
        createAccountVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.tintColor = .systemGreen
        navigationController?.pushViewController(createAccountVC, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Retry", style: .cancel)
        alert.addAction(cancelAction)
        alert.view.tintColor = .systemGreen
        self.present(alert, animated: true, completion: nil)
    }
}
