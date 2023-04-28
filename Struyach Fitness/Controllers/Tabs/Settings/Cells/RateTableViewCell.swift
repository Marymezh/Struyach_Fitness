//
//  RateTableViewCell.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 26/4/23.
//

import UIKit
import StoreKit

final class RateTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "RateCell"
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .customDarkGray
        textLabel?.text = "Rate this app"
        textLabel?.textColor = .white
        imageView?.image = UIImage(systemName: "star")
        imageView?.tintColor = .systemGreen
        
        let disclosureIndicator = UIImageView(image: UIImage(systemName: "chevron.right"))
            disclosureIndicator.contentMode = .scaleAspectFit
            disclosureIndicator.tintColor = .white
            accessoryView = disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helper Functions
    
    func openAppRatingPage() {
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id389801252") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print ("unable to open app raiting page")
        }
    }
    
}
