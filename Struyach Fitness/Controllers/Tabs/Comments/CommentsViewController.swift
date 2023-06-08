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


final class CommentsViewController: CommentsMessagesViewController, UITextViewDelegate {
    
    //    MARK: - Properties
    
    private let workout: Workout?
    private let blogPost: Post?
    var commentsArray: [Comment] = []
    
    private var detailsView = DetailsView()
    private var progressView = ProgressView()
    private var activityView = ActivityView()

    var onFinishPicking:(([UIImagePickerController.InfoKey : Any])-> Void)?
    var onCommentPosted: (() -> ())?
    
    private let userName = UserDefaults.standard.string(forKey: "userName")
    private let userEmail = UserDefaults.standard.string(forKey: "email")
    private lazy var sender = Sender(senderId: userEmail ?? "unknown email", displayName: userName ?? "unknown user")
    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    //MARK: - Lifecycle
    
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
        self.view.backgroundColor = .customDarkComments
        setupMessageCollectionView()
        setupInputBar()
        setupSubviews()
        if let workout = self.workout {
            loadComments(for: workout, loadCommentsClosure: DatabaseManager.shared.getAllComments)
        } else if let post = self.blogPost {
            loadComments(for: post, loadCommentsClosure: DatabaseManager.shared.getAllBlogComments)
        }
        setupGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    deinit {
           print ("comments vc is deallocated")
       }
    
    
    //MARK: - Message Collection View and InputBarView setup
    
