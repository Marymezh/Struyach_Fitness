//
//  ProfileTableViewCell.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
    
    private var baseInset: CGFloat { return 16 }
    
    var weightIsSet: ((String) -> Void)?
    
    let movementLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .customDarkGray
        label.numberOfLines = 0
        label.toAutoLayout()
        return label
    }()
    
    let weightLabel: UILabel = {
        let label = UILabel()
        label.toAutoLayout()
        label.textColor = .customDarkGray
        label.textAlignment = .right
        return label
    }()
    
    let weightTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "00 kg"
        textField.tintColor = .black
        textField.backgroundColor = .white
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField .frame.height))
        textField.leftViewMode = .always
        textField.keyboardType = .decimalPad
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 0.5
        textField.layer.cornerRadius = 5
        return textField
    }()
    
    lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "checkmark.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)), for: .normal)
        button.tintColor = .systemGreen
        button.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        button.toAutoLayout()
        return button
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .equalSpacing
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.toAutoLayout()
        return stackView
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupSubviews()
    }
    
    @objc private func saveTapped () {
        if let text = weightTextField.text {
            if text != "" {
                self.weightIsSet?(text)
                weightTextField.text = ""
            } else {
                self.weightIsSet?("00")
                weightLabel.text = "00 kg"
                weightTextField.text = ""
            }
        }
    }
    
    private func setupSubviews() {
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(movementLabel)
        stackView.addArrangedSubview(weightLabel)
        stackView.addArrangedSubview(weightTextField)
        stackView.addArrangedSubview(saveButton)
        
        let constraints = [
            movementLabel.widthAnchor.constraint(equalToConstant: 130),
            weightLabel.widthAnchor.constraint(equalToConstant: 70),
            weightTextField.widthAnchor.constraint(equalTo: weightLabel.widthAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 20),
            saveButton.heightAnchor.constraint(equalTo: saveButton.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: baseInset),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: baseInset),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -baseInset),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -baseInset)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
