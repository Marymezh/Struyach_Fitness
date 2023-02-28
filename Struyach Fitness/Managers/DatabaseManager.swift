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
    
    private init() {}
    
//    public func postComment( with comment: String,
//                             user: String,
//                             completion: @escaping(Bool) ->()
//    ){
//
//    }
//
//    public func getAllComments( completion: @escaping([String]) ->()
//       ){
//
//       }
    
    public func postWorkout( with workout: Workout,
                             programID: String,
                             completion: @escaping(Bool) ->()
    ){
        
        let program = programID
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "", with: "_")
        
        let workoutData: [String: Any] = [
            "description": workout.description,
            "programID": workout.programID,
            "date": workout.date,
            "id": workout.id]
        
        database
            .collection("programs")
            .document(program)
            .collection("workouts")
            .document(workout.id)
            .setData(workoutData) { error in
                completion (error == nil)
            }
    }
    
    public func addComment(comment: Comment, completion: @escaping (Bool) ->()) {

        
        let commentData: [String: Any] = [
            "workoutID": comment.workoutID,
            "text": comment.text,
            "date": comment.date,
            "userName": comment.userName,
            "userImage": comment.userImage,
            "id": comment.id
        ]
        
        database
            .collection("programs")
            .document("ecd plan")
            .collection("workouts")
            .document(comment.workoutID)
            .collection("comments")
            .document(comment.id)
            .setData(commentData) { error in
            completion (error == nil)
        }
    }
        
    
    public func getAllWorkouts(collection: String, workoutID: String, completion: @escaping([Workout])->()){
      
        let documentID = collection
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "", with: "_")
        
        let workoutID = workoutID
        
        database
            .collection("programs")
            .document(documentID)
            .collection("workouts")
            .document(workoutID)
            .getDocument { snapshot, error in
                guard let data = snapshot?.data() as? [String: String],
                      let text = data["description"],
                      let id = data["id"],
                      let date = data["date"],
                      let programID = data["programID"],
                      error == nil else {return}
                
                let workout = Workout(id: id, programID: programID, description: text, date: date)
                completion([workout])
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
