//
//  NotificationTableViewCell.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 26/4/23.
//

import UIKit

final class NotificationTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "NotificationCell"
    
    var programName: String?
    
    let containerView: UIView = {
        let containerView = UIView()
        containerView.toAutoLayout()
        containerView.backgroundColor = .customTabBar
        return containerView
    }()

    var notificationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var notificationSwitch: UISwitch = {
        let notificationSwitch = UISwitch()
        notificationSwitch.translatesAutoresizingMaskIntoConstraints = false
        return notificationSwitch
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Configuration
    
    private func configureUI() {
        selectionStyle = .none
        self.backgroundColor = .customDarkGray
        contentView.addSubview(containerView)
        containerView.addSubview(notificationLabel)
        containerView.addSubview(notificationSwitch)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            notificationLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            notificationLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            notificationSwitch.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            notificationSwitch.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }

    func configure(with title: String, isSubscribed: Bool) {
        let program = title.replacingOccurrences(of: " ", with: "_")
        let areNotificationsEnabled = NotificationsManager.shared.checkNotificationPermissions()
        let isNotificationOn = areNotificationsEnabled && isSubscribed
        
        notificationLabel.text = title
        programName = title
        notificationSwitch.isEnabled = isNotificationOn
       
        
        // Update the switch state based on notification permission and subscription status
        notificationSwitch.isOn = isNotificationOn && UserDefaults.standard.bool(forKey: program)
    }
}
