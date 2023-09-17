//
//  AppColorTableViewCell.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 13.09.2023.
//

import UIKit

protocol ColorChangeDelegate: AnyObject {
    func didChangeColor()
}

final class AppColorTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "AppColorCell"
    
    let containerView: UIView = {
        let containerView = UIView()
        containerView.toAutoLayout()
        containerView.backgroundColor = .customTabBar
        return containerView
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.toAutoLayout()
        return stackView
    }()
    
    var colorButtons: [UIButton] = []
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Create and configure buttons
    private func setupSubviews() {
        self.backgroundColor = .customDarkGray
        selectionStyle = .none
        let colors: [UIColor] = [.customBlue ?? .systemBlue, .customCyan ?? .systemTeal, .customMint!, .customGreen ?? .systemGreen, .customOrange ?? .systemOrange, .customPink ?? .systemPink, .customPurple ?? .systemPurple]
        
        for color in colors {
            let button = UIButton(type: .system)
            button.backgroundColor = color
            button.toAutoLayout()
            button.layer.cornerRadius = 15
            button.isUserInteractionEnabled = true
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            colorButtons.append(button)
            stackView.addArrangedSubview(button)
        }
        contentView.addSubview(containerView)
        containerView.addSubview(stackView)
        
        
        let constraints = [
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        print ("you selected new app color")
        guard let color = sender.backgroundColor else { return }
        UserDefaults.standard.setColor(color: color, forKey: "SelectedColor")
        NotificationCenter.default.post(name: Notification.Name("AppColorChanged"), object: color)
    }
}
