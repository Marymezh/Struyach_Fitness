//
//  BlogTableViewCell.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 5/4/23.
//

import UIKit

final class BlogTableViewCell: UITableViewCell {
    
    //MARK: - Properties
    
    private var baseInset: CGFloat { return 15 }
    
    var post: Post? 
    
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
    
    let likesAndCommentsView = LikesAndCommentsView()
    
    //MARK: - Lifecycle
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupSubviews()
    }
    
    deinit {
         print ("blog cell is deallocated")
    }
    
    //MARK: - setup subviews and handle buttons 
    
    private func setupSubviews(){
        likesAndCommentsView.toAutoLayout()
        likesAndCommentsView.likeButton.addTarget(self, action: #selector(manageLikes), for: .touchUpInside)
        likesAndCommentsView.addCommentButton.addTarget(self, action: #selector(pushCommentsVC), for: .touchUpInside)
        contentView.backgroundColor = .customDarkGray
        contentView.addSubviews(containerView, likesAndCommentsView)
        containerView.addSubviews(postDateLabel, postDescriptionTextView)
        
        let minHeight: CGFloat = postDescriptionTextView.font?.lineHeight ?? 50
        
        let constraints = [
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: baseInset),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: baseInset),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -baseInset),
            containerView.bottomAnchor.constraint(equalTo: likesAndCommentsView.topAnchor, constant: -baseInset),
            
            postDateLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: baseInset),
            postDateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: baseInset),
            postDateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -baseInset),
            
            postDescriptionTextView.topAnchor.constraint(equalTo: postDateLabel.bottomAnchor, constant: baseInset),
            postDescriptionTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: baseInset),
            postDescriptionTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -baseInset),
            postDescriptionTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: minHeight),
            postDescriptionTextView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -baseInset),
            
            likesAndCommentsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: baseInset),
            likesAndCommentsView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -baseInset*2),
            likesAndCommentsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -baseInset)

        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc private func pushCommentsVC() {
        onCommentsPush?()
    }
    
    @objc private func manageLikes() {
        onLikeButtonPush?()
    }
}
