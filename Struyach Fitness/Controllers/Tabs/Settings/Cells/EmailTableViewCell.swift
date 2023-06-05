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
    
    let containerView: UIView = {
        let containerView = UIView()
        containerView.toAutoLayout()
        containerView.backgroundColor = .customTabBar
        return containerView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.toAutoLayout()
        label.text = "Send email to developer".localized()
        label.textColor = .white
        return label
    }()
    
    private let imgView: UIImageView = {
        let imageView = UIImageView()
        imageView.toAutoLayout()
        imageView.image = UIImage(named: "mail")
        imageView.tintColor = .systemGreen
        return imageView
    }()

    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupSubviews()
        mailComposer.mailComposeDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helper Functions
    
    private func setupSubviews() {
        self.backgroundColor = .customDarkGray
        selectionStyle = .none
        let disclosureIndicator = UIImageView(image: UIImage(systemName: "chevron.right"))
        disclosureIndicator.contentMode = .scaleAspectFit
        disclosureIndicator.tintColor = .white
        accessoryView = disclosureIndicator
        
        self.addSubviews(containerView)
        containerView.addSubviews(imgView,titleLabel)
        
        let constraints = [
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            imgView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            imgView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            
            titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 45)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func sendEmail(completion: ((Error?)->())?) {
        if MFMailComposeViewController.canSendMail() {
            mailComposer.setToRecipients(["maria.mezhova@yahoo.com"])
            mailComposer.setSubject("App Feedback".localized())
            mailComposer.setMessageBody("Dear Developer,\n\nI have some feedback about the app...\n\nSincerely,\n[Your Name]".localized(), isHTML: false)
            mailComposer.navigationBar.setAppearanceForMailComposer()
            mailComposer.view.backgroundColor = .customDarkGray

            if let viewController = UIApplication.shared.windows.first?.rootViewController {
                viewController.present(mailComposer, animated: true, completion: nil)
            }
        } else {
            let error = NSError(domain: "Can't send email", code: 0, userInfo: nil)
                completion?(error)
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
    }
}
