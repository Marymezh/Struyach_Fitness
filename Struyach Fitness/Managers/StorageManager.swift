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
    
    public func uploadImageForComment(image: Data?, imageId: String, workout: Workout, progressHandler: ((Float) -> Void)?, completion: @escaping (String?)->()) {
        guard let pngData = image else {return}
        
        let imageRef = "comments_photo_and_video/photo/\(workout.programID)/\(imageId)_photo.png"
        let storageRef = container.reference(withPath: imageRef)
        let uploadTask = storageRef.putData(pngData, metadata: nil) { metadata, error in
                guard metadata != nil, error == nil else {
                    completion(nil)
                    return
                }
                completion(imageRef)
            }
        uploadTask.observe(.progress) { snapshot in
                    guard let progress = progressHandler, let percentComplete = snapshot.progress?.fractionCompleted else { return }
                    progress(Float(percentComplete))
                }
    }
    
    public func uploadImageForBlogComment(image: Data?, imageId: String, blogPost: Post, progressHandler: ((Float) -> Void)?, completion: @escaping (String?)->()) {
        guard let pngData = image else {return}
        
        let imageRef = "blog_comments_photo_and_video/photo/\(blogPost.id)/\(imageId)_photo.png"
        let storageRef = container.reference(withPath: imageRef)
        let uploadTask = storageRef.putData(pngData, metadata: nil) { metadata, error in
                guard metadata != nil, error == nil else {
                    completion(nil)
                    return
                }
                completion(imageRef)
            }
        uploadTask.observe(.progress) { snapshot in
                    guard let progress = progressHandler, let percentComplete = snapshot.progress?.fractionCompleted else { return }
                    progress(Float(percentComplete))
                }
    }
    
    public func uploadVideoURLForComment(videoID: String, videoData: Data, workout: Workout, progressHandler: ((Float) -> Void)?, completion: @escaping (String?) -> ()) {
        
        let videoRef = "comments_photo_and_video/video/\(workout.programID)/\(videoID)"
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
    public func uploadVideoURLForBlogComment(videoID: String, videoData: Data, blogPost: Post, progressHandler: ((Float) -> Void)?, completion: @escaping (String?) -> ()) {
        
        let videoRef = "blog_comments_photo_and_video/video/\(blogPost.id)/\(videoID)"
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
    
    
    
    public func deleteCommentsPhotoAndVideo(mediaRef: String) {
        
        let storageRef = container.reference(withPath: mediaRef)
        storageRef.delete { error in
            if let error = error {
                // Uh-oh, an error occurred!
                print(error.localizedDescription)
            } else {
                // Photo deleted successfully
                print("Photo deleted successfully!")
            }
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
    
    public func setUserProfilePicture(email: String, image: Data?, completion: @escaping (String?)->()) {
        let path = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        guard let pngData = image else {
            print("no png data available")
            return}
        let imageRef = "profile_pictures/\(path)/photo.png"
        container
            .reference(withPath: imageRef)
            .putData(pngData, metadata: nil) { metadata, error in
                guard metadata != nil, error == nil else {
                    completion(nil)
                    print ("can't set user profile image")
                    return
                }
                completion(imageRef)
                print ("profile picture is set with this path: \(imageRef)")
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
