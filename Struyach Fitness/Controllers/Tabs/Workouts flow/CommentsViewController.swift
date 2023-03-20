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

class CommentsViewController: MessagesViewController, UITextViewDelegate {
    
    let layout = UICollectionViewLayout()

    private lazy var messageCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: layout)
    private let workout: Workout
    var commentsArray: [Comment] = []
    private var commentsListener: ListenerRegistration?
    
    private let userName = UserDefaults.standard.string(forKey: "userName")
    private let userImage = UserDefaults.standard.data(forKey: "userImage")
    private let userEmail = UserDefaults.standard.string(forKey: "email")
       
    private lazy var sender = Sender(senderId: userEmail ?? "unknown email", displayName: userName ?? "unknown user")

    private let workoutView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = true
        textView.isUserInteractionEnabled = true
        textView.isEditable = false
        textView.layer.cornerRadius = 5
        textView.layer.shadowRadius = 5
        textView.layer.shadowOpacity = 0.7
        textView.layer.shadowColor = UIColor.black.cgColor
        textView.toAutoLayout()
        return textView
    }()

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
        setupNavbarAndView()
        loadComments(workout: self.workout)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        commentsListener = DatabaseManager.shared.addNewCommentsListener(workout: workout) {[weak self] comments in
            guard let self = self else {return}
            self.commentsArray = comments
            DispatchQueue.main.async {
                self.messagesCollectionView.reloadData()

            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        commentsListener?.remove()
    }
    
    private func setupMessageCollectionView () {
        messagesCollectionView.toAutoLayout()
        messagesCollectionView.backgroundColor = .customMediumGray
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.register(CommentCollectionViewCell.self, forCellWithReuseIdentifier: "customMessageCell")
        messageInputBar.delegate = self
        messageInputBar.inputTextView.delegate = self
        messageInputBar.inputTextView.becomeFirstResponder()
        messagesCollectionView.delegate = self
    }
    
    private func setupNavbarAndView() {
        title = "Comments"
        navigationController?.navigationBar.prefersLargeTitles = false
        self.view.backgroundColor = .customDarkGray
        workoutView.text = workout.description
        view.addSubviews(workoutView)

        let constraints = [
            workoutView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            workoutView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 10),
            workoutView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            workoutView.heightAnchor.constraint(equalToConstant: 150),
//
//            messagesCollectionView.topAnchor.constraint(equalTo: workoutView.bottomAnchor, constant: 10)
//            messagesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            messagesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            messagesCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func loadComments(workout: Workout) {

            DatabaseManager.shared.getAllComments(workout: workout) { [weak self] comments in
                guard let self = self else {return}
                self.commentsArray = comments
                self.messagesCollectionView.reloadData()
                print ("loaded \(self.commentsArray.count) comments")
                DispatchQueue.main.async {
                }
            }
        }
}

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
    
    
}

extension CommentsViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        print("executing \(#function)")
        guard let name = userName else {return}
        let messageId = " \(name)_\(Date())"
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
}
//MARK: - Methods for saving new comments to Firestore and loading them to the local commentsArray

//    private func addComment(workout: Workout, text: String) {
//        print("Executing function: \(#function)")
//        guard let userName = UserDefaults.standard.string(forKey: "userName"),
//              let userImage = UserDefaults.standard.data(forKey: "userImage") else {return}
//        let timestamp = Date().timeIntervalSince1970
//        let date = Date(timeIntervalSince1970: timestamp)
//        let formatter = DateFormatter()
//        formatter.dateFormat = "EE \n d MMMM \n yyyy"
//        let dateString = formatter.string(from: date)
//        let commentID = UUID().uuidString
//        let newComment = Comment(timeStamp: timestamp, userName: userName, userImage: userImage, date: dateString, text: text, id: commentID , workoutID: workout.id, programID: workout.programID)
//        DatabaseManager.shared.postComment(comment: newComment) { [weak self] success in
//            guard let self = self else {return}
//            if success {
//                self.imageRef = ""
//                self.loadComments(programID: workout.programID, workoutID: workout.id)
//                print ("comments without image loaded")
//            } else {
//                print ("cant save comment")
//            }
//        }
//    }

//    private func loadComments(programID: String, workoutID: String) {
//
//        DatabaseManager.shared.getAllComments(programID: programID, workoutID: workoutID) { [weak self] comments in
//            guard let self = self else {return}
//            self.commentsArray = comments
//            print ("loaded \(self.commentsArray.count) comments")
//            DispatchQueue.main.async {
//            }
//        }
//    }

//        commentsListener = DatabaseManager.shared.addNewCommentsListener(workout: selectedWorkout) {[weak self] comments in
//            guard let self = self else {return}
//            self.commentsArray = comments
//            DispatchQueue.main.async {
////                self.tableView.reloadData()
//                if let selectedIndexPath = self.selectedIndexPath {
//                    self.workoutsCollection.reloadItems(at: [selectedIndexPath])
//                }
//            }
//        }
