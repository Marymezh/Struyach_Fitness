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
import Photos

final class CommentsViewController: CommentsMessagesViewController, UITextViewDelegate {
    
    //    MARK: - Properties
    
    private let workout: Workout?
    private let blogPost: Post?
    var commentsArray: [Comment] = []
    private var userImage: UIImage?
    
    private var progressView = ProgressView()
    private var activityView = ActivityView()
    private var detailsView = DetailsView()

    var onFinishPicking:(([UIImagePickerController.InfoKey : Any])-> Void)?
    var onCommentPosted: (() -> ())?
    
    private var userName: String?
    private let userEmail = UserDefaults.standard.string(forKey: "email")
    private lazy var sender = Sender(senderId: userEmail ?? "unknown email", displayName: userName ?? "unknown user")
    private var recipientToken: String?
    private var recipientLanguage: String?
    
    private let selectedColor = UserDefaults.standard.colorForKey(key: "SelectedColor")
    private lazy var appColor = selectedColor ?? .systemGreen
    
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
        setupNavBar()
        setupInputBar()
        setupSubviews()
        setupDetailsView()
        self.userName = UserDefaults.standard.string(forKey: "userName")
        setupGestureRecognizer()
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUserImage()
        self.navigationController?.navigationBar.prefersLargeTitles = false
        if let workout = self.workout {
            loadComments(for: workout, loadCommentsClosure: DatabaseManager.shared.getAllComments)
        } else if let post = self.blogPost {
            loadComments(for: post, loadCommentsClosure: DatabaseManager.shared.getAllBlogComments)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true 
    }
    
    deinit {
           print ("comments vc is deallocated")
       }
    
