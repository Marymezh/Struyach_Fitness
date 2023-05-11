//
//  PaywallViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 24/4/23.
//

import UIKit
import StoreKit
import RevenueCat

enum InAppPurcaseID: String {
    case ECD = "marymezh.StruyachFitnessClient.ecd"
    case PelvicPower = "marymezh.StruyachFitnessClient.pelvic"
}


final class PaywallViewController: UIViewController {
    
    //MARK: - Properties
    
    let paywallView = PaywallView()
    private let programName: String
   
    //private let user: User
    
    init(programName: String) {
        self.programName = programName
   //     self.user = user
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
        
        
    //    SKPaymentQueue.default().add(self)
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
      //  paywallView.otherOptionsButton.addTarget(self, action: #selector(showOtherOptions), for: .touchUpInside)
        paywallView.payButton.addTarget(self, action: #selector(payButtonPressed), for: .touchUpInside)
        view.addSubview(paywallView)
        let constraints = [
            paywallView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            paywallView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            paywallView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            paywallView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupPaywallMessageAndPrice() {
        
        switch programName {
        case K.ecd:
            paywallView.titleLabel.text = "Subscribe to ECD Plan".localized()
            paywallView.descriptionLabel.text =
            "ECD Plan, the main training program followed by our ECD Fitness Club, is suitable for both beginners and intermediate-level athletes. \n\nWith this well-balanced program of full range movements using common gym equipment, you'll never get bored.  \n\nJoin today and start your fitness journey with us!".localized()

            paywallView.payButton.setTitle("Start your 1-Week FREE Trial".localized(), for: .normal)
            
            IAPManager.shared.getOffering(identifier: "default") { offering in
                if let package = offering?.availablePackages[0] {
                    self.paywallView.priceLabel.text = "\(package.storeProduct.localizedPriceString) /month after trial"
                }
            }
   //         paywallView.priceLabel.text = "99 RUB/month after trial".localized()
        case K.struyach:
            paywallView.titleLabel.text = "Subscribe to STRUYACH Plan".localized()
            paywallView.descriptionLabel.text = "Struyach plan is designed for advanced athletes who are serious about pushing their limits and achieving visible progress. This plan is designed for competitive athletes who are in it to win it.\n\nBy subscribing to this plan, you'll get a premium account with full access to all plans and lifetime access to the Pelvic Power and Belly Burner plans! \n\nJoin now!".localized()
            paywallView.payButton.setTitle("Start your 1-Week FREE Trial".localized(), for: .normal)
            paywallView.priceLabel.text = "799 RUB/month after trial".localized()
        case K.pelvicPower:
            paywallView.titleLabel.text = "Pelvic Power Plan".localized()
            paywallView.descriptionLabel.text = "Pelvic Power Plan offers 10 high-intensity workouts with detailed movement descriptions and video presentations to help you tone and strengthen your pelvic muscles.  \n\nJoin today for a one-time payment and get lifetime access to a stronger, healthier you!".localized()

            paywallView.payButton.setTitle("Buy now for 199 RUB".localized(), for: .normal)
            paywallView.priceLabel.text = "Pay once and get life-time access".localized()
        case K.bellyBurner:
            paywallView.titleLabel.text = "Belly Burner Plan".localized()
            paywallView.descriptionLabel.text = "Our high-intensity Belly Burner Plan offers 10 workouts with detailed descriptions and video presentations. \n\nGet rid of stubborn belly fat and achieve a leaner, fitter body with the help of a personal coach who will answer any questions you have.".localized()
            paywallView.payButton.setTitle("Buy now for 199 RUB".localized(), for: .normal)
            paywallView.priceLabel.text = "Pay once and get life-time access".localized()
        default: break
        }
    }
    
//    @objc private func payButtonPressed() {
//        if SKPaymentQueue.canMakePayments() {
//            // can make payments
//
//            let paymentRequest = SKMutablePayment()
//            switch programName {
//            case K.ecd: paymentRequest.productIdentifier = InAppPurcaseID.ECD.rawValue
//            case K.pelvicPower: paymentRequest.productIdentifier = InAppPurcaseID.PelvicPower.rawValue
//            default: break
//            }
//            SKPaymentQueue.default().add(paymentRequest)
//        } else {
//            print("user can't make payments")
//        }
//    }
    @objc private func payButtonPressed() {
//        print ("pay button is pressed")
//        IAPManager.shared.fetchPackages { package in
//            guard let package = package else {return}
//            print ("get package")
//            IAPManager.shared.subscribe(package: package){success in
//                if success {
//                    let programVC = WorkoutsViewController()
//                    programVC.title = self.programName
//                    self.navigationController?.pushViewController(programVC, animated: true)
//                } else {
//                    print ("error subscribing to a package")
//                }
//            }
//        }
    }
}



extension PaywallViewController: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if transaction.transactionState == .purchased {
                print("transaction successfull")
            } else if transaction.transactionState == .failed {
                print("transaction failed")
            }
        }
    }
    
    
}
