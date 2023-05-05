//
//  IAPManager.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import Foundation
import Purchases
import StoreKit

final class IAPManager {
    
    static let shared = IAPManager()
    private let currentUserEmail = UserDefaults.standard.string(forKey: "email")
    
    private init() {}
    
    public func getSubscriptionStatus() {
        Purchases.shared.purchaserInfo { info, error in
            guard let entitlements = info?.entitlements,
                    error == nil else {return}
            print(entitlements)
        }
    }

    public func subscribe(package: Purchases.Package, completion: @escaping (Bool) ->()) {
        Purchases.shared.purchasePackage(package) { transaction, info, error, userCancelled in
            guard let transaction = transaction,
                  let entitlements = info?.entitlements,
                  error == nil,
                  !userCancelled else {return}
            switch transaction.transactionState {
                
            case .purchasing:
                print("purchasing")
            case .purchased:
                print("purchased \(entitlements)")
                guard let email = self.currentUserEmail else {return}
                DatabaseManager.shared.updateUserSubscriptions(email: email, subscription: "ECD") { success in
                    print("successfully updated users subscriptions")
                }
            case .failed:
                print("failed")
            case .restored:
                print ("restored")
            case .deferred:
                print ("deferred")
            @unknown default:
                print ("default case")
            }
        }

    }

    public func fetchPackages(completion: @escaping (Purchases.Package?) -> ()) {
        Purchases.shared.offerings {offerings, error in
            guard let package = offerings?.offering(identifier: "default")?.availablePackages.first,
                  error == nil else {
            completion(nil)
                return
            }
            completion(package)
        }
    }

    public func restorePurchases() {
        Purchases.shared.restoreTransactions { info, error in
            guard let entitlements = info?.entitlements,
                    error == nil else {return}
            print("restored \(entitlements)")
        }
    }

}

