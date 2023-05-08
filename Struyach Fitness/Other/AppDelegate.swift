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
import Purchases

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        //setting up Firebase and Messaging
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
            guard error != nil else {
                print (error?.localizedDescription)
                return
            }
            print ("success in APNS registry")
        }
        
        application.registerForRemoteNotifications()
        
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
            Purchases.configure(withAPIKey: apiKey)
            print(apiKey)
        
        // setting up application language
        let currentLanguage = LanguageManager.shared.currentLanguage
        LanguageManager.shared.setCurrentLanguage(currentLanguage)
        print("print language on app launch \(currentLanguage)")
        
        return true
    }

    // MARK: UISceneSession Lifecycle
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        messaging.token { token, error in
            guard error != nil else {
                print (error?.localizedDescription)
                return
            }
            guard let token = token else {
                print ("no token")
                return
            }
            print ("Token : \(token)")
        }
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

