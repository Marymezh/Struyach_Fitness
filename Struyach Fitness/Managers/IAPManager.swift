//
//  IAPManager.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import Foundation
import RevenueCat

final class IAPManager {
    
    static let shared = IAPManager()
//    private let currentUserEmail = UserDefaults.standard.string(forKey: "email")
//    
    private init() {}
    
    public func getOfferingPrice(identifier: String, completion: @escaping  (String)->()) {
        Purchases.shared.getOfferings { offerings, error in
            if let error = error {
                print (error.localizedDescription)
            } else {
                let currentOffering = offerings?.offering(identifier: identifier)
                if let package = currentOffering?.availablePackages[0] {
                    let productPriceString = package.storeProduct.localizedPriceString
                    completion(productPriceString)
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
    
//    public func purchase(program: String, package: RevenueCat.Package, completion: @escaping (Bool, Error) -> ()) {
//        Purchases.shared.purchase(package: package) { (transaction, customerInfo, error, userCancelled) in
//            if let error = error {
//                completion (false, error)
//            } else {
//                if customerInfo?.entitlements[program]?.isActive == true {
//                        completion (true, error)
//                    }
//
//                }
//            }
//        }
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
 
    public func fetchPackages(identifier: String, completion: @escaping (RevenueCat.Package?) -> ()) {
        Purchases.shared.getOfferings {offerings, error in
            guard let package = offerings?.offering(identifier: identifier)?.availablePackages.first,
                  error == nil else {
            completion(nil)
                print ("no fackage fetched")
                return
            }
            completion(package)
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

