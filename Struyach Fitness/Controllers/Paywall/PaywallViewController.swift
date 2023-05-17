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
        paywallView.payButton.addTarget(self, action: #selector(payButtonPressed), for: .touchUpInside)
        paywallView.restorePurchasesButton.addTarget(self, action: #selector(restoreButtonPressed), for: .touchUpInside)
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
            paywallView.descriptionLabel.text = K.ecdDescription
            IAPManager.shared.getOfferingDetails(identifier: packageId) {[weak self] (priceText, termsText) in
                guard let self = self else {return}
                self.paywallView.priceLabel.text = priceText
                self.paywallView.payButton.setTitle(termsText, for: .normal)
            }
 
        case K.struyach:
            paywallView.titleLabel.text = "Subscribe to STRUYACH Plan".localized()
            paywallView.descriptionLabel.text = K.struyachDescription
            IAPManager.shared.getOfferingDetails(identifier: packageId) { [weak self] (priceText, termsText) in
                guard let self = self else {return}
                self.paywallView.priceLabel.text = priceText
                self.paywallView.payButton.setTitle(termsText, for: .normal)
            }
      
        case K.pelvicPower:
            paywallView.titleLabel.text = "Pelvic Power Plan".localized()
            paywallView.descriptionLabel.text = K.pelvicDescription
            paywallView.cancellationLabel.isHidden = true
            IAPManager.shared.getOfferingDetails(identifier: packageId) { [weak self] (priceText, termsText) in
                guard let self = self else {return}
                self.paywallView.payButton.setTitle(priceText, for: .normal)
                self.paywallView.priceLabel.text = termsText
            }
           
        case K.bellyBurner:
            paywallView.titleLabel.text = "Belly Burner Plan".localized()
            paywallView.descriptionLabel.text = K.bellyDescription
            paywallView.cancellationLabel.isHidden = true
            IAPManager.shared.getOfferingDetails(identifier: packageId) { [weak self] (priceText, termsText) in
                guard let self = self else {return}
                self.paywallView.payButton.setTitle(priceText, for: .normal)
                self.paywallView.priceLabel.text = termsText
            }

            
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
                    case .success(_):
                        self.onPaywallClose?()
                        self.dismiss(animated: true)
                    case .failure(let error):
                        let message = String(format: "Unable to complete in-app purchase: %@".localized(), error.localizedDescription)
                        self.showAlert(title: "Failed".localized(), message: message, completion: nil)
                    }
                }
            case .failure(let error):
                let message = String(format: "Unable to complete in-app purchase: %@".localized(), error.localizedDescription)
                self.showAlert(title: "Failed".localized(), message: message, completion: nil)
            }
        }
    }
    
    @objc private func restoreButtonPressed() {
        IAPManager.shared.restorePurchases { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .failure(let error):
                let message = String(format: "Unable to restore purchases: %@".localized(), error.localizedDescription)
                self.showAlert(title: "Failed".localized(), message: message, completion: nil)
            case .success(_):
                self.showAlert(title: "Success".localized(), message: "Your purchases are successfully restored!".localized()){_ in
                    self.onPaywallClose?()
                    self.dismiss(animated: true)
                }
                
                
            }
        }
    }
    
    private func showAlert(title: String, message: String, completion: ((UIAlertAction) -> Void)?
) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: completion)
        alert.addAction(cancelAction)
        alert.view.tintColor = .systemGreen
        self.present(alert, animated: true, completion: nil)
    }
}
