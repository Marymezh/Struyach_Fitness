//
//  TabBarController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit

final class TabBarController: UITabBarController {
    
   private let selectedColor = UserDefaults.standard.colorForKey(key: "SelectedColor")
    private lazy var appColor = selectedColor ?? .systemGreen
    
    private var blogVC = BlogViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupControllers()
        setupTabBarAppearance()
        setupNavBarAppearance()
        NotificationCenter.default.addObserver(self, selector: #selector(handleColorChange(_:)), name: Notification.Name("AppColorChanged"), object: nil)
    }
    
    deinit {
           print ("tab bar is deallocated")
        NotificationCenter.default.removeObserver(self)
       }
    
    @objc func handleColorChange(_ notification: Notification) {
        print ("changing tab bar tint color")
        if let color = notification.object as? UIColor {
            self.tabBar.tintColor = color
            self.appColor = color
            self.blogVC.appColor = color
            self.blogVC.plusButtonView.plusButton.backgroundColor = color
            self.blogVC.activityView.activityIndicator.color = color
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .customTabBar
        tabBar.standardAppearance = appearance
        tabBar.tintColor = appColor
        tabBar.unselectedItemTintColor = .darkGray
        tabBar.backgroundColor = .customDarkGray
    }
    
    private func setupNavBarAppearance() {
        UINavigationBar.appearance().tintColor = appColor
        UINavigationBar.appearance().barTintColor = .black
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
           let appearance = UINavigationBarAppearance()
           appearance.configureWithDefaultBackground()
           appearance.backgroundColor = .customDarkGray
           appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
           appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
           UINavigationBar.appearance().standardAppearance = appearance
    }

    private func setupControllers() {
        guard let currentUserEmail = UserDefaults.standard.string(forKey: "email") else {return}
        print (currentUserEmail)
        updateUserToken(email: currentUserEmail)
        updateUserLanguage(email: currentUserEmail)
        let programsVC = ProgramsViewController()
        programsVC.title = "Training Plans".localized()
        let blogVC = self.blogVC
        blogVC.title = "Coach Blog".localized()
        let profileVC = ProfileTableViewController(email: currentUserEmail)
        profileVC.title = "Profile".localized()
        profileVC.navigationItem.largeTitleDisplayMode = .always
        profileVC.fetchUserRecords()
        profileVC.fetchProfileData { success in
            if success {
                print ("fetched user data successfully")
            } else {
                print ("error fetching user data")
            }
        }
        
        let settingsVC = SettingsTableViewController(email: currentUserEmail)
        settingsVC.title = "Settings".localized()
        
        programsVC.navigationItem.largeTitleDisplayMode = .always
        blogVC.navigationItem.largeTitleDisplayMode = .always
        
        let nav1 = UINavigationController(rootViewController: programsVC)
        let nav2 = UINavigationController(rootViewController: blogVC)
        let nav3 = UINavigationController(rootViewController: profileVC)
        let nav4 = UINavigationController(rootViewController: settingsVC)
        
        nav1.navigationBar.prefersLargeTitles = true
        nav2.navigationBar.prefersLargeTitles = true
        nav3.navigationBar.prefersLargeTitles = true
        nav4.navigationBar.prefersLargeTitles = true
        
        nav1.tabBarItem = UITabBarItem(title: "Plans".localized(), image: UIImage(named:"list.bullet.clipboard.fill" ), tag: 1)
        nav2.tabBarItem = UITabBarItem(title: "Blog".localized(), image: UIImage(named: "character.bubble.fill"), tag: 2)
        nav3.tabBarItem = UITabBarItem(title: "Profile".localized(), image: UIImage(named: "figure.strengthtraining.traditional"), tag: 3)
        nav4.tabBarItem = UITabBarItem(title: "Settings".localized(), image: UIImage(named: "gearshape.fill"), tag: 3)

        setViewControllers([nav1, nav2, nav3, nav4], animated: true)
    }
    // method to update current users fcm tocken for FIrebase Cloud messaging. this token is fetched on the app launch and saved to UserDefaults
    private func updateUserToken(email: String) {
        guard let token = UserDefaults.standard.string(forKey: "fcmToken") else {
            print ("token is not received")
            return
        }
        DatabaseManager.shared.updateFCMToken(email: email, newToken: token) { success in
            if success {
                print ("FCM token is updated for current user")
            }
        }
    }
    private func updateUserLanguage(email: String) {
        let currentLanguage = LanguageManager.shared.getCurrentLanguage()
        DatabaseManager.shared.updateUserLanguage(email: email, language: currentLanguage) { success in
            if success {
                print ("set current user language to \(currentLanguage)")
            }
        }
    }
}

