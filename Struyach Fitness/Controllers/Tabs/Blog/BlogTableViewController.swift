//
//  BlogTableViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 5/4/23.
//

import UIKit

class BlogTableViewController: UITableViewController {
    
    private var blogPosts: [Post] = []
    private var selectedPost: Post?
    
   
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
#if Admin
        setupAdminFunctionality()
#endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        loadBlogPosts()
    }
    
    private func setupTableView() {
        tableView.backgroundColor = .customDarkGray
        tableView.register(BlogTableViewCell.self, forCellReuseIdentifier: String(describing: BlogTableViewCell.self))
    }
    
    private func setupAdminFunctionality (){
        navigationController?.navigationBar.tintColor = .systemGreen
        self.navigationItem.rightBarButtonItem =
            UIBarButtonItem(image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .medium)), style: .done, target: self, action: #selector(addNewPost))
    }
    
    @objc private func addNewPost() {
        print("Executing function: \(#function)")
        let newPostVC = CreateNewWorkoutViewController()
        newPostVC.title = "Add new post"
        navigationController?.pushViewController(newPostVC, animated: true)
        newPostVC.onWorkoutSave = {[weak self] text in
            let timestamp = Date().timeIntervalSince1970
            let date = Date(timeIntervalSince1970: timestamp)
            let formatter = DateFormatter()
            formatter.dateFormat = "EE d MMMM yyyy"
            let dateString = formatter.string(from: date)
            let postID = dateString.replacingOccurrences(of: " ", with: "_") + (UUID().uuidString)
            let newPost = Post(id: postID, description: text, date: dateString, timestamp: timestamp)
            DatabaseManager.shared.saveBlogPost(with: newPost) {[weak self] success in
                print("Executing function: \(#function)")
                guard let self = self else {return}
                if success {
                    print("post is added to database - \(newPost)")
                } else {
                    self.showAlert(error: "Unable to add new post")
                }
            }
        }
    }
    
    private func loadBlogPosts() {
       
        DatabaseManager.shared.getAllPosts { [weak self] posts in
            print("Executing function: \(#function)")
            guard let self = self else {return}
            self.blogPosts = posts
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func showAlert (error: String) {
        let alert = UIAlertController(title: "Warning", message: error, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return blogPosts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: BlogTableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing: BlogTableViewCell.self), for: indexPath) as! BlogTableViewCell
        let post = blogPosts[indexPath.row]
            cell.postDescriptionTextView.text = post.description
            cell.postDateLabel.text = post.date
        
        cell.onCommentsPush = {
            let commentsVC = CommentsViewController(blogPost: post)
            commentsVC.title = "Comments"
            self.navigationController?.pushViewController(commentsVC, animated: true)
        }
        
        DatabaseManager.shared.getBlogCommentsCount(blogPost: post) { numberOfComments in
            DispatchQueue.main.async {
                switch numberOfComments {
                case 0: cell.commentsLabel.text = "No comments posted yet"
                case 1: cell.commentsLabel.text = "\(numberOfComments) comment "
                default: cell.commentsLabel.text = "\(numberOfComments) comments"
                }
            }
        }
        
        return cell
    }
    

  
}
