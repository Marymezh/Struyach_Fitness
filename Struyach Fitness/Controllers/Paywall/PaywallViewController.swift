//
//  PaywallViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 24/4/23.
//

import UIKit
import StoreKit

final class PaywallViewController: UIViewController {
    
    //MARK: - Properties
    
    private let paywallView = PaywallView()
    private let programName: String
    var onPaywallClose: (()->())?
    
    private let activityView = ActivityView()
    private var packageId: String {
        switch programName {
        case K.ecd: return "ecd"
        case K.struyach: return "struyach"
        case K.bellyBurner: return "belly"
        case K.pelvicPower: return "pelvic"
        default: return "unknown"
        }
    }
    
    private let selectedColor = UserDefaults.standard.colorForKey(key: "SelectedColor")
    private lazy var appColor = selectedColor ?? .systemGreen
    
    //MARK: - Lifecycle
    
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
        setupPaywallMessageAndPrice()
        NotificationCenter.default.addObserver(self, selector: #selector(handleColorChange(_:)), name: Notification.Name("AppColorChanged"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         navigationController?.navigationBar.isHidden = true
     }
     
     override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
         navigationController?.navigationBar.isHidden = false
     }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print ("paywall is deallocated")
    }
    
    @objc func handleColorChange(_ notification: Notification) {
        print ("changing paywall VC tint color")
        if let color = notification.object as? UIColor {
            self.appColor = color
        }
    }
    
    //MARK: - Setup subviews
    
    private func setupSubviews() {
        paywallView.toAutoLayout()
        activityView.toAutoLayout()
        activityView.activityIndicator.color = appColor
        paywallView.titleLabel.textColor = appColor
        paywallView.payButton.backgroundColor = appColor
        paywallView.termsLinkLabel.textColor = appColor
        paywallView.payButton.addTarget(self, action: #selector(payButtonPressed), for: .touchUpInside)
        paywallView.closeButton.addTarget(self, action: #selector(closeScreen), for: .touchUpInside)
        view.addSubview(paywallView)
        view.addSubview(activityView)
        let constraints = [
            paywallView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            paywallView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            paywallView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            paywallView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            activityView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            activityView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            activityView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    
    private func setupPaywallMessageAndPrice() {
        switch programName {
        case K.ecd:
            paywallView.titleLabel.text = "Subscribe to ECD Plan".localized()
            paywallView.descriptionLabel.text = K.ecdDescription.localized()
            paywallView.codeTextField.isHidden = false
            paywallView.redeemCodeLabel.isHidden = false
            paywallView.termsLabel.text =  K.subscriptionTerms.localized()
            IAPManager.shared.getOfferingDetails(identifier: packageId) {[weak self] (priceText, termsText) in
                guard let self = self else {return}
                DispatchQueue.main.async {
                        self.paywallView.priceLabel.text = priceText
                        self.paywallView.payButton.setTitle(termsText, for: .normal)
                }
            }
 
        case K.struyach:
            paywallView.titleLabel.text = "Subscribe to STRUYACH Plan".localized()
            paywallView.descriptionLabel.text = K.struyachDescription.localized()
            paywallView.termsLabel.text =  K.subscriptionTerms.localized()
            IAPManager.shared.getOfferingDetails(identifier: packageId) { [weak self] (priceText, termsText) in
                guard let self = self else {return}
                DispatchQueue.main.async {
                        self.paywallView.priceLabel.text = priceText
                        self.paywallView.payButton.setTitle(termsText, for: .normal)
                }
            }
      
        case K.pelvicPower:
            paywallView.titleLabel.text = "Buy Pelvic Power Plan".localized()
            paywallView.descriptionLabel.text = K.pelvicDescription.localized()
            paywallView.termsLabel.text = K.purchaseTerms.localized()
            IAPManager.shared.getOfferingDetails(identifier: packageId) { [weak self] (priceText, termsText) in
                guard let self = self else {return}
                DispatchQueue.main.async {
                    self.paywallView.payButton.setTitle(priceText, for: .normal)
                    self.paywallView.priceLabel.text = termsText
                }
            }
           
        case K.bellyBurner:
            paywallView.titleLabel.text = "Buy Belly Burner Plan".localized()
            paywallView.descriptionLabel.text = K.bellyDescription.localized()
            paywallView.termsLabel.text = K.purchaseTerms.localized()
            IAPManager.shared.getOfferingDetails(identifier: packageId) { [weak self] (priceText, termsText) in
                guard let self = self else {return}                
                DispatchQueue.main.async {
                    self.paywallView.payButton.setTitle(priceText, for: .normal)
                    self.paywallView.priceLabel.text = termsText
                }
            }
        default: break
        }
    }
    
    @objc private func payButtonPressed() {
        if SKPaymentQueue.canMakePayments() {
            activityView.showActivityIndicator()
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
                            self.activityView.hide()
                            self.dismiss(animated: true)
                            
                        case .failure(let error):
                            self.activityView.hide()
                            let message = String(format: "Unable to complete in-app purchase: %@".localized(), error.localizedDescription)
                            AlertManager.shared.showAlert(title: "Failed".localized(), message: message, cancelAction: "Ok")
                        }
                    }
                case .failure(let error):
                    self.activityView.hide()
                    let message = String(format: "Unable to complete in-app purchase: %@".localized(), error.localizedDescription)
                    AlertManager.shared.showAlert(title: "Failed".localized(), message: message, cancelAction: "Ok")
                }
            }
        }  else {
            AlertManager.shared.showAlert(title: "Warning".localized(), message: "You are not allowed to make purchases".localized(), cancelAction: "Ok")
            self.activityView.hide()
        }
    }
    
    @objc private func closeScreen() {
        self.dismiss(animated: true)
    }
}
