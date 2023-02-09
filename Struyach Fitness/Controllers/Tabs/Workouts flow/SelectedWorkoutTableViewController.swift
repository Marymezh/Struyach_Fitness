//
//  SelectedWorkoutTableViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit

class SelectedWorkoutTableViewController: UITableViewController {

    private var commentsArray: [Comment] = [
        Comment(date: "04 февр. 2023", text: "Great workout, finished in 10:35 min"),
        Comment(date: "05 февр. 2023", text: "It was too hard for me, only 3 rounds completed")]
    
  let headerView = SelectedWorkoutHeaderView()
    
    var onCompletion: (() -> Void)?
    
    init(frame: CGRect , style: UITableView.Style) {
        super.init(style: style)
        
        view.backgroundColor = UIColor(named: "darkGreen")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "checkmark"), style: .plain, target: self, action: #selector(workoutDone))
        navigationItem.rightBarButtonItem?.tintColor = .white
        
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.register(CommentTableViewCell.self, forCellReuseIdentifier: String(describing: CommentTableViewCell.self))
        
        headerView.onSendCommentPush = { text, date in
            self.commentsArray.insert(Comment(date: date, text: text), at: 0)
            
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
 //       cell.commentTextLabel.text = commentsArray[indexPath.row].text
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}

