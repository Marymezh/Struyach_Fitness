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
            guard let data = comment?.userImage else {print("unable to get image data")
                return}
            let decoded = try! PropertyListDecoder().decode(Data.self, from: data)
            let image = UIImage(data: decoded)
            self.userImage.image = image
            self.commentTextLabel.text = comment?.text
            self.dateLabel.text = comment?.date
            self.userNameLabel.text = comment?.userName
            
        }
    }
    
    private let userImage: UIImageView = {
        let image = UIImageView(image: UIImage(named: "general"))
        image.clipsToBounds = true
        image.layer.cornerRadius = 20
        image.contentMode = .scaleAspectFill
        image.layer.borderColor = UIColor.black.cgColor
        image.layer.borderWidth = 0.5
        image.toAutoLayout()
        return image
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .black
        label.text = "Current User"
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
        label.toAutoLayout()
        label.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        return label
    }()
    
    private let commentTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .black
        label.numberOfLines = 0
        label.toAutoLayout()
        return label
    }()
    
    private var baseInset: CGFloat { return 16 }
    
    //TODO: - Add functionality to load short videos into comment and "likes" button and counter
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    private func setupUI() {
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.black.cgColor
        contentView.backgroundColor = UIColor(named: "lightGreen")
        contentView.addSubviews(userImage, userNameLabel, dateLabel, commentTextLabel)
        
        let constraints = [
            
            userImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: baseInset),
            userImage.heightAnchor.constraint(equalToConstant: 40),
            userImage.widthAnchor.constraint(equalTo: userImage.heightAnchor),
            userImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: baseInset),
            
            userNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: baseInset),
            userNameLabel.leadingAnchor.constraint(equalTo: userImage.trailingAnchor, constant: baseInset),
            userNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -baseInset),
            
            dateLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 5),
            dateLabel.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: userNameLabel.trailingAnchor),
            
            commentTextLabel.topAnchor.constraint(equalTo: userImage.bottomAnchor, constant: baseInset),
            commentTextLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: baseInset),
            commentTextLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -baseInset),
            commentTextLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -baseInset)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
