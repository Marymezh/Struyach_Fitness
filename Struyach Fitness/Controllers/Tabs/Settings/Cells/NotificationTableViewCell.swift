//
//  NotificationTableViewCell.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 26/4/23.
//

import UIKit

final class NotificationTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    var programName: String?
    
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
        self.backgroundColor = .customDarkGray
        addSubview(notificationLabel)
        addSubview(notificationSwitch)
        
        NSLayoutConstraint.activate([
            notificationLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            notificationLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            notificationSwitch.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            notificationSwitch.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
//    func configure(with title: String, isNotificationOn: Bool, isSubscribed: Bool) {
//        notificationLabel.text = title
//        notificationSwitch.isOn = isNotificationOn
//        notificationSwitch.isEnabled = isSubscribed
//    }
        func configure(with title: String, isSubscribed: Bool) {
            notificationLabel.text = title
            programName = title
            notificationSwitch.isEnabled = isSubscribed
        }
    
}
