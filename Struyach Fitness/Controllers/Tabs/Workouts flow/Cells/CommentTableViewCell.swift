//
//  CommentTableViewCell.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    
//    var comment:Comment? {
//        didSet
//        {
//            guard let data = comment?.userImage else {return}
//            let decoded = try! PropertyListDecoder().decode(Data.self, from: data)
//            let image = UIImage(data: decoded)
//            self.userImage.image = image
//            self.commentTextLabel.text = comment?.text
//            self.dateLabel.text = comment?.date
//            self.userNameLabel.text = comment?.userName
//            
//            if let ref = comment?.imageRef, ref != ""  {
//                StorageManager.shared.downloadUrlForProfilePicture(path: ref) { url in
//                    guard let url = url else {return}
//                    print ("\(url)")
//                    let task = URLSession.shared.dataTask(with: url) { data, _, _ in
//                        if let data = data {
//                            DispatchQueue.main.async {
//                                self.commentImageView.isHidden = false
//                                self.commentImageView.image = UIImage(data: data)
//                            }
//                        }
//                    }
//                    task.resume()
//                }
//            } else {
//                self.commentImageView.image = nil
//                self.commentImageView.isHidden = true 
//            }
//        }
//    }
    
    private let userImage: UIImageView = {
        let image = UIImageView()
        image.clipsToBounds = true
        image.layer.cornerRadius = 30
        image.contentMode = .scaleAspectFill
        image.layer.borderColor = UIColor.customLightGray?.cgColor 
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
    
    let commentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
//        imageView.sizeToFit()
        imageView.isHidden = true
        imageView.toAutoLayout()
        return imageView
    }()
    
    private var baseInset: CGFloat { return 15 }
    
    //TODO: - Add functionality to load short videos into comment and "likes" button and counter
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
  //      prepareForReuse()
    }
    
    private func setupUI() {

        contentView.backgroundColor = .customDarkGray
        contentView.addSubviews(userImage, userNameLabel, dateLabel, commentTextLabel, commentImageView)
        
        let constraints = [
            
            userImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: baseInset),
            userImage.heightAnchor.constraint(equalToConstant: 60),
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
//            commentTextLabel.heightAnchor.constraint(equalToConstant: 200),
    //        commentTextLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -baseInset)
            
            commentImageView.topAnchor.constraint(equalTo: commentTextLabel.bottomAnchor, constant: baseInset),
            commentImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: baseInset),
            commentImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -baseInset),
            commentImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 200),
            commentImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -baseInset)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.commentImageView.image = nil
        self.commentImageView.isHidden = true
    }
}
