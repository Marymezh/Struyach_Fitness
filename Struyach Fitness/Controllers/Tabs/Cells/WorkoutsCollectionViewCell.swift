//
//  WorkoutsCollectionViewCell.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 3/3/23.
//

import UIKit

final class WorkoutsCollectionViewCell: UICollectionViewCell {

    var workout: Workout? {
        didSet{
            self.workoutDateLabel.text = workout?.date.localized()
        }
    }
    
    let workoutDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = .systemGreen
        label.numberOfLines = 0
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.toAutoLayout()
        return label
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    //    prepareForReuse()
    }
    
    deinit {
         print ("workout cell is deallocated")
    }

    private func setupUI() {
        contentView.layer.cornerRadius = 10
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowRadius = 10
        contentView.layer.shadowOffset = CGSize(width: 1, height: 1)
        contentView.layer.shadowOpacity = 0.3
        contentView.backgroundColor = .customDarkGray
        contentView.addSubview(workoutDateLabel)
        
        let constraints = [
            workoutDateLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            workoutDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            workoutDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            workoutDateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.workoutDateLabel.backgroundColor = .systemGreen
    }
}
