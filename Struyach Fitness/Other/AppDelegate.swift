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
//import FirebaseAppCheck


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //setting up Firebase and Messaging
//        let providerFactory = AppCheckDebugProviderFactory()
//        AppCheck.setAppCheckProviderFactory(providerFactory)
//
//
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().delegate = self

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
            if let error = error {
                print ("Unable to register in APNS \(error.localizedDescription)")
            } else {
                print ("success in APNS registry")
            }
        }
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        
 //       setting up Revenue Cat "Purchases"
        
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
        
        #if Client
        Purchases.configure(with: Configuration.Builder(withAPIKey: apiKey)
            .with(usesStoreKit2IfAvailable: true)
            .build())
        Purchases.shared.delegate = self
        #endif
        
        // setting up application language
        let currentLanguage = LanguageManager.shared.currentLanguage
        LanguageManager.shared.setCurrentLanguage(currentLanguage)
        
        
        //delete badge from app icon
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {

    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        IAPManager.shared.logOutRevenueCat { error in
            AlertManager.shared.showAlert(title: "Error".localized(), message: "Unable to log out from purchases", cancelAction: "Cancel".localized(), style: .cancel)
            print (error.localizedDescription)
        }
    }
}

extension AppDelegate: PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        print("received updated customerInfo")
    }
}
    
    extension AppDelegate: UNUserNotificationCenterDelegate {
        func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
               Messaging.messaging().apnsToken = deviceToken
           }

}

// MARK: Messaging Delegate methods
extension AppDelegate: MessagingDelegate {

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        messaging.token { token, error in
            if let  error = error {
                print ("Error fetching FCM token \(error.localizedDescription)")
            } else if let token = token {
                print ("FCM registration token is received: \(token)")
            //    NotificationsManager.shared.subscribe(to: "Bodyweight")
                
                let dataDict: [String: String] = ["FCMtoken": token]
                 NotificationCenter.default.post(
                   name: Notification.Name("FCMToken"),
                   object: token,
                   userInfo: dataDict)
                UserDefaults.standard.set(fcmToken, forKey: "fcmToken")
            }
        }
    }
}
