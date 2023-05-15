//
//  PaywallViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 24/4/23.
//

import UIKit

final class PaywallViewController: UIViewController {
    
    //MARK: - Properties
    
    let paywallView = PaywallView()
    private let programName: String
    var onPaywallClose: (()->())?
    
    private var packageId: String {
        switch programName {
        case K.ecd: return "default"
        case K.struyach: return "struyach"
        case K.bellyBurner: return "belly"
        case K.pelvicPower: return "pelvic"
        default: return "unknown"
        }
    }
    
//    let currentLanguage = LanguageManager.shared.currentLanguage
//    
//    private var localeId: String {
//        switch currentLanguage {
//        case .english:
//            return "en_US"
//        case .russian:
//            return "ru_RU"
//        }
//    }
   
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         navigationController?.navigationBar.isHidden = true
     }
     
     override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
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

          //  paywallView.payButton.setTitle("Start your 1-Week FREE Trial".localized(), for: .normal)
            
            IAPManager.shared.getOfferingDetails(identifier: packageId) {[weak self] (priceText, termsText) in
                guard let self = self else {return}
//                self.paywallView.priceLabel.text =
//                String(format: "%@/month after trial".localized(), locale: Locale(identifier: self.localeId), price)
                self.paywallView.priceLabel.text = priceText
                self.paywallView.payButton.setTitle(termsText, for: .normal)
            }
 
        case K.struyach:
            paywallView.titleLabel.text = "Subscribe to STRUYACH Plan".localized()
            paywallView.descriptionLabel.text = "Struyach plan is designed for advanced athletes who are serious about pushing their limits and achieving visible progress. This plan is designed for competitive athletes who are in it to win it.\n\nBy subscribing to this plan, you'll get a premium account with full access to all plans and lifetime access to the Pelvic Power and Belly Burner plans! \n\nJoin now!".localized()
           // paywallView.payButton.setTitle("Start your 1-Week FREE Trial".localized(), for: .normal)
            IAPManager.shared.getOfferingDetails(identifier: packageId) { [weak self] (priceText, termsText) in
                guard let self = self else {return}
//                self.paywallView.priceLabel.text = String(format: "%@/month after trial".localized(), locale: Locale(identifier: self.localeId), price)
                self.paywallView.priceLabel.text = priceText
                self.paywallView.payButton.setTitle(termsText, for: .normal)
            }
        //    paywallView.priceLabel.text = "799 RUB/month after trial".localized()
        case K.pelvicPower:
            paywallView.titleLabel.text = "Pelvic Power Plan".localized()
            paywallView.descriptionLabel.text = "Pelvic Power Plan offers 10 high-intensity workouts with detailed movement descriptions and video presentations to help you tone and strengthen your pelvic muscles.  \n\nJoin today for a one-time payment and get lifetime access to a stronger, healthier you!".localized()
            IAPManager.shared.getOfferingDetails(identifier: packageId) { [weak self] (priceText, termsText) in
                guard let self = self else {return}
//                let payButtonTitle = String(format: "Buy now for %@".localized(), locale: Locale(identifier: self.localeId), price)
          
                self.paywallView.payButton.setTitle(priceText, for: .normal)
                self.paywallView.priceLabel.text = termsText
            }
//            paywallView.payButton.setTitle("Buy now for 199 RUB".localized(), for: .normal)
           
        case K.bellyBurner:
            paywallView.titleLabel.text = "Belly Burner Plan".localized()
            paywallView.descriptionLabel.text = "Our high-intensity Belly Burner Plan offers 10 workouts with detailed descriptions and video presentations. \n\nGet rid of stubborn belly fat and achieve a leaner, fitter body with the help of a personal coach who will answer any questions you have.".localized()
            IAPManager.shared.getOfferingDetails(identifier: packageId) { [weak self] (priceText, termsText) in
                guard let self = self else {return}
//                let payButtonTitle = String(format: "Buy now for %@".localized(), locale: Locale(identifier: self.localeId), price)
                self.paywallView.payButton.setTitle(priceText, for: .normal)
                self.paywallView.priceLabel.text = termsText
            }
//            paywallView.payButton.setTitle("Buy now for 199 RUB".localized(), for: .normal)
            
        default: break
        }
    }

    @objc private func payButtonPressed() {
        print ("pay button is pressed")
        IAPManager.shared.fetchPackages(identifier: packageId) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let package):
                guard let package = package else {return}
            IAPManager.shared.purchase(program: self.programName, package: package){[weak self] result in
                guard let self = self else {return}
                switch result {
                case .success(let success):
                    print ("success description: \(success.description)")
                    self.onPaywallClose?()
                    self.dismiss(animated: true)

                case .failure(let error):
                    let message = String(format: "Unable to complete in-app purchase: %@".localized(), error.localizedDescription)
                    self.showAlert(title: "Failed".localized(), message: message)
                }
            }
            case .failure(let error):
                let message = String(format: "Unable to complete in-app purchase: %@".localized(), error.localizedDescription)
                self.showAlert(title: "Failed".localized(), message: message)
        }
    }
    }
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel)
        alert.addAction(cancelAction)
        alert.view.tintColor = .systemGreen
        self.present(alert, animated: true, completion: nil)
    }
}
