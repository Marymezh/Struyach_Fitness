//
//  StorageManager.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import Foundation
import FirebaseStorage
import UIKit

final class StorageManager {
    static let shared = StorageManager()
    private let container = Storage.storage()
    
    private init() {}
    //TODO: - write methods to upload image and video URL to Firebase Storage
    
    public func uploadImageForComment(image: Data?, imageId: String, workout: Workout, completion: @escaping (String?)->()) {
        guard let pngData = image else {return}
        
        let imageRef = "comments_photo/\(workout.programID)/\(imageId)_photo.png"
        container
            .reference(withPath: imageRef)
            .putData(pngData, metadata: nil) { metadata, error in
                guard metadata != nil, error == nil else {
                    completion(nil)
                    print(error?.localizedDescription)
                    return
                }
                completion(imageRef)
            }
    }
    
    public func uploadVideoURLForComment(email: String, video: URL?, completion: @escaping (Bool)->()) {
        
    }
    
    public func downloadUrlForCommentImage(path: String, completion: @escaping (URL?)->()){
        container.reference(withPath: path)
            .downloadURL { url, _ in
                completion(url)
            }
    }
    
    public func downloadUrlForCommentVideo(path: String, completion: @escaping (URL?)->()){
        container.reference(withPath: path)
            .downloadURL { url, _ in
                completion(url)
            }
    }
    
    public func uploadUserProfilePicture(email: String, image: Data?, completion: @escaping (Bool)->()) {
        let path = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        guard let pngData = image else {return}
        container
            .reference(withPath: "profile_pictures/\(path)/photo.png")
            .putData(pngData, metadata: nil) { metadata, error in
                guard metadata != nil, error == nil else {
                    completion(false)
                    return
                }
                completion(true)
            }
    }
    
    public func downloadUrlForProfilePicture(path: String, completion: @escaping (URL?)->()){
        container.reference(withPath: path)
            .downloadURL { url, _ in
                completion(url)
            }
    }

    public func uploadUserPersonalRecords(email: String, weights: [String]?, completion: @escaping (Bool)->()) {
        let path = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        let data = try! JSONEncoder().encode(weights)
        
        container
            .reference(withPath: "personal_records/\(path)/records.json")
            .putData(data, metadata: nil) { metadata, error in
                guard metadata != nil, error == nil else {
                    completion(false)
                    return
                }
                completion(true)
            }
    }
    
    public func downloadUrlForUserRecords(path: String, completion: @escaping (URL?)->()){
        container.reference(withPath: path)
            .downloadURL { url, _ in
                completion(url)
            }
    }
}
