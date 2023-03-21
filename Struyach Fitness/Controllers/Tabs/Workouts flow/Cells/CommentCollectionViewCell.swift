//
//  CommentTableViewCell.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit
import MessageKit
import AVFoundation

class CommentCollectionViewCell: MessageContentCell {
    
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
    
    let commentVideoPlayerView: UIView = {
        let imageView = UIView()
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
            
            commentVideoPlayerView.topAnchor.constraint(equalTo: commentImageView.bottomAnchor, constant: baseInset),
            commentVideoPlayerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: baseInset),
            commentVideoPlayerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -baseInset),
            commentVideoPlayerView.heightAnchor.constraint(lessThanOrEqualToConstant: 200),
            commentVideoPlayerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -baseInset),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.userImage.image = nil
        self.userNameLabel.text = nil
        self.dateLabel.text = nil
        self.commentTextLabel.text = nil
        self.commentImageView.image = nil
        self.commentImageView.isHidden = true
        self.commentVideoPlayerView.subviews.forEach { $0.removeFromSuperview()}
    }
}

extension CommentCollectionViewCell: MessageCellDelegate {
    
    func configure(with comment: Comment, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
//        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
//            fatalError("MessagesDisplayDelegate has not been set.")
//        }
//        
//        guard let layoutDelegate = messagesCollectionView.messagesLayoutDelegate else {
//            fatalError("MessagesLayoutDelegate has not been set.")
//        }
//        
//        let textColor = displayDelegate.textColor(for: comment, at: indexPath, in: messagesCollectionView)
//        let backgroundColor = displayDelegate.backgroundColor(for: comment, at: indexPath, in: messagesCollectionView)
        self .backgroundColor = backgroundColor
        
        let data = comment.userImage
        let decoded = try! PropertyListDecoder().decode(Data.self, from: data)
        let image = UIImage(data: decoded)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy  HH:mm"
        let sentDate = formatter.string(from: comment.sentDate)
        
        
        userImage.image = image
        userNameLabel.text = comment.sender.displayName
        dateLabel.text = sentDate
        
        switch comment.kind {
        case .text(let text):
            commentTextLabel.text = text
            commentTextLabel.isHidden = false
            commentImageView.isHidden = true
            commentVideoPlayerView.isHidden = true
        case .photo(let mediaItem):
            let image = mediaItem.image
            commentImageView.image = image
            commentImageView.isHidden = false
            commentTextLabel.isHidden = true
            commentVideoPlayerView.isHidden = true
        case .video(let mediaItem):
            commentImageView.isHidden = true
            commentTextLabel.isHidden = true
            commentVideoPlayerView.isHidden = false
            
            guard let safeUrl = mediaItem.url else {print ("url for video is invalid or does not exist")
                return
            }
            let player = AVPlayer(url: safeUrl)
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = commentVideoPlayerView.bounds
            commentVideoPlayerView.layer.addSublayer(playerLayer)
            player.play()
            
            let playButton = UIButton(type: .custom)
            playButton.frame = commentVideoPlayerView.bounds
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
            commentVideoPlayerView.addSubview(playButton)
            
        default:
            commentTextLabel.isHidden = true
            commentImageView.isHidden = true
            commentVideoPlayerView.isHidden = true
        }
    }
    
    @objc private func playButtonTapped() {
        
    }
}