    private func setupNavBar() {
        let infoIconImage = UIImage(systemName: "info.circle")
        let infoButton = UIBarButtonItem(image: infoIconImage, style: .plain, target: self, action: #selector(toggleDetailsView))
        infoButton.tintColor = appColor
        navigationItem.rightBarButtonItem = infoButton
    }
    
    @objc private func toggleDetailsView() {
        detailsView.isHidden = !detailsView.isHidden

        if detailsView.isHidden {
            messagesCollectionView.alpha = 1
        } else {
            messagesCollectionView.alpha = 0.5
        }
    }
    
    //MARK: - Message Collection View and InputBarView setup
    
    private func setupMessageCollectionView() {
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
    private func changeUserName() {
        AlertManager.shared.showAlert(title: "Warning".localized(), message: "You can't post comments as an Anonymous user, please change your display name. You can do it right now or later in Settings tab".localized(), placeholderText: "Enter new name here".localized(), cancelAction: "Cancel".localized(), confirmActionTitle: "Save".localized()) { [weak self] success, text in
            guard let self = self,
                  let email = self.userEmail else {return}
            if success {
                if let text = text, text != "" {
                    DatabaseManager.shared.updateUserName(email: email, newUserName: text) { success in
                        if success {
                            UserDefaults.standard.set(text, forKey: "userName")
                            self.userName = UserDefaults.standard.string(forKey: "userName")
                            self.sender = Sender(senderId: self.userEmail ?? "unknown email", displayName: self.userName ?? "unknown user")
                            print (self.sender.displayName)
                            AlertManager.shared.showAlert(title: "Done".localized(), message: "User name is successfully changed".localized(), cancelAction: "Ok")
                            
                            print("userName: \(self.userName!)")
                        } else {
                            AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to change user's name".localized(), cancelAction: "Ok")
                        }
                    }
                }
                } else {
                    AlertManager.shared.showAlert(title: "Error".localized(), message: "User name can not be blank!".localized(), cancelAction: "Cancel".localized())
            }
        }
    }
    
    private func setupInputBar() {
        messageInputBar.delegate = self
        messageInputBar.inputTextView.delegate = self
        let attachButton = InputBarButtonItem()
        attachButton.setSize(CGSize(width: 35, height: 35), animated: false)
        let image = UIImage(systemName: "paperclip", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium))?.withTintColor(.contrastGray)
        attachButton.setImage(image, for: .normal)
        attachButton.onTouchUpInside { [weak self]_ in
            guard let self = self else {return}
            if self.userName == "unknown user" || self.userName ==  "Anonymous user" || self.userName == "Анонимный пользователь" {
                self.changeUserName()
            } else {
                self.presentInputOptions()
            }
        }
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
    }
    
    //    MARK: - Setup subviews
    
    private func setupSubviews() {
        progressView.toAutoLayout()
        progressView.progressView.progressTintColor = appColor
        activityView.toAutoLayout()
        activityView.activityIndicator.color = appColor
        progressView.isHidden = true
        activityView.isHidden = true
        view.addSubviews(progressView, activityView)
        
        let constraints = [
            
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
    
    private func setupDetailsView() {
        detailsView.isHidden = true
        if let workout = workout {
            detailsView.textView.text = workout.description
        } else if let post = blogPost {
            detailsView.textView.text = post.description
        }
        detailsView.toAutoLayout()
        view.addSubview(detailsView)

        let constraints = [
            detailsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            detailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            detailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
                    detailsView.heightAnchor.constraint(equalToConstant: 300)
                ]
                NSLayoutConstraint.activate(constraints)
    }
    
    //MARK: - Input options for InputBarAttachButton
    
    private func presentInputOptions() {
        guard let email = userEmail else {return}
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.view.tintColor = appColor
        let cameraAction = UIAlertAction(title: "Camera".localized(), style: .default) { [weak self] _ in
            guard let self = self else {return}
            self.activityView.showActivityIndicator()
            self.askForPermission(type: .camera)
            self.onFinishPicking = { [weak self] info in
                guard let image = info[.originalImage] as? UIImage,
                      let imageData = image.jpegData(compressionQuality: 0.2),
                      let self = self else { return }
                if let workout = self.workout {
                    let imageId =  "comments_workout_photo:\(workout.id)_\(Date().formattedString(dateFormat: "dd MM YYYY HH:mm:ss"))"
                    StorageManager.shared.uploadImageForComment(email: email, image: imageData, imageId: imageId,progressHandler: { [weak self] percentComplete in
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
                            AlertManager.shared.showAlert(title: "Warning".localized(), message: "Error uploading image".localized(), cancelAction: "Cancel".localized())
                        }
                        self.progressView.hide()
                    }
                } else if let post = self.blogPost {
                    let imageId =  "comments_blog_post_photo:\(post.id)_\(Date().formattedString(dateFormat: "dd MM YYYY HH:mm:ss"))"
                    StorageManager.shared.uploadImageForComment(email: email, image: imageData, imageId: imageId, progressHandler: { [weak self] percentComplete in
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
                            AlertManager.shared.showAlert(title: "Warning".localized(), message: "Error uploading image".localized(), cancelAction: "Cancel".localized())
                        }
                        self.progressView.hide()
                    }
                }
            }
        }
        let cameraImage = UIImage(systemName: "camera")?.withTintColor(appColor)
        cameraAction.setValue(cameraImage, forKey: "image")
        
        let photoAction = UIAlertAction(title: "Photo".localized(), style: .default) { [weak self] _ in
            guard let self = self else {return}
            self.activityView.showActivityIndicator()
            self.askForPermission(type: .photo)
            self.onFinishPicking = {[weak self] info in
                guard let image = info[.originalImage] as? UIImage,
                      let imageData = image.jpegData(compressionQuality: 0.6),
                      let self = self else { return }
                if let workout = self.workout {
                    let imageId =  "comments_workout_photo:\(workout.id)_\(Date().formattedString(dateFormat: "dd MM YYYY HH:mm:ss"))"
                    StorageManager.shared.uploadImageForComment(email: email, image: imageData, imageId: imageId, progressHandler: { [weak self] percentComplete in
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
                            AlertManager.shared.showAlert(title: "Warning".localized(), message: "Error uploading image".localized(), cancelAction: "Cancel".localized())
                        }
                        self.progressView.hide()
                        self.activityView.showActivityIndicator()
                        
                    }
                } else if let post = self.blogPost {
                    let imageId =  "comments_blog_post_photo:\(post.id)_\(Date().formattedString(dateFormat: "dd MM YYYY HH:mm:ss"))"
                    StorageManager.shared.uploadImageForComment(email: email, image: imageData, imageId: imageId, progressHandler: { [weak self] percentComplete in
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
                            AlertManager.shared.showAlert(title: "Warning".localized(), message: "Error uploading image".localized(), cancelAction: "Cancel".localized())
                        }
                        self.progressView.hide()
                        self.activityView.showActivityIndicator()
                    }
                }
            }
        }
        
        let photoImage = UIImage(systemName: "photo")?.withTintColor(appColor)
        photoAction.setValue(photoImage, forKey: "image")
        
        let videoAction = UIAlertAction(title: "Video".localized(), style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.activityView.showActivityIndicator()
            self.askForPermission(type: .video)
            self.onFinishPicking = {  [weak self] info in
                guard let videoUrl = info[.mediaURL] as? URL,
                      let self = self else {
                    AlertManager.shared.showAlert(title: "Warning".localized(), message: "Couldn't get media URL from image picker".localized(), cancelAction: "Cancel".localized())
                    return
                }
                do {
                    let videoData = try Data(contentsOf: videoUrl)
                    if let workout = self.workout {
                        let videoId = "comments_workout_video:\(workout.id)_\(Date().formattedString(dateFormat: "dd MM YYYY HH:mm:ss")).mov"
                        StorageManager.shared.uploadVideoURLForComment(email: email, videoID: videoId, videoData: videoData, progressHandler: { [weak self] percentComplete in
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
                                AlertManager.shared.showAlert(title: "Warning".localized(), message: "Error uploading video".localized(), cancelAction: "Cancel".localized())
                            }
                            self.progressView.hide()
                            self.activityView.showActivityIndicator()
                        }
                    } else if let post = self.blogPost {
                        let videoId = "comments_blog_post_video:\(post.id)_\(Date().formattedString(dateFormat: "dd MM YYYY HH:mm:ss")).mov"
                        StorageManager.shared.uploadVideoURLForComment(email: email, videoID: videoId, videoData: videoData, progressHandler: { [weak self] percentComplete in
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
                                AlertManager.shared.showAlert(title: "Warning".localized(), message: "Error uploading video".localized(), cancelAction: "Cancel".localized())
                            }
                            self.progressView.hide()
                            self.activityView.showActivityIndicator()
                        }
                    }
                } catch {
                    AlertManager.shared.showAlert(title: "Warning".localized(), message: "Error creating video data".localized(), cancelAction: "Cancel".localized())
                }
            }
        }
        
        let videoImage = UIImage(systemName: "tv")?.withTintColor(appColor)
        videoAction.setValue(videoImage, forKey: "image")

        actionSheet.addAction(cameraAction)
        actionSheet.addAction(photoAction)
        actionSheet.addAction(videoAction)
        actionSheet.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        actionSheet.view.tintColor = appColor
        present(actionSheet, animated: true)
    }
    
    //MARK: - Methods for saving new comments to Firestore and loading them to the local commentsArray
    
    private func getUserImage() {
        print ("get user image")
        guard let email = userEmail else {
            print ("no email")
            return}
        DatabaseManager.shared.getUser(email: email) { [weak self] user in
            guard let self = self, let user = user else { return }
            guard let imageRef = user.profilePictureRef, !imageRef.isEmpty else {
                self.userImage = UIImage(systemName: "person.circle")
                print("no image ref, setting default user image")
                return}
            StorageManager.shared.downloadUrl(path: imageRef) { url in
                guard let url = url else { return }

                let task = URLSession.shared.dataTask(with: url) { data, response, error in
                    guard let data = data, error == nil else {
                        print("Error downloading image: \(error?.localizedDescription ?? "unknown error".localized())")
                        return
                    }

                    if let image = UIImage(data: data) {
                        self.userImage = image
                        print ("set user image for the avatar")
                    } else {
                        print("Error creating image from data")
                    }
                }
                task.resume()
            }
        }
    }
    
    private func getUserFCMToken(email: String) {
        DatabaseManager.shared.getUser(email: email) { [weak self] user in
            guard let self = self, let user = user else { return }
            guard let fcmToken = user.fcmToken, !fcmToken.isEmpty else {return}
            let userLanguage = user.userLanguage ?? "ru"
            self.recipientToken = fcmToken
            self.recipientLanguage = userLanguage
            print ("recipient token is: \(recipientToken ?? "empty")")
            print ("recipient language is: \(recipientLanguage ?? "not set")")
        }
    }
    
    private func sendNotificationToCoach(message: String, destination: String, collectionId: String?, notificationType: String) {
        NotificationsManager.shared.sendPush(withToken: NotificationsManager.shared.coachToken, push: UserPush(title: "New message".localized(), body: message, type: notificationType, destination: destination, collectionId: collectionId)) { success in
            if success {
                print ("successfully sent notificaton to the coach")
            } else {
                print ("error sending notification to the coach")
            }
        }
    }
    
    private func sendReplyNotification(fcmToken: String, message: String, destination: String, collectionId: String?, notificationType: String) {
        NotificationsManager.shared.sendPush(withToken: fcmToken, push: UserPush(title: "New reply".localized(withLanguage: self.recipientLanguage ?? "ru"), body: message, type: notificationType, destination: destination, collectionId: collectionId)) { success in
            if success {
                print ("REPLY NOTIFICATION SENT")
            } else {
                print ("error sending notification")
            }
        }
    }
    
    private func postComment(text: String) {
        let senderName = sender.displayName.replacingOccurrences(of: " ", with: "_")
        print (sender.displayName)
        let messageId = "\(senderName)_\(Date().formattedString(dateFormat: "dd MM YYYY HH:mm:ss"))"
        guard let imageData = userImage?.jpegData(compressionQuality: 0.5) else {
            print ("no user image data")
            return }
        let newComment = Comment(sender: sender, messageId: messageId, sentDate: Date(), kind: .text(text), userImage: imageData, workoutId: workout?.id, programId: workout?.programID, mediaRef: "")
        //this will show new post immediately, without waitind for database update
        self.commentsArray.append(newComment)
        self.messagesCollectionView.reloadData()
        
        if let workout = self.workout {
            DatabaseManager.shared.postComment(comment: newComment) { [weak self] success in
                guard let self = self else {return}
                if success {
                    self.loadComments(for: workout, loadCommentsClosure: DatabaseManager.shared.getAllComments) { success in
                        if success {
                            self.onCommentPosted?()
                            if self.recipientToken != nil, self.recipientToken != "", self.recipientToken != NotificationsManager.shared.coachToken {
                                let message = String(format: "%1$@ replied to your comment for the workout in  %2$@".localized(withLanguage: self.recipientLanguage ?? "ru"), senderName,  workout.programID.replacingOccurrences(of: "_", with: " ").localized(withLanguage: self.recipientLanguage ?? "ru"))
                                self.sendReplyNotification(fcmToken: self.recipientToken!, message: message, destination: workout.id, collectionId: workout.programID, notificationType: "workoutComment")
                                self.recipientToken = ""
                                self.recipientLanguage = ""
                                print ("recipient token is: \(self.recipientToken ?? "empty")")
                            } else {
                                let message = String(format: "New comment posted for workout %1$@ from %2$@: %3$@".localized(), workout.id, senderName, text)
                                self.sendNotificationToCoach(message: message, destination: workout.id, collectionId: workout.programID, notificationType: "workoutComment")
                            }
                            DispatchQueue.main.async {
                                self.messagesCollectionView.scrollToLastItem()
                            }
                        }
                    }
                } else {
                    AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to post comment".localized(), cancelAction: "Cancel".localized())
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
                            if self.recipientToken != nil, self.recipientToken != "", self.recipientToken != NotificationsManager.shared.coachToken {
                                let message = String(format: "%1$@ replied to your comment for the blog post %2$@".localized(withLanguage: self.recipientLanguage ?? "ru"), senderName, post.id)
                                self.sendReplyNotification(fcmToken: self.recipientToken!, message: message, destination: post.id, collectionId: nil, notificationType: "postComment")
                                self.recipientToken = ""
                                self.recipientLanguage = ""
                                print ("recipient token is: \(self.recipientToken ?? "empty")")
                            } else {
                                let message = String(format: "New comment posted for blog post %1$@ from %2$@: %3$@".localized(), post.id, senderName, text)
                                self.sendNotificationToCoach(message: message, destination: post.id, collectionId: nil, notificationType: "postComment")
                            }
                            DispatchQueue.main.async {
                                self.messagesCollectionView.scrollToLastItem()
                            }
                        }
                    }
                } else {
                    AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to post comment".localized(), cancelAction: "Cancel".localized())
                }
            }
            messageInputBar.inputTextView.text = nil
        }
    }
    
    private func postPhotoComment(photoUrl: URL, photoRef: String) {
        let senderName = sender.displayName.replacingOccurrences(of: " ", with: "_")
        let messageId = "\(senderName)_\(Date().formattedString(dateFormat: "dd MM YYYY HH:mm:ss"))"
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
                            let message = String(format: "New photo posted for workout %1$@ from %2$@".localized(), workout.id, senderName)
                            self.sendNotificationToCoach(message: message, destination: workout.id, collectionId: workout.programID, notificationType: "workoutComment")
                            DispatchQueue.main.async {
                                self.messagesCollectionView.scrollToLastItem()
                            }
                        }
                    }
                } else {
                    AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to post comment".localized(), cancelAction: "Cancel".localized())
                }
            }
        } else if let post = self.blogPost {
            DatabaseManager.shared.postBlogComment(comment: newComment, post: post) { [weak self] success in
                guard let self = self else {return}
                if success {
                    self.loadComments(for: post, loadCommentsClosure: DatabaseManager.shared.getAllBlogComments) { success in
                        if success {
                            self.onCommentPosted?()
                            let message = String(format: "New photo posted for blog post %1$@ from %2$@".localized(), post.id, senderName)
                            self.sendNotificationToCoach(message: message, destination: post.id, collectionId: nil, notificationType: "postComment")
                            DispatchQueue.main.async {
                                self.messagesCollectionView.scrollToLastItem()
                            }
                        }
                    }
                } else {
                    AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to post comment".localized(), cancelAction: "Cancel".localized())
                }
            }
        }
    }
    
    private func postVideoComment(videoUrl: URL, videoRef: String) {
        let senderName = sender.displayName.replacingOccurrences(of: " ", with: "_")
            let messageId = "\(senderName)_\(Date().formattedString(dateFormat: "dd MM YYYY HH:mm:ss"))"
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
                                let message = String(format: "New video posted for workout %1$@ from %2$@".localized(), workout.id, senderName)
                                self.sendNotificationToCoach(message: message, destination: workout.id, collectionId: workout.programID, notificationType: "workoutComment")
                                DispatchQueue.main.async {
                                    self.messagesCollectionView.scrollToLastItem()
                                }
                            }
                        }
                    } else {
                        AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to post comment".localized(), cancelAction: "Cancel".localized())
                    }
                }
            } else if let post = self.blogPost {
                DatabaseManager.shared.postBlogComment(comment: newComment, post: post) { [weak self] success in
                    guard let self = self else {return}
                    if success {
                        self.loadComments(for: post, loadCommentsClosure: DatabaseManager.shared.getAllBlogComments) { success in
                            if success {
                                self.onCommentPosted?()
                                let message = String(format: "New video posted for blog post %1$@ from %2$@".localized(), post.id, senderName)
                                self.sendNotificationToCoach(message: message, destination: post.id, collectionId: nil, notificationType: "postComment")
                                DispatchQueue.main.async {
                                    self.messagesCollectionView.scrollToLastItem()
                                }
                            }
                        }
                    } else {
                        AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to post comment".localized(), cancelAction: "Cancel".localized())
                }
            }
        }
    }
    
    private func loadComments<T>(for object: T, loadCommentsClosure: @escaping (T, @escaping ([Comment]) -> Void) -> Void, completion: ((Bool) -> Void)? = nil) {
        self.activityView.showActivityIndicator()
        loadCommentsClosure(object) { [weak self] comments in
            guard let self = self else { return }
            self.commentsArray = comments
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
        longPress.minimumPressDuration = 0.5
        messagesCollectionView.addGestureRecognizer(longPress)
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else {
             return
         }
        print("Executing function: \(#function)")
        let location = sender.location(in: messagesCollectionView)
        if let indexPath = messagesCollectionView.indexPathForItem(at: location) {
            let selectedMessage = self.commentsArray[indexPath.section]
            if userEmail == selectedMessage.sender.senderId {
                guard let email = userEmail else {return}
                
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
                                self.onCommentPosted?()
                            } else {
                                AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to delete comment".localized(), cancelAction: "Cancel".localized())
                            }
                        }
                    } else if let post = self.blogPost {
                        DatabaseManager.shared.deleteBlogComment(comment: selectedMessage, blogPost: post) { success in
                            if success {
                                if let messageMediaRef = selectedMessage.mediaRef {
                                    StorageManager.shared.deleteCommentsPhotoAndVideo(mediaRef: messageMediaRef)
                                }
                                self.loadComments(for: post, loadCommentsClosure: DatabaseManager.shared.getAllBlogComments)
                                self.onCommentPosted?()
                            } else {
                                AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to delete comment".localized(), cancelAction: "Cancel".localized())
                            }
                        }
                    }
                }
                
                let editAction = UIAlertAction(title: "Edit".localized(), style: .default) { [weak self] action in
                    guard let self = self else {return}
                    
                    switch selectedMessage.kind {
                    case .text(let textToEdit):
                        let commentVC = TextViewController()
                        commentVC.title = "Edit".localized()
                        commentVC.text = textToEdit
                        self.navigationController?.pushViewController(commentVC, animated: true)
                        commentVC.onWorkoutSave = { text, _ in
                            if let workout = self.workout {
                                DatabaseManager.shared.updateComment(comment: selectedMessage, newDescription: text, newMediaRef: nil) { success in
                                    if success{
                                        self.loadComments(for: workout, loadCommentsClosure: DatabaseManager.shared.getAllComments)
                                    } else {
                                        AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to update selected comment".localized(), cancelAction: "Cancel".localized())
                                    }
                                }
                            } else if let post = self.blogPost {
                                DatabaseManager.shared.updateBlogComment(comment: selectedMessage, blogPost: post, newDescription: text, newMediaRef: nil) { success in
                                    if success{
                                        self.loadComments(for: post, loadCommentsClosure: DatabaseManager.shared.getAllBlogComments)
                                    } else {
                                        AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to update selected comment".localized(), cancelAction: "Cancel".localized())
                                    }
                                }
                            }
                        }
                        
                    case .photo(_):
                        self.askForPermission(type: .photo)
                        self.onFinishPicking = { [weak self] info in
                            guard let self = self, let image = info[.originalImage] as? UIImage else { return }
                            guard let imageData = image.jpegData(compressionQuality: 0.6) else { return }
                            
                            if let workout = self.workout {
                                if let messageMediaRef = selectedMessage.mediaRef {
                                    StorageManager.shared.deleteCommentsPhotoAndVideo(mediaRef: messageMediaRef)
                                    print(messageMediaRef)
                                }
                                let imageId =  "comments_workout_photo:\(workout.programID)_\(workout.id)_\(Date().formattedString(dateFormat: "dd MM YYYY HH:mm:ss"))"
                                StorageManager.shared.uploadImageForComment(email: email, image: imageData, imageId: imageId, progressHandler: { [weak self] percentComplete in
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
                                                AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to update selected photo comment".localized(), cancelAction: "Cancel".localized())
                                            }
                                            self.progressView.hide()
                                        }
                                    }
                                }
                                
                            } else if let post = self.blogPost {
                                if let messageMediaRef = selectedMessage.mediaRef {
                                    StorageManager.shared.deleteCommentsPhotoAndVideo(mediaRef: messageMediaRef)
                                }
                                let imageId =  "comments_blog_post_photo:\(post.id)_\(Date().formattedString(dateFormat: "dd MM YYYY HH:mm:ss"))"
                                StorageManager.shared.uploadImageForComment(email: email, image: imageData, imageId: imageId, progressHandler: { [weak self] percentComplete in
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
                                                AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to update selected photo comment".localized(), cancelAction: "Cancel".localized())
                                            }
                                            self.progressView.hide()
                                        }
                                    }
                                }
                            }
                        }
                        
                    case .video(_):
                        self.askForPermission(type: .video)
                        self.onFinishPicking = { [weak self] info in
                            guard let self = self, let videoUrl = info[.mediaURL] as? URL else {return}
                            do {
                                let videoData = try Data(contentsOf: videoUrl)
                                if let workout = self.workout {
                                    if let messageMediaRef = selectedMessage.mediaRef {
                                        StorageManager.shared.deleteCommentsPhotoAndVideo(mediaRef: messageMediaRef)
                                    }
                                    let videoId = "comments_workout_video:\(workout.programID)_\(workout.id)_\(Date().formattedString(dateFormat: "dd MM YYYY HH:mm:ss")).mov"
                                    StorageManager.shared.uploadVideoURLForComment(email: email, videoID: videoId, videoData: videoData, progressHandler: { [weak self] percentComplete in
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
                                                    AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to update selected video comment".localized(), cancelAction: "Cancel".localized())
                                                }
                                                self.progressView.hide()
                                            }
                                        }
                                    }
                                } else if let post = self.blogPost {
                                    if let messageMediaRef = selectedMessage.mediaRef {
                                        StorageManager.shared.deleteCommentsPhotoAndVideo(mediaRef: messageMediaRef)
                                    }
                                    let videoId = "comments_blog_post_video:\(post.id)_\(Date().formattedString(dateFormat: "dd MM YYYY HH:mm:ss")).mov"
                                    StorageManager.shared.uploadVideoURLForComment(email: email, videoID: videoId, videoData: videoData, progressHandler: { [weak self] percentComplete in
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
                                                    AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to update selected video comment".localized(), cancelAction: "Cancel".localized())
                                                }
                                                self.progressView.hide()
                                            }
                                        }
                                    }
                                }
                            } catch {
                                AlertManager.shared.showAlert(title: "Warning".localized(), message: "Error creating video data".localized(), cancelAction: "Cancel".localized())
                            }
                        }
                    default: break
                    }
                }
                let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel)
                alertController.addAction(editAction)
                alertController.addAction(deleteAction)
                alertController.addAction(cancelAction)
                alertController.view.tintColor = appColor
                present(alertController, animated: true)
            } else {
                print("reply to other user")
                self.messageInputBar.becomeFirstResponder()
                self.messageInputBar.inputTextView.becomeFirstResponder()
                switch selectedMessage.kind {
                case .text(let text):
                    self.replyTo(sender: selectedMessage.sender.displayName, senderEmail: selectedMessage.sender.senderId, message: text)
                case .photo(_):
                    self.replyTo(sender: selectedMessage.sender.displayName, senderEmail: selectedMessage.sender.senderId, message: nil)
                case .video(_):
                    self.replyTo(sender: selectedMessage.sender.displayName, senderEmail: selectedMessage.sender.senderId, message: nil)
                default: break
                }
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
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? appColor : UIColor.systemGray2
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
            guard let imageUrl = media.url else { return }
            imageView.sd_setImage(with: imageUrl)
            self.activityView.hide()
        case .video(let media):
            guard let videoUrl = media.url else { return }
            let thumbnailCacheKey = "\(videoUrl.absoluteString)_thumbnail"
            if let cachedThumbnailImage = SDImageCache.shared.imageFromCache(forKey: thumbnailCacheKey) {
                imageView.image = cachedThumbnailImage
            } else {
                // Show a placeholder image here while the thumbnail is being fetched/generated
                imageView.image = UIImage(named: "image")
                
                // Generate the thumbnail image asynchronously
                DispatchQueue.global().async {
                    let asset = AVAsset(url: videoUrl)
                    let imageGenerator = AVAssetImageGenerator(asset: asset)
                    imageGenerator.appliesPreferredTrackTransform = true
                    let time = CMTime(seconds: 0.0, preferredTimescale: 1)
                    guard let cgImage = try? imageGenerator.copyCGImage(at: time, actualTime: nil) else {
                        DispatchQueue.main.async {
                            // Clear the placeholder image if thumbnail generation fails
                            imageView.image = UIImage(named: "Struyach_dark")
                        }
                        return
                    }
                    let thumbnailSize = CGSize(width: 80, height: 80)
                    let thumbnailImage = UIImage(cgImage: cgImage).sd_resizedImage(with: thumbnailSize, scaleMode: .aspectFill)
                    
                    SDImageCache.shared.store(thumbnailImage, forKey: thumbnailCacheKey, completion: nil)
                    
                    DispatchQueue.main.async {
                        imageView.image = thumbnailImage
                    }
                }
            }
            self.activityView.hide()
        default:
            break
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
        profileVC.fetchProfileData { [weak self] success in
            guard let self = self else {return}
            if success {
                self.activityView.hide()
                self.navigationController?.present(profileVC, animated: true)
            } else {
                self.activityView.hide()
                AlertManager.shared.showAlert(title: "Error".localized(), message: "Unable to open other user profile".localized(), cancelAction: "Cancel".localized())
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

    func didTapMessage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        let comment = commentsArray[indexPath.section]
        switch comment.kind {
        case .text(let text):
            // Check if the tapped message contains a URL
            if let url = extractURL(from: text) {
                openURL(url)
            }
        default:
            break
        }
    }

    private func extractURL(from text: String) -> URL? {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector?.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        
        guard let url = matches?.first?.url else { return nil }
        return url
    }

    private func openURL(_ url: URL) {
        // Handle the URL tap event, such as opening a web browser
        UIApplication.shared.open(url)
    }

    func replyTo(sender: String, senderEmail: String, message: String?) {
        let replyTo = "Reply to".localized()
        getUserFCMToken(email: senderEmail)
        if let message = message {
            let modifiedText = "\(replyTo) \(sender): \n\"\(message)\"\n\n"
            self.messageInputBar.inputTextView.text = modifiedText
        } else {
            let modifiedText = "\(replyTo) \(sender)\n\n"
            self.messageInputBar.inputTextView.text = modifiedText
        }
    }
}

extension CommentsViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        inputBar.inputTextView.resignFirstResponder()
        if self.userName == "unknown user" || self.userName ==  "Anonymous user" || self.userName == "Анонимный пользователь" {
            changeUserName()
        } else {
            postComment(text: text)
        }
    }
}

