//
//  DatabaseManager.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    private let database = Firestore.firestore()
    
    private init() {}
    
    //MARK: - Adding, fetching, editing, deleting workouts and listen to the changes in workouts
//TODO: - Firebase pagination and caching workouts and comments localy 
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
                    completion(error == nil)
                }
        } catch {
            print("Error encoding workout: \(error)")
            completion(false)
        }
    }
    
    public func getAllWorkouts(for program: String, completion: @escaping([Workout])->()){
        print("Executing function: \(#function)")
        let documentID = program
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: " ", with: "_")
    
        database
            .collection("programs")
            .document(documentID)
            .collection("workouts")
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
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
    
//    public func searchForWorkouts(for program: String, searchText: String, completion: @escaping([Workout])->()){
//        print("Executing function: \(#function)")
//        let documentID = program
//            .replacingOccurrences(of: "/", with: "_")
//            .replacingOccurrences(of: " ", with: "_")
//        var query: Query?
//        
//       let workoutRef =  database
//            .collection("programs")
//            .document(documentID)
//            .collection("workouts")
//            .order(by: "timestamp", descending: true)
//        
//        if searchText.isEmpty {
//            query = workoutRef
//        } else {
//            query = workoutRef.whereField("description", arrayContains: searchText)
//        }
//        
//            query?.getDocuments { snapshot, error in
//                guard let documents = snapshot?.documents else {
//                    print("Error fetching documents: \(error!)")
//                    return
//                }
//                
//                let workouts: [Workout] = documents.compactMap { document in
//                    do {
//                        let workout = try Firestore.Decoder().decode(Workout.self, from: document.data())
//                        print("workouts decoded from database")
//                        return workout
//                    } catch {
//                        print("Error decoding workout: \(error)")
//                        return nil
//                    }
//                }
//                completion(workouts)
//            }
//    }
    
    public func updateWorkout(workout: Workout, newDescription: String, completion: @escaping (Bool)->()){
        print("Executing function: \(#function)")
        let documentID = workout.programID
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: " ", with: "_")
    
    let dbRef = database
            .collection("programs")
            .document(documentID)
            .collection("workouts")
            .document(workout.id)

    dbRef.getDocument { snapshot, error in
        guard var data = snapshot?.data(), error == nil else {return}
        
        data["description"] = newDescription
        dbRef.setData(data) { error in
            completion(error == nil)
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
    
    func addWorkoutsListener(for programName: String, completion: @escaping ([Workout]) -> ()) -> ListenerRegistration? {
        print("Executing function: \(#function)")
        
        let documentID = programName
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: " ", with: "_")
        
        let listener = database
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
        return listener
    }
    
    //MARK: - Adding, fetching and listen to the changes in comments
    public func postComment(comment: Comment, completion: @escaping (Bool) ->()){

           let documentID = comment.programID
               .replacingOccurrences(of: "/", with: "_")
               .replacingOccurrences(of: " ", with: "_")

           let commentData: [String: Any] = [
               "userName": comment.userName,
               "userImage": comment.userImage,
               "date": comment.date,
               "text": comment.text,
               "image": comment.imageRef ?? "",
               "programID": comment.programID,
               "workoutID": comment.workoutID,
               "commentID": comment.id,
               "timestamp": comment.timeStamp
           ]

           database
               .collection("programs")
               .document(documentID)
               .collection("workouts")
               .document(comment.workoutID)
               .collection("comments")
               .document(comment.id)
               .setData(commentData) { error in
                   completion (error == nil)
               }
       }

    public func getAllComments(programID: String, workoutID: String, completion: @escaping([Comment])->()){

           let documentID = programID
               .replacingOccurrences(of: "/", with: "_")
               .replacingOccurrences(of: " ", with: "_")

           database
               .collection("programs")
               .document(documentID)
               .collection("workouts")
               .document(workoutID)
               .collection("comments")
               .order(by: "timestamp", descending: true)
               .getDocuments { snapshot, error in
                   guard let documents = snapshot?.documents.compactMap({ $0.data()}), error == nil else {return}
                   let comments: [Comment] = documents.compactMap { dictionary in
                       guard let userName = dictionary["userName"] as? String,
                             let userImage = dictionary["userImage"] as? Data,
                             let id = dictionary["commentID"] as? String,
                             let workoutID = dictionary["workoutID"] as? String,
                             let date = dictionary["date"] as? String,
                             let text = dictionary["text"] as? String,
                             let image = dictionary["image"] as? String,
                             let timestamp = dictionary["timestamp"] as? TimeInterval,
                             let programID = dictionary["programID"] as? String else {return nil}

                       let comment = Comment(timeStamp: timestamp, userName: userName, userImage: userImage, date: date, text: text, imageRef: image, id: id, workoutID: workoutID, programID: programID)
                       return comment
                   }
                   completion(comments)
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
                .order(by: "timestamp", descending: true)
                .addSnapshotListener { snapshot, error in
                    guard let documents = snapshot?.documents.compactMap({ $0.data() }), error == nil else {
                        print("Error retrieving snapshot: \(error!)")
                        return
                    }
                    let comments: [Comment] = documents.compactMap { dictionary in
                        guard let userName = dictionary["userName"] as? String,
                              let userImage = dictionary["userImage"] as? Data,
                              let id = dictionary["commentID"] as? String,
                              let workoutID = dictionary["workoutID"] as? String,
                              let date = dictionary["date"] as? String,
                              let text = dictionary["text"] as? String,
                              let image = dictionary["image"] as? String,
                              let timestamp = dictionary["timestamp"] as? TimeInterval,
                              let programID = dictionary["programID"] as? String else {return nil}
                        
                        let comment = Comment(timeStamp: timestamp, userName: userName, userImage: userImage, date: date, text: text, imageRef: image, id: id, workoutID: workoutID, programID: programID)
                        return comment
                    }
                    completion(comments)
                }
        return listener
        }
//
//    public func postComment(comment: Comment,
//                           completion: @escaping (Bool) ->()){
//        print("Executing function: \(#function)")
//        let program = comment.programID
//            .replacingOccurrences(of: "/", with: "_")
//            .replacingOccurrences(of: " ", with: "_")
//
//        do {
//            let commentData = try Firestore.Encoder().encode(comment)
//            database
//                .collection("programs")
//                .document(program)
//                .collection("workouts")
//                .document(comment.workoutID)
//                .collection("comments")
//                .document(comment.id)
//                .setData(commentData) { error in
//                    completion(error == nil)
//                }
//        } catch {
//            print("Error encoding workout: \(error)")
//            completion(false)
//        }
//    }
//
//    public func getAllComments(programID: String, workoutID: String, completion: @escaping([Comment])->()){
//        print("Executing function: \(#function)")
//        let program = programID
//            .replacingOccurrences(of: "/", with: "_")
//            .replacingOccurrences(of: " ", with: "_")
//
//        database
//            .collection("programs")
//            .document(program)
//            .collection("workouts")
//            .document(workoutID)
//            .collection("comments")
//            .order(by: "timestamp", descending: true)
//            .getDocuments{ snapshot, error in
//                guard let documents = snapshot?.documents, error == nil else {
//                    print("Error fetching documents: \(error!)")
//                return}
//
//                let comments: [Comment] = documents.compactMap { document in
//                    do {
//                        print("start decoding comments")
//                        let comment = try Firestore.Decoder().decode(Comment.self, from: document.data())
//                        print ("comments decoded from database")
//                        return comment
//                    } catch {
//                        print("cant fetch comments from database")
//                        return nil
//                    }
//                }
//                completion(comments)
//            }
//    }

//    public func addNewCommentsListener(workout: Workout, completion: @escaping ([Comment]) -> ()) -> ListenerRegistration? {
//        print("Executing function: \(#function)")
//
//        let program = workout.programID
//            .replacingOccurrences(of: "/", with: "_")
//            .replacingOccurrences(of: " ", with: "_")
//
//        let listener = database
//            .collection("programs")
//            .document(program)
//            .collection("workouts")
//            .document(workout.id)
//            .collection("comments")
//            .order(by: "timestamp", descending: true)
//            .addSnapshotListener { (snapshot, error) in
//            guard let snapshot = snapshot else {
//                print("Error fetching comments: \(error?.localizedDescription ?? "unknown error")")
//                return
//            }
//            do {
//                let comments = try snapshot.documents.compactMap { document -> Comment? in
//                    let comment = try document.data(as: Comment.self)
//                    return comment
//                }
//                completion(comments)
//            } catch {
//                print("Error decoding workouts: \(error.localizedDescription)")
//            }
//        }
//        return listener
//    }
    
    //MARK: - Adding, fetching and editing users
    
    public func insertUser(user: User,
                           completion: @escaping(Bool) ->()
    ){
        
        let documentID = user.email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        let data = [
            "email": user.email,
            "name": user.name
        ]
        
        database
            .collection("users")
            .document(documentID)
            .setData(data) { error in
                completion(error == nil)
            }
    }
    
    public func getUser(email: String,
                        completion: @escaping(User?)->()
    ){
        let documentID = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        database
            .collection("users")
            .document(documentID)
            .getDocument { snapshot, error in
                guard let data = snapshot?.data() as? [String: String],
                      let name = data["name"],
                      error == nil else {return}
                
                let imageRef = data["profile_photo"]
                let records = data["user_records"]
                let user = User(name: name, email: email, profilePictureRef: imageRef, personalRecords: records)
                completion(user)
            }
    }
    
    public func updateProfilePhoto(email: String, completion: @escaping (Bool) ->()){
        let path = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        let photoReference = "profile_pictures/\(path)/photo.png"
        
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
        
        let recordsReference = "personal_records/\(path)/records.json"
        
        let dbRef = database
            .collection("users")
            .document(path)
        
        dbRef.getDocument { snapshot, error in
            guard var data = snapshot?.data(), error == nil else {return}
            
            data["user_records"] = recordsReference
            dbRef.setData(data) { error in
                completion(error == nil)
            }
        }
    }
}
