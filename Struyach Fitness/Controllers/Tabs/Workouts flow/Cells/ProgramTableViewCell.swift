//
//  ProgramTableViewCell.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit

class ProgramTableViewCell: UITableViewCell {
    
    var program: ProgramDescription? {
        didSet {
            programNameLabel.text = program?.programName
            descriptionLabel.text = program?.programDetail
            self.backgroundView = UIImageView(image: UIImage(named: program?.cellImage ?? "No Image"))
        }
    }
    
    private let programNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .left
        label.textColor = .white
        label.numberOfLines = 1
        label.toAutoLayout()
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .right
        label.textColor = .white
        label.numberOfLines = 0
        label.toAutoLayout()
        return label
    }()
    
    private var baseInset: CGFloat { return 16 }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubviews(programNameLabel, descriptionLabel)
        
        let constraints = [
            programNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: baseInset),
            programNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: baseInset),
            programNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -baseInset),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: baseInset),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -baseInset),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -baseInset)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
