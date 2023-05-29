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
   //         descriptionLabel.text = program?.programDetail
            self.backgroundView = UIImageView(image: UIImage(named: program?.cellImage ?? "No Image"))
        }
    }
    
    var programNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .left
        label.textColor = .white
        label.shadowColor = .black
        label.shadowOffset = CGSize(width: 1, height: 1)
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.toAutoLayout()
        return label
    }()
    
    private var baseInset: CGFloat { return 16 }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let disclosureIndicator = UIImageView(image: UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)))
        disclosureIndicator.contentMode = .scaleAspectFit
        disclosureIndicator.tintColor = .white
        disclosureIndicator.layer.masksToBounds = false
        disclosureIndicator.layer.shadowColor = UIColor.black.cgColor
        disclosureIndicator.layer.shadowOffset = CGSize(width: 1, height: 1)
        disclosureIndicator.layer.shadowOpacity = 0.5
        disclosureIndicator.layer.shadowRadius = 2.0

        accessoryView = disclosureIndicator
        
        contentView.addSubview(programNameLabel)
        
        let constraints = [
            
            programNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -baseInset),
            programNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: baseInset)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
