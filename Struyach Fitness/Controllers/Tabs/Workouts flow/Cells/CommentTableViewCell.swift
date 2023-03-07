//
//  CommentTableViewCell.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    
    var comment:Comment? {
        didSet
        {
            guard let data = comment?.userImage else {return}
            let decoded = try! PropertyListDecoder().decode(Data.self, from: data)
            let image = UIImage(data: decoded)
            self.userImage.image = image
            self.commentTextLabel.text = comment?.text
            self.dateLabel.text = comment?.date
            self.userNameLabel.text = comment?.userName 
            
        }
    }
    
    private let containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .customMediumGray
        containerView.layer.cornerRadius = 15
        containerView.layer.masksToBounds = true
        containerView.toAutoLayout()
        return containerView
    }()
    
    private let userImage: UIImageView = {
        let image = UIImageView()
        image.clipsToBounds = true
        image.layer.cornerRadius = 30
        image.contentMode = .scaleAspectFill
        image.layer.borderColor = UIColor.darkGray.cgColor
        image.layer.borderWidth = 1
        image.toAutoLayout()
        return image
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 1
        label.toAutoLayout()
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy  HH:mm"
        label.text = formatter.string(from: Date())
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .white
        label.toAutoLayout()
        return label
    }()
    
    private let commentTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .white
        label.numberOfLines = 0
        label.toAutoLayout()
        return label
    }()
    
    private var baseInset: CGFloat { return 15 }
    
    //TODO: - Add functionality to load short videos into comment and "likes" button and counter
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    private func setupUI() {

        contentView.backgroundColor = .customDarkGray
        contentView.addSubviews(containerView, userImage)
        containerView.addSubviews(userNameLabel, dateLabel, commentTextLabel)
        
        let constraints = [
            
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: baseInset),
            containerView.leadingAnchor.constraint(equalTo: userImage.trailingAnchor, constant: baseInset),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -baseInset),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            userImage.topAnchor.constraint(equalTo: containerView.topAnchor),
            userImage.heightAnchor.constraint(equalToConstant: 60),
            userImage.widthAnchor.constraint(equalTo: userImage.heightAnchor),
            userImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: baseInset),
            
            userNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: baseInset),
            userNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: baseInset),
            userNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -baseInset),
            
            dateLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 5),
            dateLabel.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: userNameLabel.trailingAnchor),
            
            commentTextLabel.topAnchor.constraint(equalTo: userImage.bottomAnchor, constant: baseInset),
            commentTextLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: baseInset),
            commentTextLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -baseInset),
            commentTextLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -baseInset)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
