//
//  IAPManager.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import Foundation
import RevenueCat
import UIKit

final class IAPManager {
    
    static let shared = IAPManager()

    private let currentLanguage = LanguageManager.shared.currentLanguage
    
    private var localeId: String {
        switch currentLanguage {
        case .english:
            return "en_US"
        case .russian:
            return "ru_RU"
        }
    }
    private init() {}
    
    public func getOfferingDetails(identifier: String, completion: @escaping  (String, String)->()) {
        Purchases.shared.getOfferings { offerings, error in
            if let error = error {
                print (error.localizedDescription)
            } else {
                let currentOffering = offerings?.offering(identifier: identifier)
                if let package = currentOffering?.availablePackages[0] {
                    let productPriceString = package.storeProduct.localizedPriceString
                    if let intro = package.storeProduct.introductoryDiscount {
                        let introValue = intro.subscriptionPeriod.value
                        let introTitle = intro.subscriptionPeriod.durationTitle
                        let termsText = String(format: "Start your %d - %@ FREE trial".localized(), introValue, introTitle)
                        let priceText =  String(format: "%@/month after trial".localized(), locale: Locale(identifier: self.localeId), productPriceString)
                        completion(priceText, termsText)
                    } else {
                        let termsText = "Pay once and get life-time access".localized()
                        let priceText = String(format: "Buy now for %@".localized(), locale: Locale(identifier: self.localeId), productPriceString)
                        completion(priceText, termsText)
                    }
                    
                }
            }
        }
    }
    
    public func checkCustomerStatus(program: String, completion: @escaping (Bool) ->()) {
        Purchases.shared.getCustomerInfo { customer, error in
            if let error = error {
                print (error.localizedDescription)
            } else {
                if customer?.entitlements[program]?.isActive == true {
                    completion(true)
                    
                } else {
                    completion(false)
                }
            }
        }
    }
    
    public func getSubscriptionStatus(program: String, completion: @escaping (UIColor, String) -> ()) {
        Purchases.shared.getCustomerInfo {customerInfo, error in
            
            if let error = error {
                print(error.localizedDescription)
            } else {
//                guard let identifiers = customerInfo?.allPurchasedProductIdentifiers else {return}
//                print (identifiers)
                if customerInfo?.entitlements[program]?.isActive == true {
                    guard let info = customerInfo?.entitlements[program] else {
                        print ("error fetching customer info")
                        return
                    }
                    print ("this is the customer info for program \(program):\(info)")
                    let formatter = DateFormatter()
                    formatter.dateStyle = .medium
                    let currentLanguage = LanguageManager.shared.currentLanguage
                    if currentLanguage.rawValue == "ru" {
                        formatter.locale = Locale(identifier: "ru_RU")
                    } else {
                        formatter.locale = Locale(identifier: "en_US")
                    }
                    if let date = customerInfo?.expirationDate(forEntitlement: program) {
                        
                        let subscriptionPeriod = formatter.string(from: date)
                        print (subscriptionPeriod + program)
                        let color = UIColor.systemGreen
                        let activeUntil = String(format: "until %@".localized(), subscriptionPeriod)
                        completion(color, activeUntil)
                    } else {
                        let purchased = "purchased".localized()
                        let color = UIColor.systemGreen
                        completion(color, purchased)
                    }
                } else {
                    let message = String(format: "not active".localized(), program)
                    let color = UIColor.systemYellow
                    completion(color, message)
                }
            }
        }
    }
    
    public func fetchPackages(identifier: String, completion: @escaping (Result <RevenueCat.Package?, Error>) -> ()) {
        Purchases.shared.getOfferings {offerings, error in
            if let error = error {
                completion(.failure(error))
            } else {
                if let package = offerings?.offering(identifier: identifier)?.availablePackages.first {
                    completion(.success(package))
                }
            }
        }
    }
    
    public func purchase(program: String, package: RevenueCat.Package, completion: @escaping (Result<Bool, Error>) -> ()) {
        Purchases.shared.purchase(package: package) { (transaction, customerInfo, error, userCancelled) in
            if let error = error {
                completion(.failure(error))
            } else {
                if customerInfo?.entitlements[program]?.isActive == true {
                    completion(.success(true))
                } else {
                    let error = NSError(domain: "com.example.purchase", code: 0, userInfo: [NSLocalizedDescriptionKey: "Purchase succeeded but program is not active"])
                    completion(.failure(error))
                }
            }
        }
    }
    
  
    
    public func logInRevenueCat(userId: String, completion: @escaping (Error) -> ())  {
        Purchases.shared.logIn(userId) { (customerInfo, created, error) in
            if let error = error {
                completion(error)
            } else {
                print("user is loged in the Revenue cat!")
            }
        }
    }
    
    
    public func logOutRevenueCat(completion: @escaping (Error) -> ()) {
        Purchases.shared.logOut { customerInfo, error in
            
            if let error = error {
                completion(error)
            } else {
                print("User is loged out from the Revenue cat")
            }
        }
    }
//
//    public func restorePurchases() {
//        Purchases.shared.restoreTransactions { info, error in
//            guard let entitlements = info?.entitlements,
//                    error == nil else {return}
//            print("restored \(entitlements)")
//        }
//    }
//
}

extension SubscriptionPeriod {
    var durationTitle: String {
        switch self.unit {
        case .day: return "day".localized()
        case .week: return "week".localized()
        case .month: return "month".localized()
        case .year: return "year".localized()
        @unknown default: return "Unknown"
        }
    }
}

