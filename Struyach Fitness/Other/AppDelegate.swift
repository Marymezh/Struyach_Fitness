//
//  AppDelegate.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications
import RevenueCat


@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //setting up Firebase and Messaging
        FirebaseApp.configure()
        
//        Messaging.messaging().delegate = self
//        UNUserNotificationCenter.current().delegate = self
//
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
//            if let error = error {
//                print ("Unable to register in APNS \(error.localizedDescription)")
//
//            } else {
//                print ("success in APNS registry")
//            }
//        }
//
//        application.registerForRemoteNotifications()
        
        //setting up Revenue Cat "Purchases"
        
        var apiKey: String {
          get {
            guard let filePath = Bundle.main.path(forResource: "Purchases-Info", ofType: "plist") else {
              fatalError("Couldn't find file 'Purchases-Info.plist'.")
            }
            let plist = NSDictionary(contentsOfFile: filePath)
            guard let value = plist?.object(forKey: "API_KEY") as? String else {
              fatalError("Couldn't find key 'API_KEY' in 'Purchases-Info.plist'.")
            }
            return value
          }
        }
        
//        Purchases.logLevel = .debug
        Purchases.configure(with: Configuration.Builder(withAPIKey: apiKey)
            .with(usesStoreKit2IfAvailable: false)
            .build())
        Purchases.shared.delegate = self
        
        
        // setting up application language
        let currentLanguage = LanguageManager.shared.currentLanguage
        LanguageManager.shared.setCurrentLanguage(currentLanguage)
        print("print language on app launch \(currentLanguage)")
        
        return true
    }

    // MARK: UISceneSession Lifecycle
    
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        messaging.token { token, error in
//            if let  error = error {
//                print ("Error fetching FCM token \(error.localizedDescription)")
//            } else if let token = token {
//                print ("FCM registration token is received: \(token)")
//            }
//        }
//    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {

    }
}

extension AppDelegate: PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        print("modified")
    }
}
