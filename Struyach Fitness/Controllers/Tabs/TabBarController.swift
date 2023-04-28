//
//  TabBarController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupControllers()
        setupTabBarAppearance()
        setupNavBarAppearance()
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .customTabBar
        tabBar.standardAppearance = appearance
     //   tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = .systemGreen
        tabBar.unselectedItemTintColor = .darkGray
        tabBar.backgroundColor = .customDarkGray
    }
    
    private func setupNavBarAppearance() {
        UINavigationBar.appearance().tintColor = .systemGreen
        UINavigationBar.appearance().barTintColor = .black
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
 //       if #available(iOS 15.0, *) {
           let appearance = UINavigationBarAppearance()
           appearance.configureWithDefaultBackground()
           appearance.backgroundColor = .black
           appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
           appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
           UINavigationBar.appearance().standardAppearance = appearance
      //     UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    private func setupControllers() {
        guard let currentUserEmail = UserDefaults.standard.string(forKey: "email") else {return}
        let programsVC = ProgramsViewController()
        programsVC.title = "Programs"
        
        let blogVC = BlogViewController()
        blogVC.title = "Coach Blog"
        
        let profileVC = ProfileTableViewController(email: currentUserEmail)
        profileVC.title = "Profile"
        
        let settingsVC = SettingsTableViewController(email: currentUserEmail)
        settingsVC.title = "Settings"
        
        programsVC.navigationItem.largeTitleDisplayMode = .always
        blogVC.navigationItem.largeTitleDisplayMode = .always
        profileVC.navigationItem.largeTitleDisplayMode = .always
        profileVC.fetchUserRecords()
        profileVC.fetchProfileData()
        
        let nav1 = UINavigationController(rootViewController: programsVC)
        let nav2 = UINavigationController(rootViewController: blogVC)
        let nav3 = UINavigationController(rootViewController: profileVC)
        let nav4 = UINavigationController(rootViewController: settingsVC)
        
        nav1.navigationBar.prefersLargeTitles = true
        nav2.navigationBar.prefersLargeTitles = true
        nav3.navigationBar.prefersLargeTitles = true
        nav4.navigationBar.prefersLargeTitles = true
        
        nav1.tabBarItem = UITabBarItem(title: "Programs", image: UIImage(named:"list.bullet.clipboard.fill" ), tag: 1)
        nav2.tabBarItem = UITabBarItem(title: "Blog", image: UIImage(named: "character.bubble.fill"), tag: 2)
        nav3.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "figure.strengthtraining.traditional"), tag: 3)
        nav4.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: "gearshape.fill"), tag: 3)

        setViewControllers([nav1, nav2, nav3, nav4], animated: true)
    }
}
