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
    
    public func postWorkout( with postText: WorkoutDescription,
                             user: User,
                             completion: @escaping(Bool) ->()
    ){
        
    }
    public func getAllWorkouts( completion: @escaping([WorkoutDescription])->()){
        
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
}
