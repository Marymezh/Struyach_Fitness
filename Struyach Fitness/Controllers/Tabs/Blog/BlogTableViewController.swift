//
//  BlogTableViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 5/4/23.
//

import UIKit
import FirebaseFirestore

class BlogTableViewController: UITableViewController {
    
    private var blogPosts: [Post] = []
    private var selectedPost: Post?
    private var likedPosts = UserDefaults.standard.array(forKey: "likedPosts") as? [String] ?? []
    private let pageSize = 10
    private var lastDocumentSnapshot: DocumentSnapshot? = nil
    private var isFetching = false
    private var shouldLoadMorePosts = true
    
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
        tabBarController?.tabBar.isHidden = false
        loadBlogPostsWithPagination(pageSize: pageSize)
    }
    
    private func setupTableView() {
        tableView.backgroundColor = .customDarkGray
        tableView.register(BlogTableViewCell.self, forCellReuseIdentifier: String(describing: BlogTableViewCell.self))
    }
    
    private func setupAdminFunctionality (){
        setupGestureRecognizer()
        navigationController?.navigationBar.tintColor = .systemGreen
        self.navigationItem.rightBarButtonItem =
            UIBarButtonItem(image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .medium)), style: .done, target: self, action: #selector(addNewPost))
    }
    
    @objc private func addNewPost() {
        print("Executing function: \(#function)")
        let newPostVC = CreateNewWorkoutViewController()
        newPostVC.title = "Add new post"
        tabBarController?.tabBar.isHidden = true
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
                self.blogPosts.insert(newPost, at: 0)
                self.tableView.reloadData()
                } else {
                    self.showAlert(title: "Warning", message: "Unable to add new post")
                }
            }
        }
    }
    
    private func loadBlogPostsWithPagination(pageSize: Int) {
        print ("executing function \(#function)")
        guard !isFetching else { return }
        isFetching = true
        DatabaseManager.shared.getBlogPostsWithPagination(pageSize: pageSize, startAfter: lastDocumentSnapshot) { [weak self] posts, lastDocumentSnapshot in
            guard let self = self else { return }
            if self.lastDocumentSnapshot == nil {
                // First page
                self.blogPosts = posts
            } else {
                // Subsequent pages
                self.blogPosts.append(contentsOf: posts)
            }
            self.lastDocumentSnapshot = lastDocumentSnapshot
            self.tableView.reloadData()
            self.isFetching = false
        }
    }
    
