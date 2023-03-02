//
//  SelectedWorkoutTableViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit

class SelectedWorkoutTableViewController: UITableViewController {
    
    private let workout: Workout
    private var commentsArray: [Comment] = []
    private let headerView = SelectedWorkoutHeaderView()
    
    var onCompletion: (() -> Void)?
    
    init(frame: CGRect , style: UITableView.Style, workout: Workout) {
        self.workout = workout
        super.init(style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupTableView()
        setupWorkoutData()
        saveComments()
        loadComments(for: workout.id)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DatabaseManager.shared.addNewCommentsListener(for: workout.id, program: workout.programID) {[weak self] comments in
            guard let self = self else {return}
            self.commentsArray = comments
            self.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DatabaseManager.shared.deleteListener()
    }
    
    //MARK: - Methods to setup Navigation Bar, TableView and load workout data
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "checkmark"), style: .plain, target: self, action: #selector(workoutDone))
        navigationItem.rightBarButtonItem?.tintColor = .white
    }
    
    private func setupTableView() {
        view.backgroundColor = UIColor(named: "darkGreen")
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.register(CommentTableViewCell.self, forCellReuseIdentifier: String(describing: CommentTableViewCell.self))
    }
    
    private func setupWorkoutData() {
        title = workout.date
        headerView.workoutDescriptionTextView.text = workout.description
    }
    //MARK: - Methods for saving new comments to Firestore and loading them to the local commentsArray
    
    private func saveComments() {
        headerView.onSendCommentPush = {[weak self] userName, userImage, text, date in
            guard let self = self else {return}
            let timestamp = Date().timeIntervalSince1970
            let commentID = UUID().uuidString
            let newComment = Comment(timeStamp: timestamp, userName: userName, userImage: userImage, date: date, text: text, id: commentID , workoutID: self.workout.id, programID: self.workout.programID)
            DatabaseManager.shared.addComment(comment: newComment, programID: self.workout.programID) { [weak self] success in
                guard let self = self else {return}
                if success {
                    print("comment is saved to database")
                    self.loadComments(for: self.workout.id)
                } else {
                    print ("cant save comment")
                }
            }
            self.headerView.commentTextView.text = ""
            self.tableView.reloadData()
        }
    }
    
    private func loadComments( for workoutID: String) {
        DatabaseManager.shared.getAllComments(for: workoutID, program: workout.programID) { [weak self] comments in
            guard let self = self else {return}
            self.commentsArray = comments
            print(self.commentsArray)
            print("this are all comments")
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    //TODO: - checkmark for the completed workout - now it is not associated with the particular workout and not stored anywhere
    
    @objc func workoutDone() {
        
        self.onCompletion?()
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table view data source methods
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        headerView.onTextChanged = {
            tableView.performBatchUpdates(nil, completion: nil)
        }
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: CommentTableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing: CommentTableViewCell.self), for: indexPath) as! CommentTableViewCell
        cell.comment = commentsArray[indexPath.row]
        cell.backgroundColor = UIColor(named: "darkGreen")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}

