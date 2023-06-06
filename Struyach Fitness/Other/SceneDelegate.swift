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
            if AuthManager.shared.isSignedIn {
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
        IQKeyboardManager.shared.toolbarTintColor = .darkGray
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
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
}