//    private func loadBlogPosts() {
//        DatabaseManager.shared.getAllPosts { [weak self] posts in
//            print("Executing function: \(#function)")
//            guard let self = self else {return}
//            self.blogPosts = posts
//            self.tableView.reloadData()
//        }
//    }
    
    private func setupGestureRecognizer() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        tableView.addGestureRecognizer(longPressRecognizer)
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: touchPoint) {
            let alertController = UIAlertController(title: "EDIT OR DELETE", message: "Please choose edit action, delete action, of cancel", preferredStyle: .actionSheet)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] action in
                guard let self = self else { return }
                let post = self.blogPosts[indexPath.item]
                DatabaseManager.shared.deletePost(blogPost: post) { [weak self] success in
                    guard let self = self else { return }
                    if success {
                        self.blogPosts.remove(at: indexPath.row)
                        self.tableView.reloadData()
                        print ("number of posts left - \(self.blogPosts.count)")
                        self.showAlert(title: "Success", message: "Post is successfully deleted!")
                    } else {
                        self.showAlert(title: "Warning", message: "Unable to delete selected post")
                    }
                }
            }
            let editAction = UIAlertAction(title: "Edit", style: .default) { [weak self] action in
                guard let self = self else {return}
                let workoutVC = CreateNewWorkoutViewController()
                workoutVC.title = "Edit post"
                let selectedPost = self.blogPosts[indexPath.item]
                workoutVC.text = selectedPost.description
                self.navigationController?.pushViewController(workoutVC, animated: true)
                workoutVC.onWorkoutSave = {[weak self] text in
                    guard let self = self else {return}
                    DatabaseManager.shared.updatePost(blogPost: selectedPost, newDescription: text) { [weak self] post in
                        guard let self = self else {return}
                        guard let index = self.blogPosts.firstIndex(where: {$0 == selectedPost}) else {return}
                        self.blogPosts[index] = post
                        DispatchQueue.main.async {
                            if let cell = self.tableView.cellForRow(at: indexPath) as? BlogTableViewCell {
                                cell.postDescriptionTextView.text = text
                            }
                        }
                        self.showAlert(title: "Success", message: "Post is successfully updated!")
                    }
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

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        alert.view.tintColor = .systemGreen
        self.present(alert, animated: true, completion: nil)
    }
    
    private func hasUserLikedPost(blogPost: Post) -> Bool {
        return self.likedPosts.contains(blogPost.id)
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
        var post = blogPosts[indexPath.row]

        cell.postDateLabel.text = post.date
        cell.likesLabel.text = "\(post.likes)"
        cell.postDescriptionTextView.text = post.description
        
        if hasUserLikedPost(blogPost: post) == true {
            cell.likeButton.isSelected = true
            cell.likeButton.setImage(UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
            cell.likeButton.tintColor = .systemRed
        } else {
            cell.likeButton.isSelected = false
            cell.likeButton.setImage(UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
            cell.likeButton.tintColor = .white
        }
        
        cell.onLikeButtonPush = {
            cell.likeButton.isSelected = !cell.likeButton.isSelected
            
            if cell.likeButton.isSelected {
                cell.likeButton.setImage(UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
                cell.likeButton.tintColor = .systemRed
                post.likes += 1
                DatabaseManager.shared.updateBlogLikes(blogPost: post, likesCount: post.likes) {[weak self] blogPost in
                    guard let self = self else {return}
                    print ("likes increase by 1")
                    cell.likesLabel.text = "\(blogPost.likes)"
                    post = blogPost
                    if !self.likedPosts.contains(post.id) {
                        self.likedPosts.append(post.id)
                        UserDefaults.standard.set(self.likedPosts, forKey: "likedPosts")
                    }
                }
            } else {
                cell.likeButton.setImage(UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
                cell.likeButton.tintColor = .white
                post.likes -= 1
                DatabaseManager.shared.updateBlogLikes(blogPost: post, likesCount: post.likes) {[weak self] blogPost in
                    guard let self = self else {return}
                    print ("likes decrease by 1")
                    
                    cell.likesLabel.text = "\(blogPost.likes)"
                    post = blogPost
                    if let index = self.likedPosts.firstIndex(of: post.id) {
                        self.likedPosts.remove(at: index)
                        UserDefaults.standard.set(self.likedPosts, forKey: "likedPosts")
                    }
                }
            }
        }
        
        cell.onCommentsPush = {
            let commentsVC = CommentsViewController(blogPost: post)
            commentsVC.title = "Comments"
            self.tabBarController?.tabBar.isHidden = true
            self.navigationController?.pushViewController(commentsVC, animated: true)
        }
        
        DatabaseManager.shared.getBlogCommentsCount(blogPost: post) { numberOfComments in
            DispatchQueue.main.async {
                switch numberOfComments {
                case 0: cell.commentsLabel.text = "No comments posted yet"
                case 1: cell.commentsLabel.text = "\(numberOfComments) comment "
                default: cell.commentsLabel.text = "\(numberOfComments) comments"
                }
                UIView.animate(withDuration: 0.3) {
                            cell.commentsLabel.alpha = 1
                        }
            }
        }
        return cell
    }
    
//    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//           // Check if table view is near bottom and not currently loading
//           let scrollViewHeight = scrollView.frame.size.height
//           let scrollContentSizeHeight = scrollView.contentSize.height
//           let scrollOffset = scrollView.contentOffset.y
//
//           if (scrollOffset + scrollViewHeight) >= (scrollContentSizeHeight - 50) && !isFetching {
//               // Load more blogs from Firestore
//               self.loadBlogPostsWithPagination(pageSize: pageSize)
//           }
//       }
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Check if table view is near bottom and not currently loading
        let scrollViewHeight = scrollView.frame.size.height
        let scrollContentSizeHeight = scrollView.contentSize.height
        let scrollOffset = scrollView.contentOffset.y

        if (scrollOffset + scrollViewHeight) >= (scrollContentSizeHeight - 50) && !isFetching && shouldLoadMorePosts {
            // Load more blogs from Firestore
            if !DatabaseManager.shared.allPostsLoaded {
                self.loadBlogPostsWithPagination(pageSize: pageSize)
            } else {
                shouldLoadMorePosts = false
                print("All posts have been loaded")
                self.tableView.tableFooterView = nil
                self.tableView.reloadData()
                scrollView.delegate = nil
            }
        }
    }
}
