//
//  BlogTableViewCell.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 5/4/23.
//

import UIKit

class BlogTableViewCell: UITableViewCell {
    
    private var baseInset: CGFloat { return 15 }
    
    var post: Post? {
        didSet {
            postDateLabel.text = post?.date
            postDescriptionTextView.text = post?.description
            likesLabel.text = "\(post?.likes ?? 0)"
//            switch post?.comments {
//            case 0: commentsLabel.text = "No comments posted yet"
//            case 1: commentsLabel.text = "\(post?.comments ?? 1) comment "
//            default: commentsLabel.text = "\(post?.comments ?? 111) comments"
//            }
        }
    }
    
    var onCommentsPush: (()->())?
    var onLikeButtonPush: (()->())?
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.cornerRadius = 5
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 5
        view.layer.shadowOffset = CGSize(width: 5, height: 5)
        view.layer.shadowOpacity = 0.7
        view.alpha = 0.8
        view.toAutoLayout()
        return view
    }()

    let postDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
        label.backgroundColor = .white
        label.textAlignment = .right
        label.numberOfLines = 0
        label.toAutoLayout()
        return label
    }()
    
    let postDescriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textView.textColor = .black
        textView.textAlignment = .left
        textView.isEditable = false
        textView.linkTextAttributes = [.foregroundColor: UIColor.systemBlue]
        textView.isSelectable = true
        textView.backgroundColor = .white
        textView.isUserInteractionEnabled = true
        textView.sizeToFit()
        textView.isScrollEnabled = false
        textView.dataDetectorTypes = .link
        textView.toAutoLayout()
        return textView
    }()

    private lazy var addCommentButton: UIButton = {
        let button = UIButton()
        button.toAutoLayout()
        button.tintColor = .white
        button.setImage(UIImage(systemName: "message", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
        button.addTarget(self, action: #selector(pushCommentsVC), for: .touchUpInside)
        return button
    }()
    
    lazy var likeButton: UIButton = {
        let button = UIButton()
        button.toAutoLayout()
        button.tintColor = .white
        button.setImage(UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
        button.addTarget(self, action: #selector(addLikeToWorkout), for: .touchUpInside)
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
//        label.alpha = 0
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
        contentView.addSubviews(containerView, stackView)
        containerView.addSubviews(postDateLabel, postDescriptionTextView)
        stackView.addArrangedSubview(likeButton)
        stackView.addArrangedSubview(likesLabel)
        stackView.addArrangedSubview(addCommentButton)
        stackView.addArrangedSubview(commentsLabel)
        
        let minHeight: CGFloat = postDescriptionTextView.font?.lineHeight ?? 50
        
        let constraints = [
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: baseInset),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: baseInset),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -baseInset),
            containerView.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -baseInset),
            
            postDateLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: baseInset),
            postDateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: baseInset),
            postDateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -baseInset),
            
            postDescriptionTextView.topAnchor.constraint(equalTo: postDateLabel.bottomAnchor, constant: baseInset),
            postDescriptionTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: baseInset),
            postDescriptionTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -baseInset),
            postDescriptionTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: minHeight),
            postDescriptionTextView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -baseInset), 
            
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
        self.onCommentsPush?()
    }
    
    @objc private func addLikeToWorkout() {
        self.onLikeButtonPush?()
    }

}
