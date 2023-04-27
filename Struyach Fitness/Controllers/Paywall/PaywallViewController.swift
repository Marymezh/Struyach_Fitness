//
//  PaywallViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 24/4/23.
//

import UIKit

class PaywallViewController: UIViewController {
    
    //MARK: - Properties
    
    private let paywallView = PaywallView()
    private let programName: String
    
    init(programName: String) {
        self.programName = programName
        super.init(nibName: nil, bundle: nil)
    }
    
    //MARK: - Lifecycle
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupPaywallMessageAndPrice()
        
        paywallView.otherOptionsButton.addTarget(self, action: #selector(showOtherOptions), for: .touchUpInside)
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
    
    //MARK: - Setup subviews
    
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
    
    private func setupPaywallMessageAndPrice() {
        switch programName {
        case K.ecd:
            paywallView.titleLabel.text = "Subscribe to ECD Plan"
            paywallView.descriptionLabel.text =
            "ECD Plan, the main training program followed by our ECD Fitness Club, is suitable for both beginners and intermediate-level athletes. With a well-balanced program of full range movements using common gym equipment, you'll never get bored. \n\nPlus, you'll have the opportunity to share your progress with a coach and other users and compare results. \n\nJoin today and start your fitness journey with us!"
            paywallView.payButton.setTitle("Upgrade for only $1.19/month", for: .normal)
        case K.struyach:
            paywallView.titleLabel.text = "Subscribe to STRUYACH Plan"
            paywallView.descriptionLabel.text = "Struyach plan is designed for advanced athletes who are serious about pushing their limits and achieving visible progress. This plan is designed for competitive athletes who are in it to win it.\n\nBy subscribing to this plan, you'll get a premium account with full access to all plans and lifetime access to the Badass and Hard press plans! \n\nJoin now!"
            paywallView.payButton.setTitle("Upgrade for $9.99/month", for: .normal)
        case K.pelvicPower:
            paywallView.titleLabel.text = "Pelvic Power Plan"
            paywallView.descriptionLabel.text = "Pelvic Power Plan offers 10 high-intensity workouts with detailed movement descriptions and video presentations to help you tone and strengthen your pelvic muscles. \n\nPlus, you'll have access to a personal coach for any questions you may have, just leave a comment under the workout! \n\nJoin today for a one-time payment and get lifetime access to a stronger, healthier you!"
            paywallView.payButton.setTitle("Upgrade Now for $2.99", for: .normal)
        case K.bellyBurner:
            paywallView.titleLabel.text = "Belly Burner Plan"
            paywallView.descriptionLabel.text = "Our high-intensity Belly Burner Plan offers 10 unique workouts with detailed descriptions and video presentations. \n\nGet rid of stubborn belly fat and achieve a leaner, fitter body with the help of a personal coach who will answer any questions you have. \n\nJoin today for great value at just $2.99."
            paywallView.payButton.setTitle("Upgrade Now for $2.99", for: .normal)
        default: break
        }
    }
    
    @objc private func showOtherOptions() {
        let otherOptionsVC = OtherOptionsViewController()
        self.present(otherOptionsVC, animated: true)
    }
}
