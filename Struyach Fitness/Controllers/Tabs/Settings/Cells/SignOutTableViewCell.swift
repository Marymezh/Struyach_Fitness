//
//  SignOutTableViewCell.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 1/5/23.
//

import UIKit

class SignOutTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "SignOutCell"
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .customDarkGray
        textLabel?.text = "Sign Out".localized()
        textLabel?.textColor = .red
    }
//        let disclosureIndicator = UIImageView(image: UIImage(systemName: "chevron.right"))
//        disclosureIndicator.contentMode = .scaleAspectFit
//        disclosureIndicator.tintColor = .white
//        accessoryView = disclosureIndicator
//    }
//
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
