//
//  LanguageSwitchTableViewCell.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 26/4/23.
//
//
import UIKit

enum Language: String {
    case english = "en"
    case russian = "ru"
}

protocol LanguageSwitchDelegate: AnyObject {
    func didSwitchLanguage(to language: Language)
}

final class LanguageSwitchTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "LanguageSwitchCell"
    
    weak var delegate: LanguageSwitchDelegate?
    
    private let containerView: UIView = {
        let containerView = UIView()
        containerView.toAutoLayout()
        containerView.layer.cornerRadius = 15
        containerView.backgroundColor = .customTabBar
        return containerView
    }()

    private lazy var engButton: UIButton = {
        let button = UIButton()
        button.toAutoLayout()
        button.setTitle(Language.english.rawValue, for: .normal)
        button.addTarget(self, action: #selector(switchLanguage(_:)), for: .touchUpInside)
        button.tag = Language.english.rawValue.hashValue
        return button
    }()
    
    private lazy var rusButton: UIButton = {
        let button = UIButton()
        button.toAutoLayout()
        button.setTitle(Language.russian.rawValue, for: .normal)
        button.addTarget(self, action: #selector(switchLanguage(_:)), for: .touchUpInside)
        button.tag = Language.russian.rawValue.hashValue
        return button
    }()
    
    private let languageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "App language / Язык приложения"
        label.textColor = .white
        label.toAutoLayout()
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .customDarkGray
        selectionStyle = .none
        contentView.addSubview(containerView)
        containerView.addSubviews(languageLabel, engButton, rusButton)
   
        
        let constraints = [
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            languageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            languageLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            engButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            engButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            rusButton.trailingAnchor.constraint(equalTo: engButton.leadingAnchor, constant: -5),
            rusButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(language: Language) {
        
        engButton.isSelected = (language == .english)
        rusButton.isSelected = (language == .russian)
        
        // Set the button labels based on selected state
        let normalAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.white    ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 16), .foregroundColor: UIColor.systemGreen]
        engButton.setAttributedTitle(NSAttributedString(string: "en", attributes: engButton.isSelected ? selectedAttributes : normalAttributes), for: .normal)
        rusButton.setAttributedTitle(NSAttributedString(string: "ru", attributes: rusButton.isSelected ? selectedAttributes : normalAttributes), for: .normal)
    }
    
    @objc func switchLanguage(_ sender: UIButton) {
        let language: Language = sender.tag == Language.english.rawValue.hashValue ? .english : .russian
      
        if language == .english && engButton.isSelected {
            return
        } else if language == .russian && rusButton.isSelected {
            return
        }
        delegate?.didSwitchLanguage(to: language)
    }
}
