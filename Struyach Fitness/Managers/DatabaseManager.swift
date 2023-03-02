//
//  DatabaseManager.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import Foundation
import FirebaseFirestore

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    private let database = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    private init() {}

    public func postWorkout( with workout: Workout,
                             programID: String,
                             completion: @escaping(Bool) ->()){
        
        let program = programID
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "", with: "_")
        
        let workoutData: [String: Any] = [
            "date": workout.date,
            "description": workout.description,
            "programID": workout.programID,
            "id": workout.id,
            "timestamp": workout.timestamp]
        
        database
            .collection("programs")
            .document(program)
            .collection("workouts")
            .document(workout.id)
            .setData(workoutData) { error in
                completion (error == nil)
            }
    }
    
    public func getAllWorkouts(for program: String,
                               completion: @escaping([Workout])->()){
        
        let documentID = program
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "", with: "_")
        
        database
            .collection("programs")
            .document(documentID)
            .collection("workouts")
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents.compactMap({ $0.data()}), error == nil else {return}
                let workouts: [Workout] = documents.compactMap { dictionary in
                    guard let id = dictionary["id"] as? String,
                          let date = dictionary["date"] as? String,
                          let timestamp = dictionary["timestamp"] as? TimeInterval,
                          let programID = dictionary["programID"] as? String,
                          let text = dictionary["description"] as? String else {return nil}
                    
                    let workout = Workout(id: id, programID: programID, description: text, date: date, timestamp: timestamp)
                    return workout
                }
                completion(workouts)
            }
    }
    
    public func updateWorkout(program: String, workoutID: String, newDescription: String, completion: @escaping (Bool)->()){
        let documentID = program
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "", with: "_")
    
    let dbRef = database
            .collection("programs")
            .document(documentID)
            .collection("workouts")
            .document(workoutID)
// TODO: - Map with Codable, read here https://firebase.google.com/docs/firestore/solutions/swift-codable-data-mapping
    dbRef.getDocument { snapshot, error in
        guard var data = snapshot?.data(), error == nil else {return}
        
        data["description"] = newDescription
        dbRef.setData(data) { error in
            completion(error == nil)
        }
    }
}
    
    public func deleteWorkout(program: String, workoutID: String, completion: @escaping (Bool)->()){
      
        let documentID = program
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "", with: "_")
        
        database
            .collection("programs")
            .document(documentID)
            .collection("workouts")
            .document(workoutID)
            .collection("comments")
            .document()
            .delete() { error in
                completion (error == nil)
            }
        
        
        database
                .collection("programs")
                .document(documentID)
                .collection("workouts")
                .document(workoutID)
                .delete() { error in
                    completion (error == nil)
                }
        
    }
    // TODO: - Map with Codable, read here https://firebase.google.com/docs/firestore/solutions/swift-codable-data-mapping
    public func addComment(comment: Comment,
                           programID: String,
                           completion: @escaping (Bool) ->()){
        
        let documentID = comment.programID
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "", with: "_")
        
        let commentData: [String: Any] = [
            "userName": comment.userName,
            "userImage": comment.userImage,
            "date": comment.date,
            "text": comment.text,
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
    // TODO: - Map with Codable, read here https://firebase.google.com/docs/firestore/solutions/swift-codable-data-mapping
    public func getAllComments(for workout: String,
                               program: String,
                               completion: @escaping([Comment])->()){
        
        let documentID = program
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "", with: "_")
        
        database
            .collection("programs")
            .document(documentID)
            .collection("workouts")
            .document(workout)
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
                          let timestamp = dictionary["timestamp"] as? TimeInterval,
                          let programID = dictionary["programID"] as? String else {return nil}
                    
                    let comment = Comment(timeStamp: timestamp, userName: userName, userImage: userImage, date: date, text: text, id: id, workoutID: workoutID, programID: programID)
                    return comment
                }
                completion(comments)
            }
    }
    
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
