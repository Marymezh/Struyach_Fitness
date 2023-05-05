//
//  EmailTableViewCell.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 26/4/23.
//

import UIKit
import MessageUI

final class EmailTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    static let reuseIdentifier = "EmailCell"
    private let mailComposer = MFMailComposeViewController()

    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .customDarkGray
        textLabel?.text = "Send email to developer".localized()
        textLabel?.textColor = .white
        imageView?.image = UIImage(named: "mail")
        
        let disclosureIndicator = UIImageView(image: UIImage(systemName: "chevron.right"))
        disclosureIndicator.contentMode = .scaleAspectFit
        disclosureIndicator.tintColor = .white
        accessoryView = disclosureIndicator
        
        mailComposer.mailComposeDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helper Functions
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            mailComposer.setToRecipients(["maria.mezhova@yahoo.com"])
            mailComposer.setSubject("App Feedback".localized())
            mailComposer.setMessageBody("Dear Developer,\n\nI have some feedback about the app...\n\nSincerely,\n[Your Name]".localized(), isHTML: false)

            // Set appearance of the mail composer
            mailComposer.navigationBar.setAppearanceForMailComposer()
            mailComposer.view.backgroundColor = .customDarkGray

            if let viewController = UIApplication.shared.windows.first?.rootViewController {
                viewController.present(mailComposer, animated: true, completion: nil)
            }
        } else {
            // Unable to send mail - handle error
        }
    }
}

// MARK: - MFMailComposeViewControllerDelegate

extension EmailTableViewCell: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension UINavigationBar {
    func setAppearanceForMailComposer() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .customDarkGray
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.shadowColor = nil
        self.tintColor = .systemGreen
        self.standardAppearance = appearance
//        self.scrollEdgeAppearance = appearance
    }
}
