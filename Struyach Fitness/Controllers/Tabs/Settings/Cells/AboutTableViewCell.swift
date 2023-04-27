//
//  AboutTableViewCell.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 26/4/23.
//

import UIKit

class AboutTableViewCell: UITableViewCell {

    // MARK: - Properties
      
      static let reuseIdentifier = "AboutCell"
      
      // MARK: - Initialization
      
      override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
          super.init(style: style, reuseIdentifier: reuseIdentifier)
          self.backgroundColor = .customDarkGray
          textLabel?.text = "About this app"
          textLabel?.textColor = .white
          imageView?.image = UIImage(systemName: "info.circle")
          imageView?.tintColor = .systemGreen
          
          let disclosureIndicator = UIImageView(image: UIImage(systemName: "chevron.right"))
              disclosureIndicator.contentMode = .scaleAspectFit
              disclosureIndicator.tintColor = .white
              accessoryView = disclosureIndicator
      }
      
      required init?(coder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
      }

  }
