//
//  SignInViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit

class SignInViewController: UIViewController {
    
    let loginView = LoginView()

    override func viewDidLoad() {
        super.viewDidLoad()
  
        title = "Log In"

        #if Admin
        view.backgroundColor = .black
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        #else
        view.backgroundColor = .white
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        #endif
        
        setupSubviews()
    }
    
    private func setupSubviews() {
        view.addSubview(loginView)
        loginView.toAutoLayout()
        
        let constraints = [
            loginView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            loginView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            loginView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loginView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
