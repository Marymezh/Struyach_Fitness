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

class CommentsViewController: MessagesViewController {

    private let workout: Workout
    private var commentsArray: [Comment] = []
    private var commentsListener: ListenerRegistration?
    
    let userImage = UserDefaults.standard.data(forKey: "userImage")
    let userName = UserDefaults.standard.string(forKey: "userName")

    let sender = Sender(senderImage: "image", senderId: UUID().uuidString, displayName: "Maria Mezhova")
    
    
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
        setupNavbarAndView()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        messageInputBar.backgroundView.backgroundColor = .customMediumGray
        messageInputBar.tintColor = .white
        messageInputBar.inputTextView.tintColor = .white
        messageInputBar.inputTextView.textColor = .white 
        messageInputBar.inputTextView.becomeFirstResponder()
        loadComments()

    }
    
    func loadComments() {
        commentsArray.append(Comment(sender: sender, messageId: UUID().uuidString, sentDate: Date(), kind: .text("test comment")))
        commentsArray.append(Comment(sender: sender, messageId: UUID().uuidString, sentDate: Date(), kind: .text("test comment, testing the test, looking how it will look like")))
        commentsArray.append(Comment(sender: sender, messageId: UUID().uuidString, sentDate: Date(), kind: .text("hello world, hello world, hello world, hello world, hello world, hello world, hello world, hello world, hello world, hello world, hello world, hello world, hello world, hello world, hello world, ")))
        messagesCollectionView.reloadData()
    }
    
    private func setupNavbarAndView() {
        title = "Comments"
        navigationController?.navigationBar.prefersLargeTitles = false
        messagesCollectionView.backgroundColor = .customMediumGray
    }
}

extension CommentsViewController: MessagesDataSource, MessagesDisplayDelegate, MessagesLayoutDelegate {
    var currentSender: SenderType {
        sender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        commentsArray[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        commentsArray.count
    }
    

}

extension CommentsViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let newComment = Comment(sender: sender, messageId: "test", sentDate: Date(), kind: .text(text))
        commentsArray.append(newComment)
        messagesCollectionView.reloadData()
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
