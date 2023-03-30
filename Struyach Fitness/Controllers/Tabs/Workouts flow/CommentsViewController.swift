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
    
    private let workout: Workout
    var commentsArray: [Comment] = []
    private var commentsListener: ListenerRegistration?
    private var progressView: UIProgressView!
    private var progressLabel: UILabel!
    
    var onImagePick:(([UIImagePickerController.InfoKey : Any])-> Void)?
    
    private let userName = UserDefaults.standard.string(forKey: "userName")
    private let userImage = UserDefaults.standard.data(forKey: "userImage")
    private let userEmail = UserDefaults.standard.string(forKey: "email")
    
    let workoutView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .white
        textView.textColor = .black
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
        view.backgroundColor = .customDarkGray
        return view
    }()
    
    let secondContainerView: UIView = {
        let view = UIView()
        view.toAutoLayout()
        view.backgroundColor = .white
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
    
    init (workout: Workout) {
        self.workout = workout
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
        setupProgress()
        loadComments(workout: self.workout)
        setupGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        commentsListener = DatabaseManager.shared.addNewCommentsListener(workout: workout) {[weak self] comments in
            guard let self = self else {return}
            self.commentsArray = comments
            self.messagesCollectionView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        commentsListener?.remove()
    }
    
    private func setupMessageCollectionView() {
        messagesCollectionView.toAutoLayout()
        messagesCollectionView.backgroundColor = .customDarkGray
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
    private func setupInputBar() {
        // Set up inputBar
        messageInputBar.delegate = self
        messageInputBar.backgroundView.backgroundColor = .customKeyboard
        messageInputBar.inputTextView.delegate = self
        messageInputBar.inputTextView.placeholder = " Write a comment..."
        messageInputBar.inputTextView.placeholderTextColor = .gray
        messageInputBar.inputTextView.backgroundColor = .white
        messageInputBar.inputTextView.layer.cornerRadius = 10
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 10, left: 5, bottom: 5, right: 5)
        messageInputBar.inputTextView.tintColor = .customDarkGray
        messageInputBar.tintColor = .systemGray
        
        let attachButton = InputBarButtonItem()
        attachButton.setSize(CGSize(width: 35, height: 44), animated: false)
        attachButton.setImage(UIImage(systemName: "paperclip", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)), for: .normal)
        attachButton.onTouchUpInside { [weak self]_ in
            self?.presentInputOptions()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        messageInputBar.sendButton.setTitle(nil, for: .normal)
        messageInputBar.sendButton.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)), for: .normal)
    }
    
    private func setupNavbarAndView() {
        self.view.backgroundColor = .customDarkGray
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UIImagePickerController.self]).tintColor = .systemGreen
        
        workoutView.text = workout.description
        view.addSubview(containerView)
        containerView.addSubview(secondContainerView)
        secondContainerView.addSubview(workoutView)
        
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
            
            workoutView.topAnchor.constraint(equalTo: secondContainerView.topAnchor, constant: 10),
            workoutView.leadingAnchor.constraint(equalTo: secondContainerView.leadingAnchor, constant: 10),
            workoutView.trailingAnchor.constraint(equalTo: secondContainerView.trailingAnchor, constant: -10),
            workoutView.heightAnchor.constraint(equalToConstant: 130),
            workoutView.bottomAnchor.constraint(equalTo: secondContainerView.bottomAnchor, constant: -10)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupProgress() {

        self.progressView = UIProgressView(progressViewStyle: .default)
        self.progressView.progress = 0
        self.progressView.progressTintColor = .systemGreen
        self.progressView.trackTintColor = .white
        self.progressView.toAutoLayout()
        self.progressView.layer.cornerRadius = 5
        self.progressView.layer.masksToBounds = true
        self.progressView.isHidden = true
        self.view.addSubview(self.progressView)
        
        self.progressLabel = UILabel()
        self.progressLabel.text = "Uploading video"
        self.progressLabel.textColor = .white
        self.progressLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        self.progressLabel.isHidden = true
        self.progressLabel.toAutoLayout()
        self.view.addSubview(self.progressLabel)
                
                let constraints = [
                    self.progressView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                    self.progressView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                    self.progressView.widthAnchor.constraint(equalToConstant: 200),
                    self.progressView.heightAnchor.constraint(equalToConstant: 12),
                    self.progressLabel.centerXAnchor.constraint(equalTo: self.progressView.centerXAnchor),
                    self.progressLabel.bottomAnchor.constraint(equalTo: self.progressView.topAnchor, constant: -10)
                ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func presentInputOptions() {
        let actionSheet = UIAlertController(title: "Attach media", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self]_ in
            guard let self = self else {return}
            let picker = UIImagePickerController()
            picker.allowsEditing = true
            picker.delegate = self
            picker.sourceType = .camera
            picker.mediaTypes = ["public.image"]
//            picker.mediaTypes = ["public.image", "public.movie"]
            picker.toolbar.tintColor = .systemGreen
            self.present(picker, animated: true)
            self.onImagePick = {info in
                guard let image = info[.editedImage] as? UIImage,
                      let imageData = image.jpegData(compressionQuality: 0.2) else { return }
                let imageId = "\(self.sender.displayName.replacingOccurrences(of: " ", with: "_"))_\(UUID().uuidString)"
                
                StorageManager.shared.uploadImageForComment(image: imageData, imageId: imageId, workout: self.workout) { [weak self] ref in
                    guard let self = self else {return}
                    if let safeRef = ref {
                        StorageManager.shared.downloadUrl(path: safeRef) { url in
                            guard let safeUrl = url else { print("unable to get safeURL")
                                return}
                            self.postPhotoComment(photoUrl: safeUrl)
                            print("Image is saved to Storage")
                        }
                    } else {
                        print ("Error uploading image to Storage")
                    }
                }
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] _ in
            guard let self = self else {return}
            let picker = UIImagePickerController()
            picker.allowsEditing = true
            picker.delegate = self
            picker.sourceType = .photoLibrary
            picker.mediaTypes = ["public.image"]
            
            self.present(picker, animated: true)
            self.onImagePick = {info in
                guard let image = info[.editedImage] as? UIImage,
                      let imageData = image.jpegData(compressionQuality: 0.5) else { return }
                let imageId = "\(self.sender.displayName.replacingOccurrences(of: " ", with: "_"))_\(UUID().uuidString)"
                
                StorageManager.shared.uploadImageForComment(image: imageData, imageId: imageId, workout: self.workout) { [weak self] ref in
                    guard let self = self else {return}
                    if let safeRef = ref {
                        StorageManager.shared.downloadUrl(path: safeRef) { url in
                            guard let safeUrl = url else { print("unable to get safeURL")
                                return}
                            self.postPhotoComment(photoUrl: safeUrl)
                            print("Image is saved to Storage")
                        }
                    } else {
                        print ("Error uploading image to Storage")
                    }
                }
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
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
                    print("couldn't get mediaURL from image picker")
                    return
                }
                let videoData = try! Data(contentsOf: videoUrl)
                
                let videoId = self.sender.displayName.replacingOccurrences(of: " ", with: "_") + (UUID().uuidString) + ".mov"
                StorageManager.shared.uploadVideoURLForComment(videoID: videoId, videoData: videoData, workout: self.workout, progressHandler: { [weak self] percentComplete in
                    self?.progressView.isHidden = false
                    self?.progressLabel.isHidden = false
                            self?.progressView.progress = percentComplete
                            self?.progressLabel.text = String(format: "Uploading video (%d%%)", Int(percentComplete * 100))
                        })  { [weak self] ref in
                    guard let self = self else { return }
                    if let safeRef = ref {
                        StorageManager.shared.downloadUrl(path: safeRef) { url in
                            guard let safeUrl = url else {
                                print("unable to get safeURL and download it")
                                return
                            }
                            self.postVideoComment(videoUrl: safeUrl)
                            print("Video is saved to Storage")
                        }
                    } else {
                        print("Error uploading video to Storage")
                    }
                    
                            self.progressView.isHidden = true
                            self.progressLabel.isHidden = true
                }
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Audio", style: .default, handler: {  _ in
            print ("to be implemented")
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
        guard let userImage = self.userImage else {return}
        let timestamp = Date().timeIntervalSince1970
        
        let newComment = Comment(sender: sender, messageId: messageId, sentDate: Date(), kind: .text(text), userImage: userImage, workoutId: workout.id, programId: workout.programID, timestamp: timestamp)
        
        DatabaseManager.shared.postComment(comment: newComment) { [weak self] success in
            guard let self = self else {return}
            if success {
                self.loadComments(workout: self.workout)
                print ("comments loaded")
            } else {
                print ("cant save comment")
            }
        }
        messageInputBar.inputTextView.text = nil
    }
    private func postPhotoComment(photoUrl: URL) {
        let senderName = sender.displayName.replacingOccurrences(of: " ", with: "_")
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "dd MM YYYY HH:mm:ss"
        let date = formatter.string(from: Date())
        let messageId = "\(senderName)_\(date)"
        //        let messageId = "\(UUID().uuidString)"
        guard let userImage = self.userImage else {return}
        let timestamp = Date().timeIntervalSince1970
        
        guard let placeholder = UIImage(systemName: "photo") else {return}
        let media = Media(url: photoUrl, image: placeholder, placeholderImage: placeholder, size: .zero)
        
        let newComment = Comment(sender: sender, messageId: messageId, sentDate: Date(), kind: .photo(media), userImage: userImage, workoutId: workout.id, programId: workout.programID, timestamp: timestamp)
        print ("new comment with photo is created and sent to the Firestore")
        DatabaseManager.shared.postComment(comment: newComment) { [weak self] success in
            guard let self = self else {return}
            if success {
                self.loadComments(workout: self.workout)
                print ("successfully load photo comment")
                self.messagesCollectionView.scrollToLastItem()
            } else {
                print ("cant save comment")
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
        guard let userImage = self.userImage else {return}
        let timestamp = Date().timeIntervalSince1970
        
        guard let placeholder = UIImage(systemName: "video.fill") else {return}
        let media = Media(url: videoUrl, image: placeholder, placeholderImage: placeholder, size: .zero)
        
        let newComment = Comment(sender: sender, messageId: messageId, sentDate: Date(), kind: .video(media), userImage: userImage, workoutId: workout.id, programId: workout.programID, timestamp: timestamp)
        print ("new comment with video is created and sent to the Firestore")
        DatabaseManager.shared.postComment(comment: newComment) { [weak self] success in
            guard let self = self else {return}
            if success {
                self.loadComments(workout: self.workout)
                print ("successfully upload video message ")
                self.messagesCollectionView.scrollToLastItem()
            } else {
                print ("cant save comment")
            }
        }
    }
    
    private func loadComments(workout: Workout) {
        DatabaseManager.shared.getAllComments(workout: workout) { [weak self] comments in
            guard let self = self else {return}
            self.commentsArray = comments
            print ("loaded \(self.commentsArray.count) comments")
            DispatchQueue.main.async {
                self.messagesCollectionView.reloadData()
            }
            
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
            if userName == selectedMessage.sender.displayName {
                let alertController = UIAlertController(title: "EDIT OR DELETE", message: "Please choose edit action, delete action, of cancel", preferredStyle: .actionSheet)
                
                let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] action in
                    guard let self = self else {return}
                    DatabaseManager.shared.deleteComment(comment: selectedMessage) { success in
                        if success {
                            DispatchQueue.main.async {
                                self.messagesCollectionView.reloadData()
                            }
                            print("comment is deleted")
                        } else {
                            print ("can not delete comment")
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
                            DatabaseManager.shared.updateComment(comment: selectedMessage, newDescription: text) { success in
                                if success{
                                    DispatchQueue.main.async {
                                        self.messagesCollectionView.reloadData()
                                        print("text comment is updated successfully")
                                    }
                                } else {
                                    self.showAlert(error: "Unable to update selected text comment")
                                }
                            }
                        }
                        
                    case .photo(_):
                        let picker = UIImagePickerController()
                        picker.allowsEditing = true
                        picker.delegate = self
                        picker.sourceType = .photoLibrary
                        picker.mediaTypes = ["public.image"]
                        picker.toolbar.tintColor = .systemGreen
                        self.present(picker, animated: true)
                        
                        self.onImagePick = { [weak self] info in
                            guard let self = self, let image = info[.editedImage] as? UIImage else { return }
                            guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
                            let imageId = "\(selectedMessage.messageId)_\(UUID().uuidString)"
                            
                            StorageManager.shared.uploadImageForComment(image: imageData, imageId: imageId, workout: self.workout) { [weak self] ref in
                                guard let self = self, let safeRef = ref else { return }
                                StorageManager.shared.downloadUrl(path: safeRef) { url in
                                    guard let safeUrl = url else {return}
                                    let mediaUrl = safeUrl.absoluteString
                                    DatabaseManager.shared.updateComment(comment: selectedMessage, newDescription: mediaUrl) { success in
                                        if success {
                                            DispatchQueue.main.async {
                                                self.messagesCollectionView.reloadData()
                                            }
                                            print("photo comment is updated successfully")
                                        } else {
                                            self.showAlert(error: "Unable to update selected photo comment")
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
                            
                            StorageManager.shared.uploadVideoURLForComment(videoID: videoId, videoData: videoData, workout: self.workout, progressHandler: { [weak self] percentComplete in
                                self?.progressView.isHidden = false
                                self?.progressLabel.isHidden = false
                                        self?.progressView.progress = percentComplete
                                        self?.progressLabel.text = String(format: "Uploading video (%d%%)", Int(percentComplete * 100))
                                    })  { [weak self] ref in
                                guard let self = self, let safeRef = ref else {return}
                                StorageManager.shared.downloadUrl(path: safeRef) { url in
                                    guard let safeUrl = url else { print("unable to get safeURL")
                                        return}
                                    let mediaUrl = safeUrl.absoluteString
                                    DatabaseManager.shared.updateComment(comment: selectedMessage, newDescription: mediaUrl) { success in
                                        if success {
                                            DispatchQueue.main.async {
                                                self.messagesCollectionView.reloadData()
                                            }
                                            print("video comment is updated successfully")
                                        } else {
                                            self.showAlert(error: "Unable to update selected video comment")
                                        }
                                    }
                                }
                                        self.progressView.isHidden = true
                                        self.progressLabel.isHidden = true
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
    
    private func showAlert (error: String) {
        let alert = UIAlertController(title: "Warning", message: error, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
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
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {return}
            imageView.sd_setImage(with: imageUrl)
            
        case .video(_):
            imageView.image = UIImage(named: "general")

        default: break
        }
    }
}

extension CommentsViewController: MessageCellDelegate {
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
        postComment(text: text)
    }
}

//MARK: - UIImagePickerControllerDelegate methods
extension CommentsViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.onImagePick?(info)
        picker.dismiss(animated: true)
    }
}



