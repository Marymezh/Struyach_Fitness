//
//  TabBarController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupControllers()
        setupTabBarAppearance()
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = .black
        tabBar.unselectedItemTintColor = .darkGray
    }

    private func setupControllers() {
        guard let currentUserEmail = UserDefaults.standard.string(forKey: "email") else {return}
        let programsVC = ProgramsViewController()
        programsVC.title = "Programs"
        let profileVC = ProfileTableViewController(currentEmail: currentUserEmail)
//        let profileVC = ProfileTableViewController()
        profileVC.title = "Profile"
        
        programsVC.navigationItem.largeTitleDisplayMode = .always
        profileVC.navigationItem.largeTitleDisplayMode = .always
        
        let nav1 = UINavigationController(rootViewController: programsVC)
        let nav2 = UINavigationController(rootViewController: profileVC)
        
        nav1.navigationBar.prefersLargeTitles = true
        nav2.navigationBar.prefersLargeTitles = true
        
        nav1.tabBarItem = UITabBarItem(title: "Programs", image: UIImage(named:"list.bullet.clipboard.fill" ), tag: 1)
        nav2.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "figure.strengthtraining.traditional"), tag: 2)
        
        setViewControllers([nav1, nav2], animated: true)
    }
}
