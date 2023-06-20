//
//  SceneDelegate.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit
import IQKeyboardManagerSwift


class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)

        var vc: UIViewController?
        let hasAgreedToPrivacyPolicy = UserDefaults.standard.bool(forKey: "HasAgreedToPrivacyPolicy")
        
        if shouldSignOutUser() {
            AuthManager.shared.signOut { success in
                if success {
                    DispatchQueue.main.async {
                        vc = LoginViewController()
                        window.rootViewController = vc
                        window.makeKeyAndVisible()
                    }
                } else {
                    print ("Error logging out user")
                }
            }
        } else {
            if AuthManager.shared.isSignedIn  && hasAgreedToPrivacyPolicy {
                let userEmail = UserDefaults.standard.string(forKey: "email")
                if let email = userEmail, !email.isEmpty {
                    print ("there is a current user with data")
                    vc = TabBarController()
                } else {
                    // user is signed in but there is no user data for him or her, need to logout user and present loginVC
                    print ("user is signed in but there is no user data for him or her, need to logout user and present loginVC")
                    AuthManager.shared.signOut { success in
                        if success {
                            let signInVC = LoginViewController()
                            signInVC.navigationItem.largeTitleDisplayMode = .never
                            let navVC = UINavigationController(rootViewController: signInVC)
                            navVC.navigationBar.prefersLargeTitles = false
                            vc = navVC
                        } else {
                            print ("error loging out user without data")
                        }
                    }
                }
            } else {
                //user is not signed in
                let signInVC = LoginViewController()
                signInVC.navigationItem.largeTitleDisplayMode = .never
                let navVC = UINavigationController(rootViewController: signInVC)
                navVC.navigationBar.prefersLargeTitles = false
                vc = navVC
            }
        }
        
        window.rootViewController = vc
        window.makeKeyAndVisible()
        self.window = window
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(CommentsViewController.self)
        IQKeyboardManager.shared.disabledToolbarClasses.append(CommentsViewController.self)
        IQKeyboardManager.shared.toolbarTintColor = .contrastGreen
    }
    
    private func shouldSignOutUser() -> Bool {
        
        guard let lastSignInDate = AuthManager.shared.lastSignInDate else {
            print ("last sign in date is not set")
            return false
        }
        print("lastSignInDate: \(lastSignInDate)")
        
        let currentDate = Date()
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.day], from: lastSignInDate, to: currentDate)
        print ("should sign out user completion: \(components.day ?? 0 >= 7)")
        return components.day ?? 0 >= 7
    }
}

