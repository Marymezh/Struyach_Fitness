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
                             program: String,
                             completion: @escaping(Bool) ->()
    ){
//        let documentID = email
//            .replacingOccurrences(of: ".", with: "_")
//            .replacingOccurrences(of: "@", with: "_")
        
        let data: [String : Any] = [
            "program": workout.program,
            "text": workout.description,
            "date": workout.date,
            "id": workout.identifier
        ]
        
        let ecdCollection = database.collection("ecd plan")
        let bodyweightCollection = database.collection("bodyweight plan")
        let struyachCollection = database.collection("struyach plan")
        let hardpressCollection = database.collection("hardpress")
        let badassCollection = database.collection("badass")
        
        switch program {
        case K.ecd:
            ecdCollection.document(workout.date).setData(data) { error in
                completion (error == nil)
            }
        case K.bodyweight:
            bodyweightCollection.document(workout.date).setData(data) { error in
                completion (error == nil)
            }
        case K.struyach:
            struyachCollection.document(workout.date).setData(data) { error in
                completion (error == nil)
            }
        case K.hardpress:
            hardpressCollection.document(workout.date).setData(data) { error in
                completion (error == nil)
            }
        case K.badass:
            badassCollection.document(workout.date).setData(data) { error in
                completion (error == nil)
            }
        default: break
        }
    }
        
//        database
//            .collection("workouts")
//            .addDocument(data: data) { error in
//                completion (error == nil)
//            }
//            .document(workout.program)
//            .collection("\(program)")
//            .document(workout.date)
//            .setData(data) { error in
//                completion(error == nil)
//            }
//    }
    
    public func getAllWorkouts( completion: @escaping([Workout])->()){
        
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