//MARK: - UIImagePickerControllerDelegate methods
extension CommentsViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func askForPermission(type: ImagePickerType) {
           switch type {
           case .camera:
               let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
               switch authorizationStatus {
               case .authorized:
                   presentImagePicker(type: type)
               case .denied:
                   AlertManager.shared.showAlert(title: "Permission Denied".localized(), message: "Please allow access to the camera in Phone Settings to take photos.".localized(), cancelAction: "Cancel".localized())
               case .notDetermined:
                   requestCameraPermission(type)
               default:
                   AlertManager.shared.showAlert(title: "Permission Denied".localized(), message: "Please allow access to the camera in Phone Settings to take photos.".localized(), cancelAction: "Cancel".localized())
               }
           case .photo, .video:
               let authorizationStatus = PHPhotoLibrary.authorizationStatus()
               switch authorizationStatus {
               case .authorized:
                   presentImagePicker(type: type)
               case .denied:
                   AlertManager.shared.showAlert(title: "Permission Denied".localized(), message: "Please allow access to the media library in Phone Settings to upload photos and videos.".localized(), cancelAction: "Cancel".localized())
               case .notDetermined:
                   requestPhotoLibraryPermission(type)
               default:
                   AlertManager.shared.showAlert(title: "Permission Denied".localized(), message: "Please allow access to the media library in Phone Settings to upload photos and videos.".localized(), cancelAction: "Cancel".localized())
               }
           }
       }

       private func requestCameraPermission(_ type: ImagePickerType) {
           AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
               guard let self = self else {return}
               DispatchQueue.main.async {
                   if granted {
                       self.presentImagePicker(type: type)
                   } else {
                       AlertManager.shared.showAlert(title: "Permission Denied".localized(), message: "Please allow access to the camera in Phone Settings to take photos.".localized(), cancelAction: "Cancel".localized())
                   }
               }
           }
       }

       private func requestPhotoLibraryPermission(_ type: ImagePickerType) {
           PHPhotoLibrary.requestAuthorization { [weak self] status in
               guard let self = self else {return}
               DispatchQueue.main.async {
                   if status == .authorized {
                       self.presentImagePicker(type: type)
                   } else {
                       AlertManager.shared.showAlert(title: "Permission Denied".localized(), message: "Please allow access to your Photo Library in Phone Settings to upload photos and videos.".localized(), cancelAction: "Cancel".localized())
                   }
               }
           }
       }
    private func presentImagePicker(type: ImagePickerType) {
       let picker = UIImagePickerController()
        picker.navigationController?.navigationBar.barTintColor = appColor
        picker.view.tintColor = appColor
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



