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
     
        let vc: UIViewController
        if AuthManager.shared.isSignedIn {
            guard let userId = AuthManager.shared.userId,
                  let userUID = AuthManager.shared.userUID else {return}
            let safeUserId = userId
                .replacingOccurrences(of: "@", with: "_")
                .replacingOccurrences(of: ".", with: "_") + userUID
            IAPManager.shared.logInRevenueCat(userId: safeUserId) { error in
                print(error.localizedDescription)
            }
            vc = TabBarController()
        } else {
            let signInVC = LoginViewController()
            signInVC.navigationItem.largeTitleDisplayMode = .never
            let navVC = UINavigationController(rootViewController: signInVC)
            navVC.navigationBar.prefersLargeTitles = false
            vc = navVC
        }

        window.rootViewController = vc
        window.makeKeyAndVisible()
        self.window = window
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(CommentsViewController.self)
        IQKeyboardManager.shared.disabledToolbarClasses.append(CommentsViewController.self)
        IQKeyboardManager.shared.toolbarTintColor = .darkGray
        
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

