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
    
    weak var delegate: LanguageSwitchDelegate?
    
    private lazy var engButton: UIButton = {
        let button = UIButton()
        button.setTitle(Language.english.rawValue, for: .normal)
        button.addTarget(self, action: #selector(switchLanguage(_:)), for: .touchUpInside)
        button.tag = Language.english.rawValue.hashValue // assign a tag based on the rawValue hash to distinguish from Russian button
        return button
    }()
    
    private lazy var rusButton: UIButton = {
        let button = UIButton()
        button.setTitle(Language.russian.rawValue, for: .normal)
        button.addTarget(self, action: #selector(switchLanguage(_:)), for: .touchUpInside)
        button.tag = Language.russian.rawValue.hashValue // assign a tag based on the rawValue hash to distinguish from English button
        return button
    }()
    
    private let languageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "App language / Язык приложения"
        label.textColor = .white
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .customDarkGray
        selectionStyle = .none
        contentView.addSubview(languageLabel)
        contentView.addSubview(engButton)
        contentView.addSubview(rusButton)
        
        languageLabel.toAutoLayout()
        NSLayoutConstraint.activate([
            languageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            languageLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        engButton.toAutoLayout()
        NSLayoutConstraint.activate([
            engButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            engButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        rusButton.toAutoLayout()
        NSLayoutConstraint.activate([
            rusButton.trailingAnchor.constraint(equalTo: engButton.leadingAnchor, constant: -8),
            rusButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(language: Language) {
        
        // Set the default selected language to English
        engButton.isSelected = (language == .english)
        rusButton.isSelected = (language == .russian)
        
        // Set the button labels based on selected state
        let normalAttributes: [NSAttributedString.Key: Any] = [        .font: UIFont.systemFont(ofSize: 16),        .foregroundColor: UIColor.white    ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [        .font: UIFont.boldSystemFont(ofSize: 16),        .foregroundColor: UIColor.systemGreen    ]
        engButton.setAttributedTitle(NSAttributedString(string: "en", attributes: engButton.isSelected ? selectedAttributes : normalAttributes), for: .normal)
        rusButton.setAttributedTitle(NSAttributedString(string: "ru", attributes: rusButton.isSelected ? selectedAttributes : normalAttributes), for: .normal)
    }
    
    @objc func switchLanguage(_ sender: UIButton) {
        let language: Language = sender.tag == Language.english.rawValue.hashValue ? .english : .russian
        delegate?.didSwitchLanguage(to: language)
    }
}