    private func setupMessageCollectionView() {
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
    private func setupInputBar() {
        messageInputBar.delegate = self
        messageInputBar.inputTextView.delegate = self
        let attachButton = InputBarButtonItem()
        attachButton.setSize(CGSize(width: 35, height: 35), animated: false)
        attachButton.setImage(UIImage(systemName: "paperclip", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
        attachButton.onTouchUpInside { [weak self]_ in
            self?.presentInputOptions()
        }
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
    }
    
    //    MARK: - Setup subviews
    
    private func setupSubviews() {
        
        if let workout = workout {
            detailsView.textView.text = workout.description
        } else if let post = blogPost {
            detailsView.textView.text = post.description
        }
        detailsView.toAutoLayout()
        progressView.toAutoLayout()
        activityView.toAutoLayout()
        progressView.isHidden = true
        activityView.isHidden = true
        view.addSubviews(detailsView, progressView, activityView)
        
        let constraints = [
            detailsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            detailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            detailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            detailsView.heightAnchor.constraint(equalToConstant: 170),
            
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            activityView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            activityView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            activityView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    //MARK: - Input options for InputBarAttachButton
    
    private func presentInputOptions() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.view.tintColor = .darkGray
        let cameraAction = UIAlertAction(title: "Camera".localized(), style: .default) { [weak self] _ in
            guard let self = self else {return}
            self.activityView.showActivityIndicator()
            self.showImagePickerController(type: .camera)
            self.onFinishPicking = {info in
                guard let image = info[.originalImage] as? UIImage,
                      let imageData = image.jpegData(compressionQuality: 0.2) else { return }
                let imageId = self.sender.displayName.replacingOccurrences(of: " ", with: "_") + UUID().uuidString
                if let workout = self.workout {
                    StorageManager.shared.uploadImageForComment(image: imageData, imageId: imageId, workout: workout, progressHandler: { [weak self] percentComplete in
                        guard let self = self else {return}
                        self.progressView.showProgress(progressLabelText:
                                                        String(format: "Uploading photo (%d%%)".localized(), Int(percentComplete * 100)),
                                          percentComplete: percentComplete)
                    }) { [weak self] ref in
                        guard let self = self else {return}
                        if let safeRef = ref {
                            StorageManager.shared.downloadUrl(path: safeRef) { url in
                                guard let safeUrl = url else {return}
                                self.postPhotoComment(photoUrl: safeUrl, photoRef: safeRef)
                            }
                        } else {
                            AlertManager.shared.showAlert(title: "Warning".localized(), message: "Error uploading image".localized(), cancelAction: "Cancel".localized(), style: .cancel)
                        }
                        self.progressView.hide()
                    }
                } else if let post = self.blogPost {
                    StorageManager.shared.uploadImageForBlogComment(image: imageData, imageId: imageId, blogPost: post, progressHandler: { [weak self] percentComplete in
                        guard let self = self else {return}
                        self.progressView.showProgress(progressLabelText: String(format: "Uploading photo (%d%%)".localized(), Int(percentComplete * 100)),
                                          percentComplete: percentComplete)
                    }) { [weak self] ref in
                        guard let self = self else {return}
                        if let safeRef = ref {
                            StorageManager.shared.downloadUrl(path: safeRef) { url in
                                guard let safeUrl = url else {return}
                                self.postPhotoComment(photoUrl: safeUrl, photoRef: safeRef)
                            }
                        } else {
                            AlertManager.shared.showAlert(title: "Warning".localized(), message: "Error uploading image".localized(), cancelAction: "Cancel".localized(), style: .cancel)
                        }
                        self.progressView.hide()
                    }
                }
            }
        }
        let cameraImage = UIImage(systemName: "camera")?.withRenderingMode(.alwaysOriginal)
        cameraAction.setValue(cameraImage, forKey: "image")
        
        let photoAction = UIAlertAction(title: "Photo".localized(), style: .default) { [weak self] _ in
            guard let self = self else {return}
            self.activityView.showActivityIndicator()
            self.showImagePickerController(type: .photo)
            self.onFinishPicking = {info in
                guard let image = info[.originalImage] as? UIImage,
                      let imageData = image.jpegData(compressionQuality: 0.6) else { return }
                let imageId = self.sender.displayName.replacingOccurrences(of: " ", with: "_") + UUID().uuidString
                if let workout = self.workout {
                    StorageManager.shared.uploadImageForComment(image: imageData, imageId: imageId, workout: workout, progressHandler: { [weak self] percentComplete in
                        guard let self = self else {return}
                        self.progressView.showProgress(progressLabelText: String(format: "Uploading photo (%d%%)".localized(), Int(percentComplete * 100)), percentComplete: percentComplete)
                    }) { [weak self] ref in
                        guard let self = self else {return}
                        if let safeRef = ref {
                            StorageManager.shared.downloadUrl(path: safeRef) { url in
                                guard let safeUrl = url else {return}
                                self.postPhotoComment(photoUrl: safeUrl, photoRef: safeRef)
                            }
                        } else {
                            AlertManager.shared.showAlert(title: "Warning".localized(), message: "Error uploading image".localized(), cancelAction: "Cancel".localized(), style: .cancel)
                        }
                        self.progressView.hide()
                        self.activityView.showActivityIndicator()
                        
                    }
                } else if let post = self.blogPost {
                    StorageManager.shared.uploadImageForBlogComment(image: imageData, imageId: imageId, blogPost: post, progressHandler: { [weak self] percentComplete in
                        guard let self = self else {return}
                        self.progressView.showProgress(progressLabelText: String(format: "Uploading photo (%d%%)".localized(), Int(percentComplete * 100)), percentComplete: percentComplete)
                    }) { [weak self] ref in
                        guard let self = self else {return}
                        if let safeRef = ref {
                            StorageManager.shared.downloadUrl(path: safeRef) { url in
                                guard let safeUrl = url else {return}
                                self.postPhotoComment(photoUrl: safeUrl, photoRef: safeRef)
                            }
                        } else {
                            AlertManager.shared.showAlert(title: "Warning".localized(), message: "Error uploading image".localized(), cancelAction: "Cancel".localized(), style: .cancel)
                        }
                        self.progressView.hide()
                        self.activityView.showActivityIndicator()
                    }
                }
            }
        }
        
        let photoImage = UIImage(systemName: "photo")?.withRenderingMode(.alwaysOriginal)
        photoAction.setValue(photoImage, forKey: "image")
        
        let videoAction = UIAlertAction(title: "Video".localized(), style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.activityView.showActivityIndicator()
            self.showImagePickerController(type: .video)
            self.onFinishPicking = { info in
                guard let videoUrl = info[.mediaURL] as? URL else {
                    AlertManager.shared.showAlert(title: "Warning".localized(), message: "Couldn't get media URL from image picker".localized(), cancelAction: "Cancel".localized(), style: .cancel)
                    return
                }
                let videoData = try! Data(contentsOf: videoUrl)
                let videoId = self.sender.displayName.replacingOccurrences(of: " ", with: "_") + (UUID().uuidString) + ".mov"
                if let workout = self.workout {
                    StorageManager.shared.uploadVideoURLForComment(videoID: videoId, videoData: videoData, workout: workout, progressHandler: { [weak self] percentComplete in
                        guard let self = self else {return}
                        self.progressView.showProgress(progressLabelText: String(format: "Uploading video (%d%%)".localized(), Int(percentComplete * 100)), percentComplete: percentComplete)
                    })  { [weak self] ref in
                        guard let self = self else { return }
                        if let safeRef = ref {
                            StorageManager.shared.downloadUrl(path: safeRef) { url in
                                guard let safeUrl = url else {return}
                                self.postVideoComment(videoUrl: safeUrl, videoRef: safeRef)
                            }
                        } else {
                            AlertManager.shared.showAlert(title: "Warning".localized(), message: "Error uploading video".localized(), cancelAction: "Cancel".localized(), style: .cancel)
                        }
                        self.progressView.hide()
                        self.activityView.showActivityIndicator()
                    }
                } else if let post = self.blogPost {
                    StorageManager.shared.uploadVideoURLForBlogComment(videoID: videoId, videoData: videoData, blogPost: post, progressHandler: { [weak self] percentComplete in
                        guard let self = self else {return}
                        self.progressView.showProgress(progressLabelText: String(format: "Uploading video (%d%%)".localized(), Int(percentComplete * 100)), percentComplete: percentComplete)
                    })  { [weak self] ref in
                        guard let self = self else { return }
                        if let safeRef = ref {
                            StorageManager.shared.downloadUrl(path: safeRef) { url in
                                guard let safeUrl = url else {return}
                                self.postVideoComment(videoUrl: safeUrl, videoRef: safeRef)
                            }
                        } else {
                            AlertManager.shared.showAlert(title: "Warning".localized(), message: "Error uploading video".localized(), cancelAction: "Cancel".localized(), style: .cancel)
                        }
                        self.progressView.hide()
                        self.activityView.showActivityIndicator()
                    }
                }
            }
        }
        
        let videoImage = UIImage(named: "popcorn")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        videoAction.setValue(videoImage, forKey: "image")

        actionSheet.addAction(cameraAction)
        actionSheet.addAction(photoAction)
        actionSheet.addAction(videoAction)
        actionSheet.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
       
        present(actionSheet, animated: true)
    }
    
    //MARK: - Methods for saving new comments to Firestore and loading them to the local commentsArray
    
    private func postComment(text: String) {
        let senderName = sender.displayName.replacingOccurrences(of: " ", with: "_")
        let messageId = "\(senderName)_\(Date().formattedString(dateFormat: "dd MM YYYY HH:mm:ss"))"
        let fileURL = documentsDirectory.appendingPathComponent("userImage.jpg")
        let userImage = UIImage(contentsOfFile: fileURL.path)
        guard let imageData = userImage?.jpegData(compressionQuality: 0.5) else { return }
        let newComment = Comment(sender: sender, messageId: messageId, sentDate: Date(), kind: .text(text), userImage: imageData, workoutId: workout?.id, programId: workout?.programID, mediaRef: nil)
        
        if let workout = self.workout {
            DatabaseManager.shared.postComment(comment: newComment) { [weak self] success in
                guard let self = self else {return}
                if success {
                    self.loadComments(for: workout, loadCommentsClosure: DatabaseManager.shared.getAllComments) { success in
                        if success {
                            self.onCommentPosted?()
                            DispatchQueue.main.async {
                                self.messagesCollectionView.scrollToLastItem()
                            }
                        }
                    }
                } else {
                    AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to post comment".localized(), cancelAction: "Cancel".localized(), style: .cancel)
                }
            }
            messageInputBar.inputTextView.text = nil
        } else if let post = self.blogPost {
            DatabaseManager.shared.postBlogComment(comment: newComment, post: post) { [weak self] success in
                guard let self = self else {return}
                if success {
                    self.loadComments(for: post, loadCommentsClosure: DatabaseManager.shared.getAllBlogComments) { success in
                        if success {
                            self.onCommentPosted?()
                            DispatchQueue.main.async {
                                self.messagesCollectionView.scrollToLastItem()
                                
                            }
                        }
                    }
                } else {
                    AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to post comment".localized(), cancelAction: "Cancel".localized(), style: .cancel)
                }
            }
            messageInputBar.inputTextView.text = nil
        }
    }
    
    private func postPhotoComment(photoUrl: URL, photoRef: String) {
        let senderName = sender.displayName.replacingOccurrences(of: " ", with: "_")
        let messageId = "\(senderName)_\(Date().formattedString(dateFormat: "dd MM YYYY HH:mm:ss"))"
        let fileURL = documentsDirectory.appendingPathComponent("userImage.jpg")
        let userImage = UIImage(contentsOfFile: fileURL.path)
        guard let imageData = userImage?.jpegData(compressionQuality: 0.5) else { return }
        
        guard let placeholder = UIImage(systemName: "photo") else {return}
        let media = Media(url: photoUrl, image: placeholder, placeholderImage: placeholder, size: .zero)
        let newComment = Comment(sender: sender, messageId: messageId, sentDate: Date(), kind: .photo(media), userImage: imageData, workoutId: workout?.id, programId: workout?.programID, mediaRef: photoRef)
        
        if let workout = self.workout {
            DatabaseManager.shared.postComment(comment: newComment) { [weak self] success in
                guard let self = self else {return}
                if success {
                    self.loadComments(for: workout, loadCommentsClosure: DatabaseManager.shared.getAllComments) { success in
                        if success {
                            self.onCommentPosted?()
                            DispatchQueue.main.async {
                                self.messagesCollectionView.scrollToLastItem()                            }
                        }
                    }
                } else {
                    AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to post comment".localized(), cancelAction: "Cancel".localized(), style: .cancel)
                }
            }
        } else if let post = self.blogPost {
            DatabaseManager.shared.postBlogComment(comment: newComment, post: post) { [weak self] success in
                guard let self = self else {return}
                if success {
                    self.loadComments(for: post, loadCommentsClosure: DatabaseManager.shared.getAllBlogComments) { success in
                        if success {
                            self.onCommentPosted?()
                            DispatchQueue.main.async {
                                self.messagesCollectionView.scrollToLastItem()
                            }
                        }
                    }
                } else {
                    AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to post comment".localized(), cancelAction: "Cancel".localized(), style: .cancel)
                }
            }
        }
    }
    
    private func postVideoComment(videoUrl: URL, videoRef: String) {
        let senderName = sender.displayName.replacingOccurrences(of: " ", with: "_")
        let messageId = "\(senderName)_\(Date().formattedString(dateFormat: "dd MM YYYY HH:mm:ss"))"
        let fileURL = documentsDirectory.appendingPathComponent("userImage.jpg")
        let userImage = UIImage(contentsOfFile: fileURL.path)
        guard let imageData = userImage?.jpegData(compressionQuality: 0.5) else { return }
        
        guard let placeholder = UIImage(systemName: "video.fill") else {return}
        let media = Media(url: videoUrl, image: placeholder, placeholderImage: placeholder, size: .zero)
       
        let newComment = Comment(sender: sender, messageId: messageId, sentDate: Date(), kind: .video(media), userImage: imageData, workoutId: workout?.id, programId: workout?.programID, mediaRef: videoRef)
        if let workout = self.workout {
            DatabaseManager.shared.postComment(comment: newComment) { [weak self] success in
                guard let self = self else {return}
                if success {
                    self.loadComments(for: workout, loadCommentsClosure: DatabaseManager.shared.getAllComments) { success in
                        if success {
                            self.onCommentPosted?()
                            DispatchQueue.main.async {
                                self.messagesCollectionView.scrollToLastItem()
                            }
                        }
                    }
                } else {
                    AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to post comment".localized(), cancelAction: "Cancel".localized(), style: .cancel)
                }
            }
        } else if let post = self.blogPost {
            DatabaseManager.shared.postBlogComment(comment: newComment, post: post) { [weak self] success in
                guard let self = self else {return}
                if success {
                    self.loadComments(for: post, loadCommentsClosure: DatabaseManager.shared.getAllBlogComments) { success in
                        if success {
                            self.onCommentPosted?()
                            DispatchQueue.main.async {
                                self.messagesCollectionView.scrollToLastItem()
                            }
                        }
                    }
                } else {
                    AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to post comment".localized(), cancelAction: "Cancel".localized(), style: .cancel)
                }
            }
        }
    }
    
    private func loadComments<T>(for object: T, loadCommentsClosure: @escaping (T, @escaping ([Comment]) -> Void) -> Void, completion: ((Bool) -> Void)? = nil) {
        self.activityView.showActivityIndicator()
        loadCommentsClosure(object) { [weak self] comments in
            guard let self = self else { return }
            self.commentsArray = comments
            print("loaded \(self.commentsArray.count) comments")
            DispatchQueue.main.async {
                self.messagesCollectionView.reloadData()
                self.activityView.hide()
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
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let deleteAction = UIAlertAction(title: "Delete".localized(), style: .destructive) { [weak self] action in
                    guard let self = self else {return}
                    if let workout = self.workout {
                        DatabaseManager.shared.deleteComment(comment: selectedMessage) { success in
                            if success {
                                if let messageMediaRef = selectedMessage.mediaRef {
                                    StorageManager.shared.deleteCommentsPhotoAndVideo(mediaRef: messageMediaRef)
                                    print(messageMediaRef)
                                }
                                self.loadComments(for: workout, loadCommentsClosure: DatabaseManager.shared.getAllComments)
                            } else {
                                AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to delete comment".localized(), cancelAction: "Cancel".localized(), style: .cancel)
                            }
                        }
                    } else if let post = self.blogPost {
                        DatabaseManager.shared.deleteBlogComment(comment: selectedMessage, blogPost: post) { success in
                            if success {
                                if let messageMediaRef = selectedMessage.mediaRef {
                                    StorageManager.shared.deleteCommentsPhotoAndVideo(mediaRef: messageMediaRef)
                                }
                                self.loadComments(for: post, loadCommentsClosure: DatabaseManager.shared.getAllBlogComments)
                            } else {
                                AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to delete comment".localized(), cancelAction: "Cancel".localized(), style: .cancel)
                            }
                        }
                    }
                }
                
                let editAction = UIAlertAction(title: "Edit".localized(), style: .default) { [weak self] action in
                    guard let self = self else {return}
                    
                    switch selectedMessage.kind {
                    case .text(let textToEdit):
                        let commentVC = TextViewController()
                        commentVC.title = "Edit comment".localized()
                        commentVC.text = textToEdit
                        self.navigationController?.pushViewController(commentVC, animated: true)
                        commentVC.onWorkoutSave = { text in
                            if let workout = self.workout {
                                DatabaseManager.shared.updateComment(comment: selectedMessage, newDescription: text, newMediaRef: nil) { success in
                                    if success{
                                        self.loadComments(for: workout, loadCommentsClosure: DatabaseManager.shared.getAllComments)
                                    } else {
                                        AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to update selected comment".localized(), cancelAction: "Cancel".localized(), style: .cancel)
                                    }
                                }
                            } else if let post = self.blogPost {
                                DatabaseManager.shared.updateBlogComment(comment: selectedMessage, blogPost: post, newDescription: text, newMediaRef: nil) { success in
                                    if success{
                                        self.loadComments(for: post, loadCommentsClosure: DatabaseManager.shared.getAllBlogComments)
                                    } else {
                                        AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to update selected comment".localized(), cancelAction: "Cancel".localized(), style: .cancel)
                                    }
                                }
                            }
                        }
                        
                    case .photo(_):
                        self.showImagePickerController(type: .photo)
                        self.onFinishPicking = { [weak self] info in
                            guard let self = self, let image = info[.originalImage] as? UIImage else { return }
                            guard let imageData = image.jpegData(compressionQuality: 0.6) else { return }
                            let imageId = self.sender.displayName.replacingOccurrences(of: " ", with: "_") + UUID().uuidString
                            if let workout = self.workout {
                                if let messageMediaRef = selectedMessage.mediaRef {
                                    StorageManager.shared.deleteCommentsPhotoAndVideo(mediaRef: messageMediaRef)
                                    print(messageMediaRef)
                                }
                                StorageManager.shared.uploadImageForComment(image: imageData, imageId: imageId, workout: workout, progressHandler: { [weak self] percentComplete in
                                    guard let self = self else {return}
                                    self.progressView.showProgress(progressLabelText: String(format: "Updating photo (%d%%)".localized(), Int(percentComplete * 100)), percentComplete: percentComplete)
                                }) { [weak self] ref in
                                    guard let self = self, let safeRef = ref else { return }
                                    StorageManager.shared.downloadUrl(path: safeRef) { url in
                                        guard let safeUrl = url else {return}
                                        let mediaUrl = safeUrl.absoluteString
                                        DatabaseManager.shared.updateComment(comment: selectedMessage, newDescription: mediaUrl, newMediaRef: safeRef) { success in
                                            if success {
                                                self.loadComments(for: workout, loadCommentsClosure: DatabaseManager.shared.getAllComments)
                                            } else {
                                                AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to update selected photo comment".localized(), cancelAction: "Cancel".localized(), style: .cancel)
                                            }
                                            self.progressView.hide()
                                        }
                                    }
                                }
                                
                            } else if let post = self.blogPost {
                                if let messageMediaRef = selectedMessage.mediaRef {
                                    StorageManager.shared.deleteCommentsPhotoAndVideo(mediaRef: messageMediaRef)
                                }
                                StorageManager.shared.uploadImageForBlogComment(image: imageData, imageId: imageId, blogPost: post, progressHandler: { [weak self] percentComplete in
                                    guard let self = self else {return}
                                    self.progressView.showProgress(progressLabelText: String(format: "Updating photo (%d%%)".localized(), Int(percentComplete * 100)), percentComplete: percentComplete)
                                }) { [weak self] ref in
                                    guard let self = self, let safeRef = ref else { return }
                                    StorageManager.shared.downloadUrl(path: safeRef) { url in
                                        guard let safeUrl = url else {return}
                                        let mediaUrl = safeUrl.absoluteString
                                        DatabaseManager.shared.updateComment(comment: selectedMessage, newDescription: mediaUrl, newMediaRef: safeRef) { success in
                                            if success {
                                                self.loadComments(for: post, loadCommentsClosure: DatabaseManager.shared.getAllBlogComments)
                                            } else {
                                                AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to update selected photo comment".localized(), cancelAction: "Cancel".localized(), style: .cancel)
                                            }
                                            self.progressView.hide()
                                        }
                                    }
                                }
                            }
                        }
                        
                    case .video(_):
                        self.showImagePickerController(type: .video)
                        self.onFinishPicking = { [weak self] info in
                            guard let self = self, let videoUrl = info[.mediaURL] as? URL else {return}
                            let videoId = self.sender.displayName.replacingOccurrences(of: " ", with: "_") + (UUID().uuidString) + ".mov"
                            let videoData = try! Data(contentsOf: videoUrl)
                            if let workout = self.workout {
                                if let messageMediaRef = selectedMessage.mediaRef {
                                    StorageManager.shared.deleteCommentsPhotoAndVideo(mediaRef: messageMediaRef)
                                }
                                StorageManager.shared.uploadVideoURLForComment(videoID: videoId, videoData: videoData, workout: workout, progressHandler: { [weak self] percentComplete in
                                    guard let self = self else {return}
                                    self.progressView.showProgress(progressLabelText: String(format: "Updating video (%d%%)".localized(), Int(percentComplete * 100)), percentComplete: percentComplete)
                                })  { [weak self] ref in
                                    guard let self = self, let safeRef = ref else {return}
                                    StorageManager.shared.downloadUrl(path: safeRef) { url in
                                        guard let safeUrl = url else { print("unable to get safeURL")
                                            return}
                                        let mediaUrl = safeUrl.absoluteString
                                        DatabaseManager.shared.updateComment(comment: selectedMessage, newDescription: mediaUrl, newMediaRef: mediaUrl) { success in
                                            if success {
                                                self.loadComments(for: workout, loadCommentsClosure: DatabaseManager.shared.getAllComments)
                                            } else {
                                                AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to update selected video comment".localized(), cancelAction: "Cancel".localized(), style: .cancel)
                                            }
                                            self.progressView.hide()
                                        }
                                    }
                                }
                            } else if let post = self.blogPost {
                                if let messageMediaRef = selectedMessage.mediaRef {
                                    StorageManager.shared.deleteCommentsPhotoAndVideo(mediaRef: messageMediaRef)
                                }
                                StorageManager.shared.uploadVideoURLForBlogComment(videoID: videoId, videoData: videoData, blogPost: post, progressHandler: { [weak self] percentComplete in
                                    guard let self = self else {return}
                                    self.progressView.showProgress(progressLabelText: String(format: "Updating video (%d%%)".localized(), Int(percentComplete * 100)), percentComplete: percentComplete)
                                })  { [weak self] ref in
                                    guard let self = self, let safeRef = ref else {return}
                                    StorageManager.shared.downloadUrl(path: safeRef) { url in
                                        guard let safeUrl = url else { print("unable to get safeURL")
                                            return}
                                        let mediaUrl = safeUrl.absoluteString
                                        DatabaseManager.shared.updateComment(comment: selectedMessage, newDescription: mediaUrl, newMediaRef: mediaUrl) { success in
                                            if success {
                                                self.loadComments(for: post, loadCommentsClosure: DatabaseManager.shared.getAllBlogComments)
                                            } else {
                                                AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to update selected video comment".localized(), cancelAction: "Cancel".localized(), style: .cancel)
                                            }
                                            self.progressView.hide()
                                        }
                                    }
                                }
                            }
                        }
                    default: break
                    }
                }
                let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel)
                alertController.addAction(editAction)
                alertController.addAction(deleteAction)
                alertController.addAction(cancelAction)
                alertController.view.tintColor = .darkGray
                present(alertController, animated: true)
            }
        }
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
        let formatter = DateFormatter()
        let currentLanguage = LanguageManager.shared.currentLanguage
        if currentLanguage.rawValue == "ru" {
            formatter.locale = Locale(identifier: "ru_RU")
            formatter.dateFormat = "dd MMM yyyy, HH:mm"
        } else {
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "MMM dd yyyy, HH:mm"
        }
        let dateString = formatter.string(from: sentDate)
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
            self.activityView.hide()
            
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
            self.activityView.hide()
            
        default: break
        }
    }
}

extension CommentsViewController: MessageCellDelegate {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {return}
        let comment = commentsArray[indexPath.section]
        guard comment.sender.senderId != userEmail else {return}
        self.activityView.showActivityIndicator()
        let otherUserEmail = comment.sender.senderId
        let profileVC = ProfileTableViewController(email: otherUserEmail)
        profileVC.fetchUserRecords()
        profileVC.fetchOtherUserData { [weak self] success in
            guard let self = self else {return}
            if success {
                self.activityView.hide()
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
    
    func replyTo(sender: String, message: String) {
        let replyTo = "Reply to".localized()
        let modifiedText = "\(replyTo) \(sender): \n \" \(message) \"\n"
        self.messageInputBar.inputTextView.text = modifiedText
        let attributedString = NSMutableAttributedString(string: modifiedText)
        let copiedTextRange = NSRange(location: 0, length: modifiedText.count)
        attributedString.addAttribute(.backgroundColor, value: UIColor.systemGray, range: copiedTextRange)
        attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: copiedTextRange)
        let font = UIFont.systemFont(ofSize: 16)
        attributedString.addAttribute(.font, value: font, range: copiedTextRange)
        self.messageInputBar.inputTextView.attributedText = attributedString
    }

    func didTapMessage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {return}

        let comment = commentsArray[indexPath.section]
        guard comment.sender.senderId != userEmail else {return}
        let sender = comment.sender.displayName

        switch comment.kind {
        case .text(let text):
            self.replyTo(sender: sender, message: text)
        default: break
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
    
    private func showImagePickerController(type: ImagePickerType) {
       let picker = UIImagePickerController()
        picker.navigationController?.navigationBar.barTintColor = .systemGreen
            picker.delegate = self
        switch type {
        case .camera:
            picker.sourceType = .camera
            picker.mediaTypes = ["public.image"]
        case .photo:
            picker.sourceType = .photoLibrary
            picker.mediaTypes = ["public.image"]
        case .video:
            picker.allowsEditing = true
            picker.sourceType = .photoLibrary
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
        }
        self.navigationController?.present(picker, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        self.activityView.hide()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.onFinishPicking?(info)
        picker.dismiss(animated: true)
        self.activityView.hide()
    }
}



