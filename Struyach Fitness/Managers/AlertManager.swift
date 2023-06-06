//
//  AlertManager.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 6/6/23.
//

import Foundation
import UIKit

final class AlertManager {
    static let shared = AlertManager()
    
    private init() {}
    
    func showAlert(title: String, message: String, cancelAction: String, style: UIAlertAction.Style, completion: ((UIAlertAction) -> Void)? = nil) {
        guard let topViewController = UIApplication.shared.topViewController else {
            return
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: cancelAction, style: style, handler: completion)
        alert.addAction(cancelAction)
        alert.view.tintColor = .systemGreen
        
        topViewController.present(alert, animated: true, completion: nil)
    }
}

extension UIApplication {
    var topViewController: UIViewController? {
        return UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController?.topViewController
    }
}

extension UIViewController {
    var topViewController: UIViewController? {
        if let presentedViewController = presentedViewController {
            return presentedViewController.topViewController
        }
        
        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController?.topViewController
        }
        
        if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.topViewController
        }
        
        return self
    }
}
