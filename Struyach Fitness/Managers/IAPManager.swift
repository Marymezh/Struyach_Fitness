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
    
    // method checking if user has access to a training plan
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
    
    // method fetching details about offering: price, terms
    public func getOfferingDetails(identifier: String, completion: @escaping  (String, String)->()) {
        Purchases.shared.getOfferings { offerings, error in
            if let error = error {
                print (error.localizedDescription)
            } else if identifier == "belly" || identifier == "pelvic"{
                let currentOffering = offerings?.offering(identifier: identifier)
                if let package = currentOffering?.availablePackages[0] {
                    let productPriceString = package.storeProduct.localizedPriceString
                    let termsText = "Pay once and get life-time access".localized()
                    let priceText = String(format: "Buy now for %@".localized(), locale: Locale(identifier: self.localeId), productPriceString)
                    completion(priceText, termsText)
                }
            } else {
                let currentOffering = offerings?.offering(identifier: identifier)
                if let package = currentOffering?.availablePackages[0] {
                    let productPriceString = package.storeProduct.localizedPriceString
                    let product = package.storeProduct
                    Purchases.shared.checkTrialOrIntroDiscountEligibility(product: product) { result in
                        if result == .eligible {
                            if let intro = package.storeProduct.introductoryDiscount {
                                print ("there is an into discount")
                                let introValue = intro.subscriptionPeriod.value
                                let introTitle = intro.subscriptionPeriod.durationTitle
                                let termsText = String(format: "Start your %d - %@ FREE trial".localized(), introValue, introTitle)
                                let priceText =  String(format: "%@/month after trial".localized(), locale: Locale(identifier: self.localeId), productPriceString)
                                completion(priceText, termsText)
                            }
                        } else {
                            print ("user not eligible for an intro offer")
                            let priceText = ""
                            let termsText = String(format: "Subscribe now for %@/month".localized(), locale: Locale(identifier: self.localeId), productPriceString)
                            completion(priceText, termsText)
                        }
                    }
                }
            }
        }
    }
   
    // method fetching subscription status for each plan to show it in Settings VC
    public func getSubscriptionStatus(program: String, completion: @escaping (Bool, UIColor, String) -> ()) {
        Purchases.shared.getCustomerInfo {customerInfo, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if customerInfo?.entitlements[program]?.isActive == true {
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
                        let color = UIColor.systemGreen
                        let activeUntil = String(format: "until %@".localized(), subscriptionPeriod)
                        completion(true, color, activeUntil)
                    } else {
                        let purchased = "purchased".localized()
                        let color = UIColor.systemGreen
                        completion(true, color, purchased)
                    }
                } else {
                    let message = String(format: "not active".localized(), program)
                    let color = UIColor.systemYellow
                    completion(false, color, message)
                }
            }
        }
    }
    
    // method fetching available packages in the offering
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
    
    //method to purchase a package from offering
    public func purchase(program: String, package: RevenueCat.Package, completion: @escaping (Result<Bool, Error>) -> ()) {

        Purchases.shared.purchase(package: package) { (transaction, customerInfo, error, userCancelled) in
            if let error = error {
                completion(.failure(error))
                print("error - failed to complete the purchase")
            } else {
                if customerInfo?.entitlements[program]?.isActive == true {
                    completion(.success(true))
                } else {
                    print ("Purchase succeeded but program is not active")
                    let error = NSError(domain: "com.example.purchase", code: 0, userInfo: [NSLocalizedDescriptionKey: "Purchase succeeded but program is not active"])
                    completion(.failure(error))
                }
            }
        }
    }

  //method logs in a user on app launch (connected with Firebase Authentication)
    public func logInRevenueCat(userId: String, completion: @escaping (Error) -> ())  {
        Purchases.shared.logIn(userId) { (customerInfo, created, error) in
            if let error = error {
                completion(error)
            } else {
                print("user is loged in the Revenue cat!")
            }
        }
    }
    
   //method logs out a user on sign out
    public func logOutRevenueCat(completion: @escaping (Error) -> ()) {
        Purchases.shared.logOut { customerInfo, error in
            if let error = error {
                completion(error)
            } else {
                print("User is loged out from the Revenue cat")
            }
        }
    }

    //method to restore purchases if app accessed from a different device
//    public func restorePurchases(completion: @escaping (Result<Bool, Error>) -> ()) {
//        Purchases.shared.restorePurchases { info, error in
//            if let error = error {
//                completion (.failure(error))
//                print("purchases are not restored")
//            } else {
//                completion (.success(true))
//                print("purchases are restored successfully")
//            }
//        }
//    }
    public func restorePurchases(completion: @escaping (Result<Bool, Error>) -> ()) {
        Purchases.shared.restorePurchases { info, error in
            if let error = error {
                completion(.failure(error))
                print("Purchases are not restored")
            } else if let info = info {
                if info.activeSubscriptions.isEmpty {
                    // User doesn't have any purchases
                    print("User doesn't have any purchases")
                    // You can handle this case differently if needed
                    completion(.success(false))
                } else {
                    // Purchases are restored successfully
                    print("Purchases are restored successfully")
                    completion(.success(true))
                }
            }
        }
    }

   
    //method to syncronize purchases, not working on simulator
    public func syncPurchases(completion: @escaping (Result<Bool, Error>) -> ()) {
        Purchases.shared.syncPurchases { info, error in
            if let error = error {
                completion (.failure(error))
            } else {
                completion (.success(true))
            }
        }
    }
}

//method to localize data from RevCat about subscription status
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

