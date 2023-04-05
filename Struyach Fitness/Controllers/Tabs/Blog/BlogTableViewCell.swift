//
//  BlogTableViewCell.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 5/4/23.
//

import UIKit

class BlogTableViewCell: UITableViewCell {
    
    private let selectedWorkoutView = SelectedWorkoutView()
    private var baseInset: CGFloat { return 15 }

    private lazy var addCommentButton: UIButton = {
        let button = UIButton()
        button.toAutoLayout()
        button.tintColor = .white
        button.setImage(UIImage(systemName: "message", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
        button.addTarget(self, action: #selector(pushCommentsVC), for: .touchUpInside)
        return button
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.toAutoLayout()
        button.tintColor = .white
        button.setImage(UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
        button.addTarget(self, action: #selector(addLikeToWorkout), for: .touchUpInside)
        return button
    }()
    
    private let likesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .white
        label.text = "0"
        label.toAutoLayout()
        return label
    }()

    private let commentsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .white
        label.toAutoLayout()
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .equalSpacing
        stackView.axis = .horizontal
        stackView.alignment = .center
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
    
    private func setupSubviews(){
        contentView.backgroundColor = .customDarkGray
        selectedWorkoutView.toAutoLayout()
        contentView.addSubviews( selectedWorkoutView, stackView)
        stackView.addArrangedSubview(likeButton)
        stackView.addArrangedSubview(likesLabel)
        stackView.addArrangedSubview(addCommentButton)
        stackView.addArrangedSubview(commentsLabel)
        
        let constraints = [
            
            selectedWorkoutView.topAnchor.constraint(equalTo: contentView.topAnchor),
            selectedWorkoutView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            selectedWorkoutView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            selectedWorkoutView.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -baseInset),
            
            likeButton.widthAnchor.constraint(equalToConstant: 35),
            likeButton.heightAnchor.constraint(equalTo: likeButton.widthAnchor),
            likesLabel.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: baseInset),
            likesLabel.widthAnchor.constraint(equalTo: likeButton.widthAnchor),
            addCommentButton.widthAnchor.constraint(equalToConstant: 35),
            addCommentButton.heightAnchor.constraint(equalToConstant: 35),
            commentsLabel.leadingAnchor.constraint(equalTo: addCommentButton.trailingAnchor, constant: baseInset),
            
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: baseInset),
            stackView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -baseInset*2),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -baseInset)

        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc private func pushCommentsVC() {
//        guard let selectedWorkout = selectedWorkout else { print("workout is not selected")
//            return }
//        let commentsVC = CommentsViewController(workout: selectedWorkout)
//        commentsVC.title = "Comments"
//    
//        navigationController?.pushViewController(commentsVC, animated: true)
    }
    
    @objc private func addLikeToWorkout() {
        likeButton.isSelected = !likeButton.isSelected
        
        if likeButton.isSelected {
            likeButton.setImage(UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
            likeButton.tintColor = .systemRed
        } else {
            likeButton.setImage(UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
            likeButton.tintColor = .white
        }
    }

}
