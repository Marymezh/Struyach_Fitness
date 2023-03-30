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
                    //         print(error?.localizedDescription)
                    return
                }
                completion(imageRef)
            }
    }
    
    public func uploadVideoURLForComment(videoID: String, videoData: Data, workout: Workout, progressHandler: ((Float) -> Void)?, completion: @escaping (String?) -> ()) {
        
        let videoRef = "comments_video/\(workout.programID)/\(videoID)"
        print(videoData)
        let storageRef = container.reference(withPath: videoRef)
           let uploadTask = storageRef.putData(videoData, metadata: nil) { metadata, error in
               if let error = error {
                   print("Error uploading video to Storage: \(error.localizedDescription)")
                   completion(nil)
                   return
               }
               completion(videoRef)
           }
        uploadTask.observe(.progress) { snapshot in
                    guard let progress = progressHandler, let percentComplete = snapshot.progress?.fractionCompleted else { return }
                    progress(Float(percentComplete))
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
    
    public func downloadUrl(path: String, completion: @escaping (URL?)->()){
        container.reference(withPath: path)
            .downloadURL { url, _ in
                completion(url)
            }
    }
}
