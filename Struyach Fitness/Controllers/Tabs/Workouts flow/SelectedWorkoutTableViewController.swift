//
//  SelectedWorkoutTableViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit

class SelectedWorkoutTableViewController: UITableViewController {

    private var commentsArray: [Comment] = []
    
  let headerView = SelectedWorkoutHeaderView()

    var workoutID: String = ""
    var onCompletion: (() -> Void)?
    
    init(frame: CGRect , style: UITableView.Style) {
        super.init(style: style)
        
        view.backgroundColor = UIColor(named: "darkGreen")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "checkmark"), style: .plain, target: self, action: #selector(workoutDone))
        navigationItem.rightBarButtonItem?.tintColor = .white
        
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.register(CommentTableViewCell.self, forCellReuseIdentifier: String(describing: CommentTableViewCell.self))
        
        headerView.onSendCommentPush = {userName, userImage, text, date in
            let commentID = UUID().uuidString
           
            let newComment = Comment(userName: userName, userImage: userImage, id: commentID , workoutID: self.workoutID, date: date, text: text)
            self.commentsArray.insert(newComment, at: 0)
            DatabaseManager.shared.addComment(comment: newComment) { success in
                if success {
                    print ("comment is saved")
                } else {
                    print ("cant save comment")
                }
            }
            self.headerView.commentTextView.text = ""
            self.tableView.reloadData()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func workoutDone() {
        
        self.onCompletion?()
        navigationController?.popViewController(animated: true)
    }

// MARK: - Table view data source
    
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

