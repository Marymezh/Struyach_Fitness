//
//  DatabaseManager.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseMessaging
import UIKit
import MessageKit

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    private let database = Firestore.firestore()
    var allPostsLoaded = false
    var allWorkoutsLoaded = false
  
    private init() {}
    
    //MARK: - Workouts: adding, fetching, editing, deleting workouts and listen to the changes
    
    public func postWorkout(with workout: Workout, completion: @escaping(Bool) ->()){
        print("Executing function: \(#function)")
        let program = workout.programID
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: " ", with: "_")
        
        do {
            let workoutData = try Firestore.Encoder().encode(workout)
            database
                .collection("programs")
                .document(program)
                .collection("workouts")
                .document(workout.id)
                .setData(workoutData) { error in
                    if let error = error {
                        print ("Error posting new workout \(error.localizedDescription)")
                    } else {
                        print("workout posted")
                    }
                }
        } catch {
            print("Error encoding workout: \(error)")
            completion(false)
        }
    }
    

    
    public func getWorkoutsWithPagination(program: String, pageSize: Int, startAfter: DocumentSnapshot? = nil, completion: @escaping ([Workout], DocumentSnapshot?) -> ()) {
        print("Executing function: \(#function)")
        let documentID = program
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: " ", with: "_")
  
        var query = database
            .collection("programs")
            .document(documentID)
            .collection("workouts")
            .order(by: "timestamp", descending: true)
            .limit(to: pageSize)
        if let startAfter = startAfter {
            query = query.start(afterDocument: startAfter)
        }
        
        query.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            var lastDocumentSnapshot: DocumentSnapshot?
            let workouts: [Workout] = documents.compactMap { document in
                do {
                    let workout = try Firestore.Decoder().decode(Workout.self, from: document.data())
                    lastDocumentSnapshot = document
                    return workout
                } catch {
                    print("Error decoding workout: \(error)")
                    return nil
                }
            }
            
            if documents.count < pageSize {
                self.allWorkoutsLoaded = true
                print ("all posts have been loaded from Firestore")
            }
            
            completion(workouts, lastDocumentSnapshot)
            print ("downloaded \(workouts.count) workouts")
        }
    }
    
    public func searchWorkoutsByDescription(program: String, searchText: String, completion: @escaping([Workout])->()){
        print("Executing function: \(#function)")
        
        let documentID = program
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: " ", with: "_")
        
        let workoutsRef = database
            .collection("programs")
            .document(documentID)
            .collection("workouts")
            
        let query = workoutsRef
            .whereField("description", isGreaterThanOrEqualTo: searchText)
            .whereField("description", isLessThanOrEqualTo: searchText + "\u{f8ff}")

            query.getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }

                let workouts: [Workout] = documents.compactMap { document in
                    do {
                        let workout = try Firestore.Decoder().decode(Workout.self, from: document.data())
                        print("workouts decoded from database")
                        return workout
                    } catch {
                        print("Error decoding workout: \(error)")
                        return nil
                    }
                }
                completion(workouts)
            }
    }
    
    public func updateWorkout(workout: Workout, newDescription: String, completion: @escaping (Workout)->()){
        print("Executing function: \(#function)")
        let documentID = workout.programID
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: " ", with: "_")
        
        let dbRef = database
            .collection("programs")
            .document(documentID)
            .collection("workouts")
            .document(workout.id)
        dbRef.updateData(["description": newDescription]) { error in
            if error == nil {
                var updatedWorkout = workout
                updatedWorkout.description = newDescription
                completion(updatedWorkout)
            }
        }
    }
    
    public func deleteWorkout(workout: Workout, completion: @escaping (Bool)->()){
        print("Executing function: \(#function)")
        
        let documentID = workout.programID
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: " ", with: "_")
        
        let commentsRef = database
            .collection("programs")
            .document(documentID)
            .collection("workouts")
            .document(workout.id)
            .collection("comments")
        
        commentsRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting comments: \(error.localizedDescription)")
                completion(false)
                return
            }
            guard let snapshot = snapshot else {
                print("No comments found")
                completion(false)
                return
            }
            let batch = self.database.batch()
            snapshot.documents.forEach { batch.deleteDocument($0.reference) }
            batch.commit { (error) in
                if let error = error {
                    print("Error deleting comments: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Comments deleted successfully")
                    self.database
                        .collection("programs")
                        .document(documentID)
                        .collection("workouts")
                        .document(workout.id)
                        .delete() { error in
                            if let error = error {
                                print("Error deleting workout: \(error.localizedDescription)")
                                completion(false)
                            } else {
                                print("Workout deleted successfully")
                                completion(true)
                            }
                        }
                }
            }
        }
    }
    
    public func updateLikes(workout: Workout, likesCount: Int, completion: @escaping (Workout)->()){
        print("Executing function: \(#function)")
        let documentID = workout.programID
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: " ", with: "_")
        
        let dbRef = database
            .collection("programs")
            .document(documentID)
            .collection("workouts")
            .document(workout.id)
        
        dbRef.updateData(["likes": likesCount]) { error in
            if error == nil {
                var updatedWorkout = workout
                updatedWorkout.likes = likesCount
                completion(updatedWorkout)
            }
        }
    }

    public func addWorkoutsListener(for programName: String, completion: @escaping ([Workout]) -> ()) -> ListenerRegistration? {
        print("Executing function: \(#function)")

        let documentID = programName
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: " ", with: "_")

        let workoutsListener = database
            .collection("programs")
            .document(documentID)
            .collection("workouts")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error fetching workouts: \(error?.localizedDescription ?? "unknown error")")
                return
            }
                
                do {
                let workouts = try snapshot.documents.compactMap { document -> Workout? in
                    let workout = try document.data(as: Workout.self)
                    return workout
                }
                completion(workouts)
            } catch {
                print("Error decoding workouts: \(error.localizedDescription)")
            }
        }
        return workoutsListener
    }
    
    //MARK: - Blog posts: adding, fetching, updating and deleting
    public func saveBlogPost(with post: Post, completion: @escaping(Bool) ->()){
        print("Executing function: \(#function)")

        do {
            let blogPostData = try Firestore.Encoder().encode(post)
            database
                .collection("blogPosts")
                .document(post.id)
                .setData(blogPostData) { error in
                    completion(error == nil)
                }
        } catch {
            print("Error encoding workout: \(error)")
            completion(false)
        }
    }
    
    public func getBlogPostsWithPagination(pageSize: Int, startAfter: DocumentSnapshot? = nil, completion: @escaping ([Post], DocumentSnapshot?) -> ()) {
        var query = database
            .collection("blogPosts")
            .order(by: "timestamp", descending: true)
            .limit(to: pageSize)
        if let startAfter = startAfter {
            query = query.start(afterDocument: startAfter)
        }
        
        query.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            var lastDocumentSnapshot: DocumentSnapshot?
            let posts: [Post] = documents.compactMap { document in
                do {
                    let post = try Firestore.Decoder().decode(Post.self, from: document.data())
                    lastDocumentSnapshot = document
                    return post
                } catch {
                    print("Error decoding post: \(error)")
                    return nil
                }
            }
            
            if documents.count < pageSize {
                self.allPostsLoaded = true
                print ("all posts have been loaded from Firestore")
            }
            
            completion(posts, lastDocumentSnapshot)
            print ("downloaded \(posts.count) posts")
        }
    }


    public func updatePost(blogPost: Post, newDescription: String, completion: @escaping (Post)->()){
        print("Executing function: \(#function)")

        let dbRef = database
            .collection("blogPosts")
            .document(blogPost.id)
        
        dbRef.updateData(["description": newDescription]) { error in
            if error == nil {
                var updatedPost = blogPost
                updatedPost.description = newDescription
                completion(updatedPost)
            }
        }
    }
 
    public func deletePost(blogPost: Post, completion: @escaping (Bool)->()){
        print("Executing function: \(#function)")
        
        let commentsRef = database
            .collection("blogPosts")
            .document(blogPost.id)
            .collection("comments")
        
        commentsRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting comments: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let snapshot = snapshot else {
                print("No comments found")
                completion(false)
                return
            }
            let batch = self.database.batch()
            snapshot.documents.forEach { batch.deleteDocument($0.reference) }
            batch.commit { (error) in
                if let error = error {
                    print("Error deleting comments: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Comments deleted successfully")
                    self.database
                        .collection("blogPosts")
                        .document(blogPost.id)
                        .delete() { error in
                            if let error = error {
                                print("Error deleting post: \(error.localizedDescription)")
                                completion(false)
                            } else {
                                print("Post deleted successfully")
                                completion(true)
                            }
                        }
                }
            }
        }
    }
    
    public func updateBlogLikes(blogPost: Post, likesCount: Int, completion: @escaping (Post)->()){
        print("Executing function: \(#function)")
  
        let dbRef = database
            .collection("blogPosts")
            .document(blogPost.id)
        
        dbRef.updateData(["likes": likesCount]) { error in
            if error == nil {
                var updatedPost = blogPost
                updatedPost.likes = likesCount
                completion(updatedPost)
            }
        }
    }
    
    public func addBlogPostsListener(completion: @escaping ([Post]) -> ()) -> ListenerRegistration? {
        print("Executing function: \(#function)")

        let postsListener = database
            .collection("blogPosts")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error fetching workouts: \(error?.localizedDescription ?? "unknown error")")
                return
            }
            do {
                let posts = try snapshot.documents.compactMap { document -> Post? in
                    let post = try document.data(as: Post.self)
                    return post
                }
                completion(posts)
            } catch {
                print("Error decoding workouts: \(error.localizedDescription)")
            }
        }
        return postsListener
    }
    
    //MARK: - Comments for blog posts: Adding, fetching, editing, deleting and listen to the changes
    public func postBlogComment(comment: Comment, post: Post, completion: @escaping (Bool) ->()){
        print("posting comment for blog post to Firestore")
        var commentContents = ""

        switch comment.kind {
        case .text(let enteredText): commentContents = enteredText
        case .photo(let mediaItem):
            if let mediaUrl = mediaItem.url?.absoluteString {
                    commentContents = mediaUrl
                print(mediaUrl)
            }
        case .video(let mediaItem):
            if let mediaUrl = mediaItem.url?.absoluteString {
                commentContents = mediaUrl
            }
        default: break
        }

        let commentData: [String: Any] = [
            "senderId": comment.sender.senderId,
            "senderName": comment.sender.displayName,
            "messageId": comment.messageId,
            "sentDate": FieldValue.serverTimestamp(),
            "contents": commentContents,
            "type": comment.kind.messageKindString,

            "userImage": comment.userImage,
            "programId": comment.programId ?? "",
            "workoutId": comment.workoutId ?? "",
            "mediaRef": comment.mediaRef ?? ""
        ]

           database
               .collection("blogPosts")
               .document(post.id)
               .collection("comments")
               .document(comment.messageId)
               .setData(commentData) { error in
                   if let error = error {
                       print(error.localizedDescription)
                   } else {
                       completion(error == nil)
                   }
               }
       }

    public func getAllBlogComments(blogPost: Post, completion: @escaping([Comment])->()){
        print ("executing loading comments from database \(#function)")
        
        database
            .collection("blogPosts")
            .document(blogPost.id)
            .collection("comments")
            .order(by: "sentDate", descending: false)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents.compactMap({ $0.data()}), error == nil else {return}
                let comments: [Comment] = documents.compactMap { dictionary in
                    guard let senderId = dictionary["senderId"] as? String,
                          let senderName = dictionary["senderName"] as? String,
                          let userImage = dictionary["userImage"] as? Data,
                          let messageId = dictionary["messageId"] as? String,
                          let contents = dictionary["contents"] as? String,
                          let type = dictionary["type"] as? String,
                          let date = dictionary["sentDate"] as? Timestamp,
                          let workoutId = dictionary["workoutId"] as? String,
                          let programId = dictionary["programId"] as? String,
                          let mediaRef = dictionary["mediaRef"] as? String else {print("unable to create comment")
                        return nil}
                    
                    let sentDate = date.dateValue()
                    var kind: MessageKind?
                    
                    switch type {
                    case "photo":
                        guard let imageURL = URL(string: contents),
                        let placeholder = UIImage(systemName: "photo") else {return nil}
                        let media = Media(url: imageURL, image: nil, placeholderImage: placeholder, size: CGSize(width: 300, height: 250))
                        kind = .photo(media)
                    case "video":
                        guard let videoUrl = URL(string: contents),
                        let placeholder = UIImage(named: "general") else {return nil}
                        let media = Media(url: videoUrl, image: nil, placeholderImage: placeholder, size: CGSize(width: 90, height: 90))
                        kind = .video(media)
                    case "text": kind = .text(contents)
                    default: break
                    }

                    guard let finalKind = kind else {return nil}
                    let sender = Sender(senderId: senderId, displayName: senderName)
                    let comment = Comment(sender: sender, messageId: messageId, sentDate: sentDate, kind: finalKind, userImage: userImage, workoutId: workoutId, programId: programId, mediaRef: mediaRef)
                    return comment
                }
                   completion(comments)
               }
       }
    
    public func getBlogCommentsCount(blogPost: Post, completion: @escaping(Int)->()){
        var numberOfComments = 0
        database
            .collection("blogPosts")
            .document(blogPost.id)
            .collection("comments")
            .order(by: "sentDate", descending: false)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    numberOfComments = querySnapshot?.count ?? 0
                }
                completion(numberOfComments)
            }
       }
    
    public func updateBlogCommentsCount(blogPost: Post, commentsCount: Int, completion: @escaping (Post)->()){
        print("Executing function: \(#function)")
        
        let dbRef = database
            .collection("blogPosts")
            .document(blogPost.id)
        
        dbRef.updateData(["comments": commentsCount]) { error in
            if error == nil {
                var updatedPost = blogPost
                updatedPost.comments = commentsCount
                completion(updatedPost)
            }
        }
    }
    
    public func updateBlogComment(comment: Comment, blogPost: Post, newDescription: String, newMediaRef: String?, completion: @escaping (Bool)->()){
        print("Executing function: \(#function)")

        let dbRef = database
            .collection("blogPosts")
            .document(blogPost.id)
            .collection("comments")
            .document(comment.messageId)
        
        dbRef.getDocument { snapshot, error in
            guard var data = snapshot?.data(), error == nil else {return}
            
            data["contents"] = newDescription
            data["mediaRef"] = newMediaRef ?? ""
            dbRef.setData(data) { error in
                completion(error == nil)
            }
        }
    }
    
    public func deleteBlogComment(comment: Comment, blogPost: Post, completion: @escaping (Bool)->()){
        print("Executing function: \(#function)")
        
        
        let commentsRef = database
            .collection("blogPosts")
            .document(blogPost.id)
            .collection("comments")
            .document(comment.messageId)
        
        commentsRef.delete() { error in
            if let error = error {
                print("Error deleting comment: \(error.localizedDescription)")
                completion(false)
            } else {
                print("comment deleted successfully")
                completion(true)
            }
        }
    }
    
    public func deleteAllBlogCommentsForUser(userId: String, completion: @escaping ((Bool)-> Void)) {
        let db = Firestore.firestore()
       
        db.collection("blogPosts").getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else {
                print("Error retrieving blog posts: \(error?.localizedDescription ?? "Unknown error")")
                completion(false)
                return
            }
            
            let dispatchGroup = DispatchGroup()
            
            for document in documents {
                let postId = document.documentID
                
                let commentsCollection = db.collection("blogPosts").document(postId).collection("comments")
                let query = commentsCollection.whereField("senderId", isEqualTo: userId)
                
                dispatchGroup.enter()
                
                query.getDocuments { (snapshot, error) in
                    guard let documents = snapshot?.documents else {
                        print("Error retrieving comments for post \(postId): \(error?.localizedDescription ?? "Unknown error")")
                        dispatchGroup.leave()
                        completion(false)
                        return
                    }
                   
                    let batch = db.batch()
                    
                    for document in documents {
                        let commentId = document.documentID
                        let commentRef = commentsCollection.document(commentId)
                        
                        batch.deleteDocument(commentRef)
                    }
               
                    batch.commit { (error) in
                        if let error = error {
                            print("Error deleting comments for post \(postId): \(error.localizedDescription)")
                            completion(false)
                        } else {
                            print("Comments deleted successfully for post \(postId)")
                        }
                        
                        dispatchGroup.leave()
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                completion(true)
                print("Deletion of comments for user \(userId) completed")
            }
        }
    }
    
    //MARK: - Comments for workouts: Adding, fetching, editing, deleting and listen to the changes 
    public func postComment(comment: Comment, completion: @escaping (Bool) ->()){
        print("posting comment to Firestore")
        guard let programId = comment.programId, let workoutId = comment.workoutId else {return}

           let documentID = programId
               .replacingOccurrences(of: "/", with: "_")
               .replacingOccurrences(of: " ", with: "_")

        var commentContents = ""

        switch comment.kind {
        case .text(let enteredText): commentContents = enteredText
           
        case .photo(let mediaItem):
            if let mediaUrl = mediaItem.url?.absoluteString {
                    commentContents = mediaUrl
                print(mediaUrl)
            }
        case .video(let mediaItem):
            if let mediaUrl = mediaItem.url?.absoluteString {
                commentContents = mediaUrl
            }
        default: break
        }

        let commentData: [String: Any] = [
            "senderId": comment.sender.senderId,
            "senderName": comment.sender.displayName,
            "messageId": comment.messageId,
            "sentDate": FieldValue.serverTimestamp(),
            "contents": commentContents,
            "type": comment.kind.messageKindString, 

            "userImage": comment.userImage,
            "programId": comment.programId ?? "",
            "workoutId": comment.workoutId ?? "",
            "mediaRef": comment.mediaRef ?? ""
            
        ]

           database
               .collection("programs")
               .document(documentID)
               .collection("workouts")
               .document(workoutId)
               .collection("comments")
               .document(comment.messageId)
               .setData(commentData) { error in
                   if let error = error {
                       print(error.localizedDescription)
                   } else {
                       completion(error == nil)
                   }
               }
       }

    public func getAllComments(workout: Workout, completion: @escaping([Comment])->()){
        print ("executing loading comments from database \(#function)")

        let documentID = workout.programID
               .replacingOccurrences(of: "/", with: "_")
               .replacingOccurrences(of: " ", with: "_")

        database
            .collection("programs")
            .document(documentID)
            .collection("workouts")
            .document(workout.id)
            .collection("comments")
            .order(by: "sentDate", descending: false)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents.compactMap({ $0.data()}), error == nil else {return}
                let comments: [Comment] = documents.compactMap { dictionary in
                    guard let senderId = dictionary["senderId"] as? String,
                          let senderName = dictionary["senderName"] as? String,
                          let userImage = dictionary["userImage"] as? Data,
                          let messageId = dictionary["messageId"] as? String,
                          let contents = dictionary["contents"] as? String,
                          let type = dictionary["type"] as? String,
                          let date = dictionary["sentDate"] as? Timestamp,
                          let workoutId = dictionary["workoutId"] as? String,
                          let programId = dictionary["programId"] as? String,
                    let mediaRef = dictionary["mediaRef"] as? String else {print("unable to create comment")
                        return nil}
                    
                    let sentDate = date.dateValue()
                    
                    var kind: MessageKind?
                    
                    switch type {
                    case "photo":
                        guard let imageURL = URL(string: contents),
                        let placeholder = UIImage(systemName: "photo") else {return nil}
                        let media = Media(url: imageURL, image: nil, placeholderImage: placeholder, size: CGSize(width: 300, height: 250))
                        kind = .photo(media)
                    case "video":
                        guard let videoUrl = URL(string: contents),
                        let placeholder = UIImage(named: "general") else {return nil}
                        let media = Media(url: videoUrl, image: nil, placeholderImage: placeholder, size: CGSize(width: 90, height: 90))
                        kind = .video(media)
                    case "text": kind = .text(contents)
                    default: break
                    }

                    guard let finalKind = kind else {return nil}
                    let sender = Sender(senderId: senderId, displayName: senderName)
                    let comment = Comment(sender: sender, messageId: messageId, sentDate: sentDate, kind: finalKind, userImage: userImage, workoutId: workoutId, programId: programId, mediaRef: mediaRef)
                    return comment
                }
                   completion(comments)
               }
       }
    
    public func getCommentsCount(workout: Workout, completion: @escaping(Int)->()){
        print ("executing loading comments from database \(#function)")

        let documentID = workout.programID
               .replacingOccurrences(of: "/", with: "_")
               .replacingOccurrences(of: " ", with: "_")
        
        var numberOfComments = 0

        database
            .collection("programs")
            .document(documentID)
            .collection("workouts")
            .document(workout.id)
            .collection("comments")
            .order(by: "sentDate", descending: false)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    numberOfComments = querySnapshot?.count ?? 0
                    print("found \(numberOfComments) comments for selected workout")
                }
                completion(numberOfComments)
            }
       }
    
    public func updateWorkoutCommentsCount(workout: Workout, commentsCount: Int, completion: @escaping (Workout)->()){
        print("Executing function: \(#function)")
        let documentID = workout.programID
               .replacingOccurrences(of: "/", with: "_")
               .replacingOccurrences(of: " ", with: "_")
        
        let dbRef = database
            .collection("programs")
            .document(documentID)
            .collection("workouts")
            .document(workout.id)
        
        dbRef.updateData(["comments": commentsCount]) { error in
            if error == nil {
                var updatedWorkout = workout
                updatedWorkout.comments = commentsCount
                completion(updatedWorkout)
            }
        }
    }
    
    public func updateComment(comment: Comment, newDescription: String, newMediaRef: String?, completion: @escaping (Bool)->()){
        print("Executing function: \(#function)")
        
        guard let programId = comment.programId, let workoutId = comment.workoutId else {return}
        let documentID = programId
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: " ", with: "_")
        
        let dbRef = database
            .collection("programs")
            .document(documentID)
            .collection("workouts")
            .document(workoutId)
            .collection("comments")
            .document(comment.messageId)
        
        dbRef.getDocument { snapshot, error in
            guard var data = snapshot?.data(), error == nil else {return}
            
            data["contents"] = newDescription
            data["mediaRef"] = newMediaRef ?? ""
            dbRef.setData(data) { error in
                completion(error == nil)
            }
        }
    }
    
    public func deleteComment(comment: Comment, completion: @escaping (Bool)->()){
        print("Executing function: \(#function)")
        
        guard let programId = comment.programId, let workoutId = comment.workoutId else {return}
        let documentID = programId
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: " ", with: "_")
        
        let commentsRef = database
            .collection("programs")
            .document(documentID)
            .collection("workouts")
            .document(workoutId)
            .collection("comments")
            .document(comment.messageId)
        
        commentsRef.delete() { error in
            if let error = error {
                print("Error deleting comment: \(error.localizedDescription)")
                completion(false)
            } else {
                print("comment deleted successfully")
                completion(true)
            }
        }
    }
    
    public func deleteAllWorkoutCommentsForUser(userId: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        
        let programsIDs = ["Belly_Burner_Plan", "Bodyweight", "ECD_Plan", "Pelvic_Power_Plan", "Struyach_Plan"]
        
        for program in programsIDs {
            db.collection("programs")
                .document(program)
                .collection("workouts")
                .getDocuments { (snapshot, error) in
                    guard let documents = snapshot?.documents else {
                        print("Error retrieving blog posts: \(error?.localizedDescription ?? "Unknown error")")
                        completion(false)
                        return
                    }
                    
                    let dispatchGroup = DispatchGroup()
                    
                    for document in documents {
                        let workoutId = document.documentID
                        print ("workoutId: \(workoutId)")
                        
                        let commentsCollection = db.collection("programs")
                            .document(program)
                            .collection("workouts")
                            .document(workoutId)
                            .collection("comments")
                        let query = commentsCollection.whereField("senderId", isEqualTo: userId)
                        
                        dispatchGroup.enter()
                        
                        query.getDocuments { (snapshot, error) in
                            guard let documents = snapshot?.documents else {
                                print("Error retrieving comments for post \(workoutId): \(error?.localizedDescription ?? "Unknown error")")
                                dispatchGroup.leave()
                                completion(false)
                                return
                            }
                            
                            let batch = db.batch()
                            
                            for document in documents {
                                let commentId = document.documentID
                                let commentRef = commentsCollection.document(commentId)
                                
                                batch.deleteDocument(commentRef)
                            }
                            
                            batch.commit { (error) in
                                if let error = error {
                                    print("Error deleting comments for post \(workoutId): \(error.localizedDescription)")
                                    completion(false)
                                } else {
                                    print("Comments deleted successfully for post \(workoutId)")
                                }
                                
                                dispatchGroup.leave()
                            }
                        }
                    }
                    
                    dispatchGroup.notify(queue: .main) {
                        completion(true)
                        print("Deletion of all workout comments for user \(userId) completed")
                    }
                }
        }
    }
    
    public func addNewCommentsListener(workout: Workout, completion: @escaping ([Comment]) -> ()) -> ListenerRegistration? {
        print("Executing function: \(#function)")
        let documentID = workout.programID
                .replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: " ", with: "_")

           let listener = database
                .collection("programs")
                .document(documentID)
                .collection("workouts")
                .document(workout.id)
                .collection("comments")
                .order(by: "timestamp", descending: false)
                .addSnapshotListener { snapshot, error in
                    guard let documents = snapshot?.documents.compactMap({ $0.data()}), error == nil else {return}
                    let comments: [Comment] = documents.compactMap { dictionary in
                        guard let senderId = dictionary["senderId"] as? String,
                              let senderName = dictionary["senderName"] as? String,
                              let userImage = dictionary["userImage"] as? Data,
                              let messageId = dictionary["messageId"] as? String,
                              let contents = dictionary["contents"] as? String,
                              let type = dictionary["type"] as? String,
                              let date = dictionary["sentDate"] as? Timestamp,
                              let workoutId = dictionary["workoutId"] as? String,
                              let programId = dictionary["programId"] as? String,
                              let mediaRef = dictionary["mediaRef"] as? String else {print("unable to create comment")
                            return nil}
                        
                        let sentDate = date.dateValue()
                        
                        var kind: MessageKind?
                        
                        switch type {
                        case "photo":
                            guard let imageURL = URL(string: contents),
                            let placeholder = UIImage(systemName: "photo") else {return nil}
                            let media = Media(url: imageURL, image: nil, placeholderImage: placeholder, size: CGSize(width: 300, height: 250))
                            kind = .photo(media)
                        case "video":
                            guard let videoUrl = URL(string: contents),
                            let placeholder = UIImage(named: "general") else {return nil}
                            let media = Media(url: videoUrl, image: nil, placeholderImage: placeholder, size: CGSize(width: 90, height: 90))
                            kind = .video(media)
                        case "text": kind = .text(contents)
                        default: break
                        }

                        guard let finalKind = kind else {return nil}
                        let sender = Sender(senderId: senderId, displayName: senderName)
                        let comment = Comment(sender: sender, messageId: messageId, sentDate: sentDate, kind: finalKind, userImage: userImage, workoutId: workoutId, programId: programId, mediaRef: mediaRef)
                        return comment
                    }
                       completion(comments)
                   }
        return listener
        }
    
    //MARK: - Adding, fetching and editing users
    
    public func insertUser(user: User, completion: @escaping(Bool) ->()){
        
        let documentID = user.email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        let data: [String : Any] = [
            "email": user.email,
            "name": user.name,
            "profile_photo": user.profilePictureRef,
            "isAdmin": user.isAdmin,
            "hideEmail": user.emailIsHidden
        ]
        
        database
            .collection("users")
            .document(documentID)
            .setData(data) { error in
                completion(error == nil)
            }
    }
    
    public func getUser(email: String, completion: @escaping(User?)->()){
        let documentID = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        database
            .collection("users")
            .document(documentID)
            .getDocument { snapshot, error in
                guard let data = snapshot?.data(),
                      let name = data["name"] as? String,
                      let imageRef = data["profile_photo"] as? String,
                      let hideEmail = data["hideEmail"] as? Bool,
                      let isAdmin = data["isAdmin"] as? Bool,
                      error == nil else {
                    completion(nil)
                    return
                }
                let token = data["fcmToken"] as? String
                let personalRecords = data["personal_records"] as? String
                let likedWorkouts = data["liked_workouts"] as? String
                let likedPosts = data["liked_posts"] as? String
                let user = User(name: name, email: email, profilePictureRef: imageRef, personalRecords: personalRecords, isAdmin: isAdmin, fcmToken: token, emailIsHidden: hideEmail, likedWorkouts: likedWorkouts, likedPosts: likedPosts)
                        completion(user)
                    }
                }
    
    public func deleteUser(email: String, completion: @escaping (Bool)->()){
        let documentID = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        let dbRef = database
            .collection("users")
            .document(documentID)
        
        dbRef.delete() { error in
            if let error = error {
                print("Error deleting user: \(error.localizedDescription)")
                completion(false)
            } else {
                print("user deleted successfully")
                completion(true)
            }
        }
    }
    
    public func updateUserName(email: String, newUserName: String,
                               completion: @escaping(Bool)->()
    ){
        let documentID = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        let dbRef = database
            .collection("users")
            .document(documentID)
        
        dbRef.getDocument { snapshot, error in
            guard var data = snapshot?.data(), error == nil else {return}
            data["name"] = newUserName
            dbRef.setData(data) { error in
                if error == nil {
                    completion(true)
                }
            }
        }
    }
    
    public func updateFCMToken(email: String, newToken: String,
                               completion: @escaping(Bool)->()
    ){
        let documentID = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        let dbRef = database
            .collection("users")
            .document(documentID)
        
        dbRef.getDocument { snapshot, error in
            guard var data = snapshot?.data(), error == nil else {return}
            data["fcmToken"] = newToken
            dbRef.setData(data) { error in
                if error == nil {
                    completion(true)
                }
            }
        }
    }
    
    public func updateLikedWorkouts(email: String, completion: @escaping(Bool)->()){
        let path = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        let reference = "users/\(path)/liked_workouts.json"
        
        let dbRef = database
            .collection("users")
            .document(path)
        
        dbRef.getDocument { snapshot, error in
            guard var data = snapshot?.data(), error == nil else {return}
            data["liked_workouts"] = reference
            dbRef.setData(data) { error in
                if error == nil {
                    completion(true)
                }
            }
        }
    }
    
    public func updateLikedPosts(email: String, completion: @escaping(Bool)->()){
        let path = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        let reference = "users/\(path)/liked_posts.json"
        
        let dbRef = database
            .collection("users")
            .document(path)
        
        dbRef.getDocument { snapshot, error in
            guard var data = snapshot?.data(), error == nil else {return}
            data["liked_posts"] = reference
            dbRef.setData(data) { error in
                if error == nil {
                    completion(true)
                }
            }
        }
    }
    
    public func updateProfilePhoto(email: String, completion: @escaping (Bool) ->()){
        let path = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        let photoReference = "users/\(path)/profile_picture.png"
        
        let dbRef = database
            .collection("users")
            .document(path)
        
        dbRef.getDocument { snapshot, error in
            guard var data = snapshot?.data(), error == nil else {return}
            
            data["profile_photo"] = photoReference
            dbRef.setData(data) { error in
                completion(error == nil)
            }
        }
    }
    
    public func updateUserPersonalRecords(email: String, completion: @escaping (Bool) ->()){
        let path = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        let recordsReference = "users/\(path)/personal_records.json"
        
        let dbRef = database
            .collection("users")
            .document(path)
        
        dbRef.getDocument { snapshot, error in
            guard var data = snapshot?.data(), error == nil else {return}
            
            data["personal_records"] = recordsReference
            dbRef.setData(data) { error in
                completion(error == nil)
            }
        }
    }
    
    public func hideOrShowEmail(email: String, isHidden: Bool,
                               completion: @escaping(Bool)->()
    ){
        let documentID = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        let dbRef = database
            .collection("users")
            .document(documentID)
        
        dbRef.getDocument { snapshot, error in
            guard var data = snapshot?.data(), error == nil else {return}
            data["hideEmail"] = isHidden
            dbRef.setData(data) { error in
                if error == nil {
                    completion(true)
                }
            }
        }
    }
}
