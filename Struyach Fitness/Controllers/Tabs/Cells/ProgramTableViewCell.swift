//
//  ProgramTableViewCell.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit

final class ProgramTableViewCell: UITableViewCell {
    
    var program: ProgramDescription? {
        didSet {
            programNameLabel.text = program?.programName
            descriptionLabel.text = program?.programDetail
            self.backgroundView = UIImageView(image: UIImage(named: program?.cellImage ?? "No Image"))
        }
    }
    
    var programNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .left
        label.textColor = .white
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.toAutoLayout()
        return label
    }()
    
    var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .left
        label.textColor = .white
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.toAutoLayout()
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .leading
        stackView.toAutoLayout()
        return stackView
    }()
    
    private var baseInset: CGFloat { return 16 }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(programNameLabel)
        stackView.addArrangedSubview(descriptionLabel)

        let constraints = [
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: baseInset),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: baseInset),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -baseInset),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -baseInset)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
