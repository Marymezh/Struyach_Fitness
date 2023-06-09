//
//  RestorePasswordViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 7/6/23.
//

import UIKit

final class RestorePasswordViewController: UIViewController {
    
    //MARK: - Properties
    let restoreView = RestorePasswordView()
    let activityView = ActivityView()
    let email: String?
    
    //MARK: - Lifecycle
    init(email: String?) {
        self.email = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
    }
    
    //MARK: - Methods
    private func setupSubviews() {
        view.backgroundColor = .black
        activityView.toAutoLayout()
        restoreView.toAutoLayout()
        restoreView.sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        restoreView.closeButton.addTarget(self, action: #selector(closeScreen), for: .touchUpInside)
        if email != nil {
            restoreView.emailTextField.text = email
        }
        view.addSubviews(restoreView, activityView)
        
        let constraints = [
            restoreView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            restoreView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            restoreView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            restoreView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityView.topAnchor.constraint(equalTo: view.topAnchor),
            activityView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            activityView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            activityView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc private func sendButtonTapped() {
        self.activityView.showActivityIndicator()
        guard let email = restoreView.emailTextField.text, !email.isEmpty else {
            AlertManager.shared.showAlert(title: "Warning".localized(), message: "Enter your email".localized(), cancelAction: "Retry".localized())
            self.activityView.hide()
            return}
        send(email: email)
    }
    
    private func send(email: String) {
        AuthManager.shared.restorePassword(email: email) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(()):
                AlertManager.shared.showAlert(title: "Success".localized(), message: "Email with instructions was successfully sent!".localized(), cancelAction: "Ok") {  [weak self] _ in
                    guard let self = self else {return}
                    self.dismiss(animated: true)
                }
                self.activityView.hide()
            case .failure(let error):
                let message = String(format: "Failed sending email: %@".localized(), error.localizedDescription)
                AlertManager.shared.showAlert(title: "Error".localized(), message: message, cancelAction: "Calcel".localized())
                self.activityView.hide()
            }
        }
    }
    
    @objc private func closeScreen() {
        self.dismiss(animated: true)
    }
}

