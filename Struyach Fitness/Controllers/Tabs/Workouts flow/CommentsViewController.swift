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

class CommentsViewController: MessagesViewController, UITextViewDelegate {

    private let workout: Workout
    var commentsArray: [Comment] = []
    private var commentsListener: ListenerRegistration?
    
    private let userName = UserDefaults.standard.string(forKey: "userName")
    private let userImage = UserDefaults.standard.data(forKey: "userImage")
    private let userEmail = UserDefaults.standard.string(forKey: "email")
    
    let workoutView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = true
        textView.isUserInteractionEnabled = true
        textView.isEditable = false
        textView.layer.cornerRadius = 10

        textView.toAutoLayout()
        return textView
    }()
    
    let containerView: UIView = {
        let view = UIView()
        view.toAutoLayout()
        view.backgroundColor = .customMediumGray
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
        loadComments(workout: self.workout)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        messagesCollectionView.backgroundColor = .customMediumGray
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
    
    private func presentInputOptions() {
        let actionSheet = UIAlertController(title: "Attach media", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] _ in
            self?.showImagePickerController()
        }))
//        actionSheet.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self] _ in
//            <#code#>
//        }))
//        actionSheet.addAction(UIAlertAction(title: "Audio", style: .default, handler: { [weak self] _ in
//            <#code#>
//        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(actionSheet, animated: true)
    }
    
    private func setupNavbarAndView() {
        title = "Comments"
        navigationController?.navigationBar.prefersLargeTitles = false
        self.view.backgroundColor = .customDarkGray

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
    
    //MARK: - Methods for saving new comments to Firestore and loading them to the local commentsArray
    
    private func postComment(text: String) {
        let senderName = sender.displayName.replacingOccurrences(of: " ", with: "_")
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "dd MM YYYY HH:mm:ss"
        let date = formatter.string(from: Date())
        let messageId = "\(senderName)_\(date)"
//        let messageId = "\(UUID().uuidString)"
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
                print ("successfully send photo message ")
            } else {
                print ("cant save comment")
            }
        }
        messageInputBar.inputTextView.text = nil
    }
    
    private func loadComments(workout: Workout) {
         DatabaseManager.shared.getAllComments(workout: workout) { [weak self] comments in
             guard let self = self else {return}
             self.commentsArray = comments
             print ("loaded \(self.commentsArray.count) comments")
                 self.messagesCollectionView.reloadData()
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
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {return}
            imageView.sd_setImage(with: imageUrl)
            
        default: break
        }
    }
//    func currentSender() -> SenderType {
//        return sender
//    }
//
//    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
//        let comment = commentsArray[indexPath.section]
//        return comment
//    }
//
//    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
//        return commentsArray.count
//    }
//
//    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//        let comment = commentsArray[indexPath.section]
//        let dateString = DateFormatter.localizedString(from: comment.sentDate, dateStyle: .medium, timeStyle: .short)
//        let senderName = comment.sender.displayName
//        let attributedString = NSAttributedString(string: "\(senderName) - \(dateString)", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)])
//        return attributedString
//    }
    
//    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//        return nil
//    }
//
//    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//        return nil
//    }
//
//    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//        return nil
//    }
//
//    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
//        let comment = commentsArray[indexPath.section]
//        if comment.sender.senderId == userEmail {
//            return .bubbleTail(.bottomRight, .curved)
//        } else {
//            return .bubbleTail(.bottomLeft, .curved)
//        }
//    }
//
//    func messageHeaderView(for indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageReusableView? {
//        return nil
//    }
//
//    func messageFooterView(for indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageReusableView? {
//        return nil
//    }
}

extension CommentsViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        print("executing \(#function)")
        postComment(text: text)
    }
}

//MARK: - UIImagePickerControllerDelegate methods
extension CommentsViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func showImagePickerController() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage,
        let imageData = image.jpegData(compressionQuality: 0.2) else { return }
//        let date = Date()
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy_MM_dd_HH_mm_ss"
//        let dateString = formatter.string(from: date)
        let imageId = "\(sender.displayName.replacingOccurrences(of: " ", with: "_"))_\(UUID().uuidString)"
        
        StorageManager.shared.uploadImageForComment(image: imageData, imageId: imageId, workout: workout) { [weak self] ref in
            guard let self = self else {return}
            if let safeRef = ref {
                StorageManager.shared.downloadUrlForCommentImage(path: safeRef) { url in
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
}



