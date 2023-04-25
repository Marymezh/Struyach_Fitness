//
//  PaywallViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 24/4/23.
//

import UIKit

class PaywallViewController: UIViewController {
    
    private let paywallView = PaywallView()
    private let programName: String
    
    init(programName: String) {
        self.programName = programName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         
         // Hide navigation bar
         navigationController?.navigationBar.isHidden = true
     }
     
     override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
         
         // Show navigation bar
         navigationController?.navigationBar.isHidden = false
     }
    
    private func setupSubviews() {
        paywallView.toAutoLayout()
        view.addSubview(paywallView)
        let constraints = [
            paywallView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            paywallView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            paywallView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            paywallView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
