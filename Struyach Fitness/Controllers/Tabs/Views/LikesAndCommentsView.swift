//
//  LikesAndCommentsView.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 28/4/23.
//

import UIKit

class LikesAndCommentsView: UIView {
    
    //MARK: - Properties
    
    private var baseInset: CGFloat { return 15 }
    
    let addCommentButton: UIButton = {
        let button = UIButton()
        button.toAutoLayout()
        button.tintColor = .white
        button.setImage(UIImage(systemName: "message", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
        return button
    }()
    
    let likeButton: UIButton = {
        let button = UIButton()
        button.toAutoLayout()
        button.tintColor = .white
        button.setImage(UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
        return button
    }()
    
    let likesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .white
        label.text = "0"
        label.toAutoLayout()
        return label
    }()

    let commentsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .white
        label.text = "Counting comments...".localized()
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

    // MARK: - Lifecycle
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    deinit {
        print("likes and comments view is deallocated")
    }
    
    private func setupSubviews() {
        self.addSubview(stackView)
        stackView.addArrangedSubview(likeButton)
        stackView.addArrangedSubview(likesLabel)
        stackView.addArrangedSubview(addCommentButton)
        stackView.addArrangedSubview(commentsLabel)
        
        let constraints = [
            likeButton.widthAnchor.constraint(equalToConstant: 35),
            likeButton.heightAnchor.constraint(equalTo: likeButton.widthAnchor),
            likesLabel.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: baseInset),
            likesLabel.widthAnchor.constraint(equalTo: likeButton.widthAnchor),
            addCommentButton.widthAnchor.constraint(equalToConstant: 35),
            addCommentButton.heightAnchor.constraint(equalToConstant: 35),
            commentsLabel.leadingAnchor.constraint(equalTo: addCommentButton.trailingAnchor, constant: baseInset),
            
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
