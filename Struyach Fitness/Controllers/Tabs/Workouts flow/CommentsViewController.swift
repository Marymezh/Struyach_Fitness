//
//  CommentsViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 13/3/23.
//

import UIKit
import FirebaseFirestore
import MessageKit
import InputBarAccessoryView
import SDWebImage
import AVFoundation
import AVKit


class CommentsViewController: MessagesViewController, UITextViewDelegate {
    
    private let workout: Workout?
    private let blogPost: Post?
    var commentsArray: [Comment] = []
    
    private var progress = ProgressView()
    private var indicator = ActivityView()
    
    var onImagePick:(([UIImagePickerController.InfoKey : Any])-> Void)?
    var onCommentsClose: (() -> ())?
    
    private let userName = UserDefaults.standard.string(forKey: "userName")
    private let userEmail = UserDefaults.standard.string(forKey: "email")
    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    let detailsView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .systemGray6
        textView.isScrollEnabled = true
        textView.isUserInteractionEnabled = true
        textView.isEditable = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.cornerRadius = 10
        textView.toAutoLayout()
        return textView
    }()
    
    let containerView: UIView = {
        let view = UIView()
        view.toAutoLayout()
        view.backgroundColor = .customDarkComments
        return view
    }()
    
    let secondContainerView: UIView = {
        let view = UIView()
        view.toAutoLayout()
        view.backgroundColor = .systemGray6
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 10
        view.layer.shadowOffset = CGSize(width: 5, height: 5)
        view.layer.shadowOpacity = 0.7
        view.alpha = 0.8
        return view
    }()
    
    private lazy var sender = Sender(senderId: userEmail ?? "unknown email", displayName: userName ?? "unknown user")
    
    init(workout: Workout) {
        self.workout = workout
        self.blogPost = nil
        super.init(nibName: nil, bundle: nil)
    }
    
    init(blogPost: Post) {
        self.workout = nil
        self.blogPost = blogPost
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMessageCollectionView()
        setupInputBar()
        setupNavbarAndView()
        setupIndicator()
        setupProgress()
        if let workout = self.workout {
            loadComments(workout: workout)
        } else if let post = self.blogPost {
            loadComments(blogPost: post)
        }
        setupGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.onCommentsClose?()
    }
    
    private func setupMessageCollectionView() {
        messagesCollectionView.toAutoLayout()
        messagesCollectionView.backgroundColor = .customDarkComments
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.setMessageOutgoingAvatarSize(CGSize(width: 40, height: 40))
        layout?.setMessageIncomingAvatarSize(CGSize(width: 40, height: 40))
        layout?.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 50)))
        layout?.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 50)))
        
        layout?.setMessageIncomingMessageTopLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 5, left: 50, bottom: 5, right: 0)))
        layout?.setMessageIncomingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 5, left: 50, bottom: 5, right: 0)))
        
        layout?.setMessageOutgoingAvatarPosition(AvatarPosition(vertical: .messageBottom))
        layout?.setMessageIncomingAvatarPosition(AvatarPosition(vertical: .messageBottom))
        
    }
    
    private func setupInputBar() {
        // Set up inputBar
        messageInputBar.delegate = self
        messageInputBar.backgroundView.backgroundColor = .customKeyboard
        messageInputBar.inputTextView.delegate = self
        messageInputBar.inputTextView.placeholder = " Write a comment..."
        messageInputBar.inputTextView.placeholderTextColor = .gray
        messageInputBar.inputTextView.backgroundColor = .systemGray6
        messageInputBar.inputTextView.layer.cornerRadius = 15
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 10, left: 5, bottom: 5, right: 0)
        messageInputBar.tintColor = .systemGray
        let attachButton = InputBarButtonItem()
        attachButton.setSize(CGSize(width: 35, height: 35), animated: false)
        attachButton.setImage(UIImage(systemName: "paperclip", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
        attachButton.onTouchUpInside { [weak self]_ in
            self?.presentInputOptions()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 35, animated: false)
        messageInputBar.setRightStackViewWidthConstant(to: 35, animated: false)
        messageInputBar.leftStackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        messageInputBar.leftStackView.isLayoutMarginsRelativeArrangement = true
        messageInputBar.rightStackView.isLayoutMarginsRelativeArrangement = true
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        messageInputBar.sendButton.setTitle(nil, for: .normal)
        messageInputBar.sendButton.setSize(CGSize(width: 35, height: 35), animated: false)
        messageInputBar.sendButton.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
    }
    
    private func setupNavbarAndView() {
        self.view.backgroundColor = .customDarkComments
        if let workout = workout {
            detailsView.text = workout.description
        } else if let post = blogPost {
            detailsView.text = post.description
        }

        view.addSubview(containerView)
        containerView.addSubview(secondContainerView)
        secondContainerView.addSubview(detailsView)
   
    
        messagesCollectionView.contentInset.top = 180
        messagesCollectionView.verticalScrollIndicatorInsets = UIEdgeInsets(top: 180, left: 0, bottom: 0, right: 0)
        
        let constraints = [
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            secondContainerView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            secondContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            secondContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            secondContainerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            
            detailsView.topAnchor.constraint(equalTo: secondContainerView.topAnchor, constant: 10),
            detailsView.leadingAnchor.constraint(equalTo: secondContainerView.leadingAnchor, constant: 10),
            detailsView.trailingAnchor.constraint(equalTo: secondContainerView.trailingAnchor, constant: -10),
            detailsView.heightAnchor.constraint(equalToConstant: 130),
            detailsView.bottomAnchor.constraint(equalTo: secondContainerView.bottomAnchor, constant: -10)
          
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupProgress() {
        progress.toAutoLayout()
        progress.isHidden = true
        self.view.addSubview(progress)
        let constraints = [
            progress.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progress.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progress.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progress.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    private func setupIndicator() {
        indicator.toAutoLayout()
        progress.isHidden = true
        self.view.addSubview(indicator)
        let constraints = [
            indicator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            indicator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            indicator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            indicator.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
//    private func setupProgress() {
//        self.progressBackgroundView = UIView()
//        self.progressBackgroundView.backgroundColor = .black
//        self.progressBackgroundView.alpha = 0.7
//        self.progressBackgroundView.isHidden = true
//        self.progressBackgroundView.toAutoLayout()
//        self.view.addSubview(self.progressBackgroundView)
//
//        self.progressView = UIProgressView(progressViewStyle: .default)
//        self.progressView.progress = 0
//        self.progressView.progressTintColor = .systemGreen
//        self.progressView.trackTintColor = .white
//        self.progressView.toAutoLayout()
//        self.progressView.layer.cornerRadius = 5
//        self.progressView.layer.masksToBounds = true
//        self.progressView.isHidden = true
//        self.view.addSubview(self.progressView)
//
//        self.progressLabel = UILabel()
//        self.progressLabel.text = "Uploading video"
//        self.progressLabel.textColor = .white
//        self.progressLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
//        self.progressLabel.isHidden = true
//        self.progressLabel.toAutoLayout()
//        self.view.addSubview(self.progressLabel)
//
//        let constraints = [
//            self.progressBackgroundView.topAnchor.constraint(equalTo: self.view.topAnchor),
//            self.progressBackgroundView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
//            self.progressBackgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//            self.progressBackgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
//            self.progressView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
//            self.progressView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
//            self.progressView.widthAnchor.constraint(equalToConstant: 200),
//            self.progressView.heightAnchor.constraint(equalToConstant: 12),
//            self.progressLabel.centerXAnchor.constraint(equalTo: self.progressView.centerXAnchor),
//            self.progressLabel.bottomAnchor.constraint(equalTo: self.progressView.topAnchor, constant: -10)
//        ]
//
//        NSLayoutConstraint.activate(constraints)
//    }
    
    private func showActivityIndicator() {
        indicator.isHidden = false
        indicator.activityIndicator.startAnimating()
    }
    
    private func hideActivityIndicator() {
        indicator.isHidden = true
        indicator.activityIndicator.stopAnimating()
    }
    
    private func showProgress(progressLabelText: String, percentComplete: Float){
        progress.isHidden = false
//        progress.progressBackgroundView.isHidden = false
//        progress.progressView.isHidden = false
//        progress.progressLabel.isHidden = false
        progress.progressView.progress = percentComplete
        progress.progressLabel.text = progressLabelText
    }
//    private func showProgress(progressLabelText: String, percentComplete: Float){
//        self.progressBackgroundView.isHidden = false
//        self.progressView.isHidden = false
//        self.progressLabel.isHidden = false
//        self.progressView.progress = percentComplete
//        self.progressLabel.text = progressLabelText
//    }
    
    private func hideProgress() {
        progress.isHidden = true
//        progress.progressBackgroundView.isHidden = true
//        progress.progressView.isHidden = true
//        progress.progressLabel.isHidden = true
    }
    
//    private func hideProgress() {
//        self.progressBackgroundView.isHidden = true
//        self.progressView.isHidden = true
//        self.progressLabel.isHidden = true
//    }
    
    private func presentInputOptions() {
        let actionSheet = UIAlertController(title: "Attach media", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            guard let self = self else {return}
            self.showActivityIndicator()
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            picker.mediaTypes = ["public.image"]
            picker.toolbar.tintColor = .systemGreen
            self.present(picker, animated: true)
            self.onImagePick = {info in
                guard let image = info[.originalImage] as? UIImage,
                      let imageData = image.jpegData(compressionQuality: 0.2) else { return }
                let imageId = self.sender.displayName.replacingOccurrences(of: " ", with: "_") + UUID().uuidString
                if let workout = self.workout {
                    StorageManager.shared.uploadImageForComment(image: imageData, imageId: imageId, workout: workout, progressHandler: { [weak self] percentComplete in
                        guard let self = self else {return}
                        self.showProgress(progressLabelText:
                                            String(format: "Uploading photo (%d%%)", Int(percentComplete * 100)),
                                          percentComplete: percentComplete)
//                        self.progressBackgroundView.isHidden = false
//                        self.progressView.isHidden = false
//                        self.progressLabel.isHidden = false
//                        self.progressView.progress = percentComplete
//                        self.progressLabel.text = String(format: "Uploading photo (%d%%)", Int(percentComplete * 100))
                    }) { [weak self] ref in
                        guard let self = self else {return}
                        if let safeRef = ref {
                            StorageManager.shared.downloadUrl(path: safeRef) { url in
                                guard let safeUrl = url else {return}
                                self.postPhotoComment(photoUrl: safeUrl)
                            }
                        } else {
                            self.showAlert(title: "Warning", message: "Error uploading image to Storage")
                        }
                        self.hideProgress()
//                        self.progressBackgroundView.isHidden = true
//                        self.progressView.isHidden = true
//                        self.progressLabel.isHidden = true
                  //      self.activityIndicator.stopAnimating()
                    }
                } else if let post = self.blogPost {
                    StorageManager.shared.uploadImageForBlogComment(image: imageData, imageId: imageId, blogPost: post, progressHandler: { [weak self] percentComplete in
                        guard let self = self else {return}
                        self.showProgress(progressLabelText: String(format: "Uploading photo (%d%%)", Int(percentComplete * 100)),
                                          percentComplete: percentComplete)
//                        self.progressBackgroundView.isHidden = false
//                        self.progressView.isHidden = false
//                        self.progressLabel.isHidden = false
//                        self.progressView.progress = percentComplete
//                        self.progressLabel.text = String(format: "Uploading photo (%d%%)", Int(percentComplete * 100))
                    }) { [weak self] ref in
                        guard let self = self else {return}
                        if let safeRef = ref {
                            StorageManager.shared.downloadUrl(path: safeRef) { url in
                                guard let safeUrl = url else {return}
                                self.postPhotoComment(photoUrl: safeUrl)
                            }
                        } else {
                            self.showAlert(title: "Warning", message: "Error uploading image to Storage")
                        }
                        self.hideProgress()
//                        self.progressBackgroundView.isHidden = true
//                        self.progressView.isHidden = true
//                        self.progressLabel.isHidden = true
                    }
                }
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] _ in
            guard let self = self else {return}
            self.showActivityIndicator()
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            picker.mediaTypes = ["public.image"]
            self.present(picker, animated: true)
            self.onImagePick = {info in
                guard let image = info[.originalImage] as? UIImage,
                      let imageData = image.jpegData(compressionQuality: 0.6) else { return }
                let imageId = self.sender.displayName.replacingOccurrences(of: " ", with: "_") + UUID().uuidString
                if let workout = self.workout {
                    StorageManager.shared.uploadImageForComment(image: imageData, imageId: imageId, workout: workout, progressHandler: { [weak self] percentComplete in
                        guard let self = self else {return}
                        self.showProgress(progressLabelText: String(format: "Uploading photo (%d%%)", Int(percentComplete * 100)), percentComplete: percentComplete)
//                        self.progressBackgroundView.isHidden = false
//                        self.progressView.isHidden = false
//                        self.progressLabel.isHidden = false
//                        self.progressView.progress = percentComplete
//                        self.progressLabel.text = String(format: "Uploading photo (%d%%)", Int(percentComplete * 100))
                    }) { [weak self] ref in
                        guard let self = self else {return}
                        if let safeRef = ref {
                            StorageManager.shared.downloadUrl(path: safeRef) { url in
                                guard let safeUrl = url else {return}
                                self.postPhotoComment(photoUrl: safeUrl)
                            }
                        } else {
                            self.showAlert(title: "Warning", message: "Error uploading image to Storage")
                        }
                        self.hideProgress()
//                        self.progressBackgroundView.isHidden = true
//                        self.progressView.isHidden = true
//                        self.progressLabel.isHidden = true
                    }
                } else if let post = self.blogPost {
                    StorageManager.shared.uploadImageForBlogComment(image: imageData, imageId: imageId, blogPost: post, progressHandler: { [weak self] percentComplete in
                        guard let self = self else {return}
                        self.showProgress(progressLabelText: String(format: "Uploading photo (%d%%)", Int(percentComplete * 100)), percentComplete: percentComplete)
//                        self.progressBackgroundView.isHidden = false
//                        self.progressView.isHidden = false
//                        self.progressLabel.isHidden = false
//                        self.progressView.progress = percentComplete
//                        self.progressLabel.text = String(format: "Uploading photo (%d%%)", Int(percentComplete * 100))
                    }) { [weak self] ref in
                        guard let self = self else {return}
                        if let safeRef = ref {
                            StorageManager.shared.downloadUrl(path: safeRef) { url in
                                guard let safeUrl = url else {return}
                                self.postPhotoComment(photoUrl: safeUrl)
                            }
                        } else {
                            self.showAlert(title: "Warning", message: "Error uploading image to Storage")
                        }
                        self.hideProgress()
//                        self.progressBackgroundView.isHidden = true
//                        self.progressView.isHidden = true
//                        self.progressLabel.isHidden = true
                    }
                }
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.showActivityIndicator()
            let picker = UIImagePickerController()
            picker.allowsEditing = true
            picker.delegate = self
            picker.sourceType = .photoLibrary
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.toolbar.tintColor = .systemGreen
            self.present(picker, animated: true)
            
            self.onImagePick = { info in
                guard let videoUrl = info[.mediaURL] as? URL else {
                    self.showAlert(title: "Warning", message: "Couldn't get mediaURL from image picker")
                    return
                }
                let videoData = try! Data(contentsOf: videoUrl)
                let videoId = self.sender.displayName.replacingOccurrences(of: " ", with: "_") + (UUID().uuidString) + ".mov"
                if let workout = self.workout {
                    StorageManager.shared.uploadVideoURLForComment(videoID: videoId, videoData: videoData, workout: workout, progressHandler: { [weak self] percentComplete in
                        guard let self = self else {return}
                        self.showProgress(progressLabelText: String(format: "Uploading video (%d%%)", Int(percentComplete * 100)), percentComplete: percentComplete)
//                        self.progressBackgroundView.isHidden = false
//                        self.progressView.isHidden = false
//                        self.progressLabel.isHidden = false
//                        self.progressView.progress = percentComplete
//                        self.progressLabel.text = String(format: "Uploading video (%d%%)", Int(percentComplete * 100))
                    })  { [weak self] ref in
                        guard let self = self else { return }
                        if let safeRef = ref {
                            StorageManager.shared.downloadUrl(path: safeRef) { url in
                                guard let safeUrl = url else {return}
                                self.postVideoComment(videoUrl: safeUrl)
                            }
                        } else {
                            self.showAlert(title: "Warning", message: "Error uploading video to Storage")
                        }
                        self.hideProgress()
//                        self.progressBackgroundView.isHidden = true
//                        self.progressView.isHidden = true
//                        self.progressLabel.isHidden = true
                    }
                } else if let post = self.blogPost {
                    StorageManager.shared.uploadVideoURLForBlogComment(videoID: videoId, videoData: videoData, blogPost: post, progressHandler: { [weak self] percentComplete in
                        guard let self = self else {return}
                        self.showProgress(progressLabelText: String(format: "Uploading video (%d%%)", Int(percentComplete * 100)), percentComplete: percentComplete)
//                        self.progressBackgroundView.isHidden = false
//                        self.progressView.isHidden = false
//                        self.progressLabel.isHidden = false
//                        self.progressView.progress = percentComplete
//                        self.progressLabel.text = String(format: "Uploading video (%d%%)", Int(percentComplete * 100))
                    })  { [weak self] ref in
                        guard let self = self else { return }
                        if let safeRef = ref {
                            StorageManager.shared.downloadUrl(path: safeRef) { url in
                                guard let safeUrl = url else {return}
                                self.postVideoComment(videoUrl: safeUrl)
                            }
                        } else {
                            self.showAlert(title: "Warning", message: "Error uploading video to Storage")
                        }
                        self.hideProgress()
//                        self.progressBackgroundView.isHidden = true
//                        self.progressView.isHidden = true
//                        self.progressLabel.isHidden = true
                    }
                }
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        actionSheet.view.tintColor = .darkGray
        present(actionSheet, animated: true)
    }
    
    //MARK: - Methods for saving new comments to Firestore and loading them to the local commentsArray
    
    private func postComment(text: String) {
        let senderName = sender.displayName.replacingOccurrences(of: " ", with: "_")
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "dd MM YYYY HH:mm:ss"
        let date = formatter.string(from: Date())
        let messageId = "\(senderName)_\(date)"
        let fileURL = documentsDirectory.appendingPathComponent("userImage.jpg")
        let userImage = UIImage(contentsOfFile: fileURL.path)
        guard let imageData = userImage?.jpegData(compressionQuality: 0.5) else {return}
        
        if let workout = self.workout {
            let newComment = Comment(sender: sender, messageId: messageId, sentDate: Date(), kind: .text(text), userImage: imageData, workoutId: workout.id, programId: workout.programID)
            
            DatabaseManager.shared.postComment(comment: newComment) { [weak self] success in
                guard let self = self else {return}
                if success {
                    self.loadComments(workout: workout) { success in
                        if success {
                            DispatchQueue.main.async {
                                self.messagesCollectionView.scrollToLastItem()
                            }
                        }
                    }
                } else {
                    self.showAlert(title: "Warning", message: "Unable to post comment")
                }
            }
            messageInputBar.inputTextView.text = nil
        } else if let post = self.blogPost {
            let newComment = Comment(sender: sender, messageId: messageId, sentDate: Date(), kind: .text(text), userImage: imageData, workoutId: "", programId: "")
            
            DatabaseManager.shared.postBlogComment(comment: newComment, post: post) { [weak self] success in
                guard let self = self else {return}
                if success {
                    self.loadComments(blogPost: post){ success in
                        if success {
                            DispatchQueue.main.async {
                                self.messagesCollectionView.scrollToLastItem()
                            }
                        }
                    }
                } else {
                    self.showAlert(title: "Warning", message: "Unable to post comment")
                }
            }
            messageInputBar.inputTextView.text = nil
        }
    }
    
    private func postPhotoComment(photoUrl: URL) {
        let senderName = sender.displayName.replacingOccurrences(of: " ", with: "_")
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "dd MM YYYY HH:mm:ss"
        let date = formatter.string(from: Date())
        let messageId = "\(senderName)_\(date)"
        let fileURL = documentsDirectory.appendingPathComponent("userImage.jpg")
        let userImage = UIImage(contentsOfFile: fileURL.path)
        guard let imageData = userImage?.jpegData(compressionQuality: 1) else {return}
        
        guard let placeholder = UIImage(systemName: "photo") else {return}
        let media = Media(url: photoUrl, image: placeholder, placeholderImage: placeholder, size: .zero)
        if let workout = self.workout {
            let newComment = Comment(sender: sender, messageId: messageId, sentDate: Date(), kind: .photo(media), userImage: imageData, workoutId: workout.id, programId: workout.programID)
            print ("new comment with photo is created and sent to the Firestore")
            DatabaseManager.shared.postComment(comment: newComment) { [weak self] success in
                guard let self = self else {return}
                if success {
                    self.loadComments(workout: workout){ success in
                        if success {
                            DispatchQueue.main.async {
                                self.messagesCollectionView.scrollToLastItem()
                            }
                        }
                    }
                } else {
                    self.showAlert(title: "Warning", message: "Unable to post comment")
                }
            }
        } else if let post = self.blogPost {
            let newComment = Comment(sender: sender, messageId: messageId, sentDate: Date(), kind: .photo(media), userImage: imageData, workoutId: nil, programId: nil)
            print ("new comment with photo is created and sent to the Firestore")
            DatabaseManager.shared.postBlogComment(comment: newComment, post: post) { [weak self] success in
                guard let self = self else {return}
                if success {
                    self.loadComments(blogPost: post){ success in
                        if success {
                            DispatchQueue.main.async {
                                self.messagesCollectionView.scrollToLastItem()
                            }
                        }
                    }
                } else {
                    self.showAlert(title: "Warning", message: "Unable to post comment")
                }
            }
        }
    }
    
    private func postVideoComment(videoUrl: URL) {
        let senderName = sender.displayName.replacingOccurrences(of: " ", with: "_")
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "dd MM YYYY HH:mm:ss"
        let date = formatter.string(from: Date())
        let messageId = "\(senderName)_\(date)"
        let fileURL = documentsDirectory.appendingPathComponent("userImage.jpg")
        let userImage = UIImage(contentsOfFile: fileURL.path)
        guard let imageData = userImage?.jpegData(compressionQuality: 1) else {return}
        
        guard let placeholder = UIImage(systemName: "video.fill") else {return}
        let media = Media(url: videoUrl, image: placeholder, placeholderImage: placeholder, size: .zero)
        
        if let workout = self.workout {
            let newComment = Comment(sender: sender, messageId: messageId, sentDate: Date(), kind: .video(media), userImage: imageData, workoutId: workout.id, programId: workout.programID)
            print ("new comment with video is created and sent to the Firestore")
            DatabaseManager.shared.postComment(comment: newComment) { [weak self] success in
                guard let self = self else {return}
                if success {
                    self.loadComments(workout: workout){ success in
                        if success {
                            DispatchQueue.main.async {
                                self.messagesCollectionView.scrollToLastItem()
                            }
                        }
                    }
                } else {
                    self.showAlert(title: "Warning", message: "Unable to post comment")
                }
            }
        } else if let post = self.blogPost {
            let newComment = Comment(sender: sender, messageId: messageId, sentDate: Date(), kind: .video(media), userImage: imageData, workoutId: nil, programId: nil)
            print ("new comment with video is created and sent to the Firestore")
            DatabaseManager.shared.postBlogComment(comment: newComment, post: post) { [weak self] success in
                guard let self = self else {return}
                if success {
                    self.loadComments(blogPost: post){ success in
                        if success {
                            DispatchQueue.main.async {
                                self.messagesCollectionView.scrollToLastItem()
                            }
                        }
                    }
                } else {
                    self.showAlert(title: "Warning", message: "Unable to post comment")
                }
            }
        }
    }
    
    private func loadComments(workout: Workout, completion: ((Bool) -> Void)? = nil){
        self.showActivityIndicator()
        DatabaseManager.shared.getAllComments(workout: workout) { [weak self] comments in
            guard let self = self else {return}
            self.commentsArray = comments
            print ("loaded \(self.commentsArray.count) comments")
            DispatchQueue.main.async {
                self.messagesCollectionView.reloadData()
                self.hideActivityIndicator()
            }
            completion?(true)
        }
    }
    
    private func loadComments(blogPost: Post, completion: ((Bool) -> Void)? = nil){
        self.showActivityIndicator()
        DatabaseManager.shared.getAllBlogComments(blogPost: blogPost) { [weak self] comments in
            guard let self = self else {return}
            self.commentsArray = comments
            print ("loaded \(self.commentsArray.count) comments")
            DispatchQueue.main.async {
                self.messagesCollectionView.reloadData()
                self.hideActivityIndicator()
            }
            completion?(true)
        }
    }

    //MARK: - Methods for editing and deleting comments from local array and Firestore
    
    private func setupGestureRecognizer() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        messagesCollectionView.addGestureRecognizer(longPress)
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        print("Executing function: \(#function)")
        let location = sender.location(in: messagesCollectionView)
        if let indexPath = messagesCollectionView.indexPathForItem(at: location) {
            let selectedMessage = self.commentsArray[indexPath.section]
            if userEmail == selectedMessage.sender.senderId {
                let alertController = UIAlertController(title: "EDIT OR DELETE", message: "Please choose edit action, delete action, of cancel", preferredStyle: .actionSheet)
                
                let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] action in
                    guard let self = self else {return}
                    if let workout = self.workout {
                        DatabaseManager.shared.deleteComment(comment: selectedMessage) { success in
                            if success {
                                self.loadComments(workout: workout)
                            } else {
                                self.showAlert(title: "Warning", message: "Unable to delete comment")
                            }
                        }
                    } else if let post = self.blogPost {
                        DatabaseManager.shared.deleteBlogComment(comment: selectedMessage, blogPost: post) { success in
                            if success {
                                self.loadComments(blogPost: post)
                            } else {
                                self.showAlert(title: "Warning", message: "Unable to delete comment")
                            }
                        }
                    }
                }
                
                let editAction = UIAlertAction(title: "Edit", style: .default) { [weak self] action in
                    guard let self = self else {return}
                    
                    switch selectedMessage.kind {
                    case .text(let textToEdit):
                        let commentVC = CreateNewWorkoutViewController()
                        commentVC.title = "Edit comment"
                        commentVC.text = textToEdit
                        self.navigationController?.pushViewController(commentVC, animated: true)
                        commentVC.onWorkoutSave = { text in
                            if let workout = self.workout {
                                DatabaseManager.shared.updateComment(comment: selectedMessage, newDescription: text) { success in
                                    if success{
                                        self.loadComments(workout: workout)
                                    } else {
                                        self.showAlert(title: "Warning", message: "Unable to update selected comment")
                                    }
                                }
                            } else if let post = self.blogPost {
                                DatabaseManager.shared.updateBlogComment(comment: selectedMessage, blogPost: post, newDescription: text) { success in
                                    if success{
                                        self.loadComments(blogPost: post)
                                    } else {
                                        self.showAlert(title: "Warning", message: "Unable to update selected comment")
                                    }
                                }
                            }
                        }
                        
                    case .photo(_):
                        let picker = UIImagePickerController()
                        picker.delegate = self
                        picker.sourceType = .photoLibrary
                        picker.mediaTypes = ["public.image"]
                        picker.toolbar.tintColor = .systemGreen
                        self.present(picker, animated: true)
                        
                        self.onImagePick = { [weak self] info in
                            guard let self = self, let image = info[.originalImage] as? UIImage else { return }
                            guard let imageData = image.jpegData(compressionQuality: 0.6) else { return }
                            let imageId = self.sender.displayName.replacingOccurrences(of: " ", with: "_") + UUID().uuidString
                            if let workout = self.workout {
                                StorageManager.shared.uploadImageForComment(image: imageData, imageId: imageId, workout: workout, progressHandler: { [weak self] percentComplete in
                                    guard let self = self else {return}
                                    self.showProgress(progressLabelText: String(format: "Updating photo (%d%%)", Int(percentComplete * 100)), percentComplete: percentComplete)
//                                    self?.progressBackgroundView.isHidden = false
//                                    self?.progressView.isHidden = false
//                                    self?.progressLabel.isHidden = false
//                                    self?.progressView.progress = percentComplete
//                                    self?.progressLabel.text = String(format: "Updating photo (%d%%)", Int(percentComplete * 100))
                                }) { [weak self] ref in
                                    guard let self = self, let safeRef = ref else { return }
                                    StorageManager.shared.downloadUrl(path: safeRef) { url in
                                        guard let safeUrl = url else {return}
                                        let mediaUrl = safeUrl.absoluteString
                                        DatabaseManager.shared.updateComment(comment: selectedMessage, newDescription: mediaUrl) { success in
                                            if success {
                                                self.loadComments(workout: workout)
                                            } else {
                                                self.showAlert(title: "Warning", message: "Unable to update selected photo comment")
                                            }
                                            self.hideProgress()
//                                            self.progressBackgroundView.isHidden = true
//                                            self.progressView.isHidden = true
//                                            self.progressLabel.isHidden = true
                                        }
                                    }
                                }
                            } else if let post = self.blogPost {
                                StorageManager.shared.uploadImageForBlogComment(image: imageData, imageId: imageId, blogPost: post, progressHandler: { [weak self] percentComplete in
                                    guard let self = self else {return}
                                    self.showProgress(progressLabelText: String(format: "Updating photo (%d%%)", Int(percentComplete * 100)), percentComplete: percentComplete)
//                                    self?.progressBackgroundView.isHidden = false
//                                    self?.progressView.isHidden = false
//                                    self?.progressLabel.isHidden = false
//                                    self?.progressView.progress = percentComplete
//                                    self?.progressLabel.text = String(format: "Updating photo (%d%%)", Int(percentComplete * 100))
                                }) { [weak self] ref in
                                    guard let self = self, let safeRef = ref else { return }
                                    StorageManager.shared.downloadUrl(path: safeRef) { url in
                                        guard let safeUrl = url else {return}
                                        let mediaUrl = safeUrl.absoluteString
                                        DatabaseManager.shared.updateComment(comment: selectedMessage, newDescription: mediaUrl) { success in
                                            if success {
                                                self.loadComments(blogPost: post)
                                            } else {
                                                self.showAlert(title: "Warning", message: "Unable to update selected photo comment")
                                            }
                                            self.hideProgress()
//                                            self.progressBackgroundView.isHidden = true
//                                            self.progressView.isHidden = true
//                                            self.progressLabel.isHidden = true
                                        }
                                    }
                                }
                            }
                        }
                        
                    case .video(_):
                        let picker = UIImagePickerController()
                        picker.allowsEditing = true
                        picker.delegate = self
                        picker.sourceType = .photoLibrary
                        picker.mediaTypes = ["public.movie"]
                        picker.videoQuality = .typeMedium
                        picker.toolbar.tintColor = .systemGreen
                        self.present(picker, animated: true)
                        
                        self.onImagePick = { [weak self] info in
                            guard let self = self, let videoUrl = info[.mediaURL] as? URL else {return}
                            let videoId = self.sender.displayName.replacingOccurrences(of: " ", with: "_") + (UUID().uuidString) + ".mov"
                            let videoData = try! Data(contentsOf: videoUrl)
                            if let workout = self.workout {
                                StorageManager.shared.uploadVideoURLForComment(videoID: videoId, videoData: videoData, workout: workout, progressHandler: { [weak self] percentComplete in
                                    guard let self = self else {return}
                                    self.showProgress(progressLabelText: String(format: "Updating video (%d%%)", Int(percentComplete * 100)), percentComplete: percentComplete)
//                                    self?.progressBackgroundView.isHidden = false
//                                    self?.progressView.isHidden = false
//                                    self?.progressLabel.isHidden = false
//                                    self?.progressView.progress = percentComplete
//                                    self?.progressLabel.text = String(format: "Updating video (%d%%)", Int(percentComplete * 100))
                                })  { [weak self] ref in
                                    guard let self = self, let safeRef = ref else {return}
                                    StorageManager.shared.downloadUrl(path: safeRef) { url in
                                        guard let safeUrl = url else { print("unable to get safeURL")
                                            return}
                                        let mediaUrl = safeUrl.absoluteString
                                        DatabaseManager.shared.updateComment(comment: selectedMessage, newDescription: mediaUrl) { success in
                                            if success {
                                                self.loadComments(workout: workout)
                                            } else {
                                                self.showAlert(title: "Warning", message: "Unable to update selected video comment")
                                            }
                                            self.hideProgress()
//                                            self.progressBackgroundView.isHidden = true
//                                            self.progressView.isHidden = true
//                                            self.progressLabel.isHidden = true
                                        }
                                    }
                                }
                            } else if let post = self.blogPost {
                                StorageManager.shared.uploadVideoURLForBlogComment(videoID: videoId, videoData: videoData, blogPost: post, progressHandler: { [weak self] percentComplete in
                                    guard let self = self else {return}
                                    self.showProgress(progressLabelText: String(format: "Updating video (%d%%)", Int(percentComplete * 100)), percentComplete: percentComplete)
//                                    self?.progressBackgroundView.isHidden = false
//                                    self?.progressView.isHidden = false
//                                    self?.progressLabel.isHidden = false
//                                    self?.progressView.progress = percentComplete
//                                    self?.progressLabel.text = String(format: "Updating video (%d%%)", Int(percentComplete * 100))
                                })  { [weak self] ref in
                                    guard let self = self, let safeRef = ref else {return}
                                    StorageManager.shared.downloadUrl(path: safeRef) { url in
                                        guard let safeUrl = url else { print("unable to get safeURL")
                                            return}
                                        let mediaUrl = safeUrl.absoluteString
                                        DatabaseManager.shared.updateComment(comment: selectedMessage, newDescription: mediaUrl) { success in
                                            if success {
                                                self.loadComments(blogPost: post)
                                            } else {
                                                self.showAlert(title: "Warning", message: "Unable to update selected video comment")
                                            }
                                            self.hideProgress()
//                                            self.progressBackgroundView.isHidden = true
//                                            self.progressView.isHidden = true
//                                            self.progressLabel.isHidden = true
                                        }
                                    }
                                }
                            }
                        }
                    default: break
                    }
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                alertController.addAction(editAction)
                alertController.addAction(deleteAction)
                alertController.addAction(cancelAction)
                alertController.view.tintColor = .darkGray
                present(alertController, animated: true)
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        alert.view.tintColor = .systemGreen
        self.present(alert, animated: true, completion: nil)
    }
}
//MARK: MessagesDataSource, MessagesDisplayDelegate, MessagesLayoutDelegate
extension CommentsViewController: MessagesDataSource, MessagesDisplayDelegate, MessagesLayoutDelegate {
    
    var currentSender: SenderType {
        return sender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return commentsArray[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return commentsArray.count
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let comment = commentsArray[indexPath.section]
        
        let imageData = comment.userImage
        let image = UIImage(data: imageData)
        let avatar = Avatar(image: image, initials: "")
        avatarView.set(avatar: avatar)
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let sender = message.sender
        return NSAttributedString(
            string: sender.displayName,
            attributes: [.font: UIFont.preferredFont(forTextStyle: .caption1),.foregroundColor: UIColor.white]
        )
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 30
    }

    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let sentDate = message.sentDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM YYYY HH:mm"
        dateFormatter.locale = .current
        let dateString = dateFormatter.string(from: sentDate)
        return NSAttributedString(
            string: dateString,
            attributes: [.font: UIFont.preferredFont(forTextStyle: .caption2),.foregroundColor: UIColor.white]
        )
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 30
    }
          
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        switch message.kind {
            
        case .photo(let media):
            guard let imageUrl = media.url else {return}
            imageView.sd_setImage(with: imageUrl)
            
        case .video(let media):
                guard let videoUrl = media.url else { return }
                let thumbnailCacheKey = "\(videoUrl.absoluteString)_thumbnail"
                if let cachedThumbnailImage = SDImageCache.shared.imageFromCache(forKey: thumbnailCacheKey) {
                    imageView.image = cachedThumbnailImage
                    return
                }
                let asset = AVAsset(url: videoUrl)
                let imageGenerator = AVAssetImageGenerator(asset: asset)
                imageGenerator.appliesPreferredTrackTransform = true
                let time = CMTime(seconds: 0.0, preferredTimescale: 1)
                guard let cgImage = try? imageGenerator.copyCGImage(at: time, actualTime: nil) else { return }
                let thumbnailSize = CGSize(width: 80, height: 80)
                let thumbnailImage = UIImage(cgImage: cgImage).sd_resizedImage(with: thumbnailSize, scaleMode: .aspectFill)

                SDImageCache.shared.store(thumbnailImage, forKey: thumbnailCacheKey, completion: nil)

                imageView.image = thumbnailImage
            
        default: break
        }
    }
}

extension CommentsViewController: MessageCellDelegate {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {return}
        let comment = commentsArray[indexPath.section]
        guard comment.sender.senderId != userEmail else {return}
        self.showActivityIndicator()
        let profileVC = ProfileTableViewController(email: comment.sender.senderId)
        profileVC.fetchUserRecords()
        profileVC.fetchOtherUserData { [weak self] success in
            guard let self = self else {return}
            if success {
                self.hideActivityIndicator()
                self.navigationController?.present(profileVC, animated: true)
            }
        }
    }
    
    func didTapPlayButton(in cell: AudioMessageCell) {
        let player = AVPlayer()
        player.play()
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {return}
        
        let comment = commentsArray[indexPath.section]
        
        switch comment.kind {
            
        case .photo(let media): guard let imageUrl = media.url else {return}
            let vc = PhotoPresenterViewController(url: imageUrl)
            self.navigationController?.present(vc, animated: true)
            
        case .video(let media): guard let videoUrl = media.url else {return}
            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: videoUrl)
            vc.player?.play()
            self.present(vc, animated: true)
            
        default:break
            
        }
    }
}

extension CommentsViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        print("executing \(#function)")
        inputBar.inputTextView.resignFirstResponder()
        postComment(text: text)
    }
}

//MARK: - UIImagePickerControllerDelegate methods
extension CommentsViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        self.hideActivityIndicator()
//        self.progressBackgroundView.isHidden = true
//        self.activityIndicator.isHidden = true
//        self.activityIndicator.stopAnimating()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.onImagePick?(info)
        picker.dismiss(animated: true)
        self.hideActivityIndicator()
//        self.progressBackgroundView.isHidden = true
//        self.activityIndicator.isHidden = true
//        self.activityIndicator.stopAnimating()
    }
}



