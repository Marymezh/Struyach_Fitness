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
    
    func showAlert(title: String, message: String, cancelAction: String, completion: ((UIAlertAction) -> Void)? = nil) {
        guard let topViewController = UIApplication.shared.topViewController else {return}
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: cancelAction, style: .cancel, handler: completion)
        alert.addAction(cancelAction)
        alert.view.tintColor = .contrastGreen

        topViewController.present(alert, animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String, continueAction: String, continueCompletion: ((UIAlertAction) -> Void)?,  cancelAction: String, completion: ((UIAlertAction) -> Void)? = nil) {
        guard let topViewController = UIApplication.shared.topViewController else {return}
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let continueAction = UIAlertAction(title: continueAction, style: .default, handler: continueCompletion)
        let cancelAction = UIAlertAction(title: cancelAction, style: .cancel, handler: completion)
        alert.addAction(continueAction)
        alert.addAction(cancelAction)
        alert.view.tintColor = .contrastGreen

        topViewController.present(alert, animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String?, placeholderText: String, cancelAction: String, cancelCompletion: ((UIAlertAction) -> Void)? = nil, confirmActionTitle: String, confirmActionHandler: @escaping ((Bool, String?) -> Void)) {
        guard let topViewController = UIApplication.shared.topViewController else {return}
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { textfield in
            textfield.placeholder = placeholderText
        }
        let confirmAction = UIAlertAction(title: confirmActionTitle, style: .default) { action in
            if let text = alert.textFields?[0].text, text != "" {
                confirmActionHandler(true, text)
            } else {
                confirmActionHandler(false, nil)
            }
        }
        let cancelAction = UIAlertAction(title: cancelAction, style: .destructive, handler: cancelCompletion)
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)

        alert.view.tintColor = .contrastGreen
        topViewController.present(alert, animated: true, completion: nil)
    }
    
    func showActionSheet(title: String, message: String, cancelHandler: ((UIAlertAction) -> Void)?, confirmActionTitle: String, confirmHandler: @escaping ((UIAlertAction) -> Void)) {
        guard let topViewController = UIApplication.shared.topViewController else {return}
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let confirmAction = UIAlertAction(title: confirmActionTitle, style: .destructive, handler: confirmHandler)
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: cancelHandler)
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        alert.view.tintColor = .contrastGreen
        
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
