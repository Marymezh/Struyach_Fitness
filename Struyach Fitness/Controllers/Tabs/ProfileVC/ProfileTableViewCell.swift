//
//  ProfileTableViewCell.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
    
    private var baseInset: CGFloat { return 16 }
    
//    var weights = ["","00", "00", "00", "00", "00", "00", "00"]
    
    var weightIsSet: ((String) -> Void)?
    
    let movementLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.numberOfLines = 0
        label.toAutoLayout()
        return label
    }()
    
    let weightLabel: UILabel = {
        let label = UILabel()
        label.toAutoLayout()
        label.textAlignment = .right
//        label.text = "00 kg"
        return label
    }()
    
    private let weightTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "00 kg"
        textField.tintColor = .black
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField .frame.height))
        textField.leftViewMode = .always
        textField.keyboardType = .numberPad
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 0.5
        textField.layer.cornerRadius = 5
        return textField
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        button.toAutoLayout()
        return button
    }()
    
    @objc func saveTapped () {
        if let text = weightTextField.text {
            if text != "" {
 //               weightLabel.text = "\(text) kg"
                self.weightIsSet?(text)
//                UserDefaults.standard.set(text, forKey: "weight")
                weightTextField.text = ""
            } else {
                weightLabel.text = "00 kg"
                weightTextField.text = ""
            }
        }
    }
    
    let stackView: UIStackView = {
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
        
     //   setWeightValue()
        
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(movementLabel)
        stackView.addArrangedSubview(weightLabel)
        stackView.addArrangedSubview(weightTextField)
        stackView.addArrangedSubview(saveButton)
        
        let constraints = [
            movementLabel.widthAnchor.constraint(equalToConstant: 130),
            weightLabel.widthAnchor.constraint(equalToConstant: 60),
            weightTextField.widthAnchor.constraint(equalTo: weightLabel.widthAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 20),
            saveButton.heightAnchor.constraint(equalTo: saveButton.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: baseInset),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: baseInset),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -baseInset),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -baseInset)
//
//            weightLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: baseInset),
//            weightLabel.leadingAnchor.constraint(equalTo: movementLabel.trailingAnchor, constant: baseInset),
//            weightLabel.widthAnchor.constraint(equalToConstant: 20),
//
//            weightTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: baseInset),
//            weightTextField.leadingAnchor.constraint(equalTo: weightLabel.trailingAnchor, constant: baseInset),
//            weightTextField.widthAnchor.constraint(equalToConstant: 15),
//
//            saveButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: baseInset),
//            saveButton.leadingAnchor.constraint(equalTo: weightTextField.trailingAnchor, constant: baseInset),
//            saveButton.heightAnchor.constraint(equalToConstant: 20),
//            saveButton.widthAnchor.constraint(equalToConstant: 20)
//
        ]
        
        NSLayoutConstraint.activate(constraints)
}
    
//    private func setWeightValue() {
//        
//        if let text = UserDefaults.standard.object(forKey: "weight") as? String {
//            if text != "" {
//                weightLabel.text = "\(text) kg"
//            } else {
//                weightLabel.text = "00 kg"
//            }
//        }
//    }
}
