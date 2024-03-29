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
    
    public func uploadImageForComment(email: String, image: Data?, imageId: String, progressHandler: ((Float) -> Void)?, completion: @escaping (String?)->()) {
        
        let path = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        guard let pngData = image else {return}
        let imageRef = "users/\(path)/\(imageId)_photo.png"
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
    
    public func uploadVideoURLForComment(email: String, videoID: String, videoData: Data, progressHandler: ((Float) -> Void)?, completion: @escaping (String?) -> ()) {
        
        let path = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        let videoRef = "users/\(path)/\(videoID)"
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
                print(error.localizedDescription)
            } else {
                print("Photo deleted successfully!")
            }
        }
    }
    
    public func setUserProfilePicture(email: String, image: Data?, completion: @escaping (String?)->()) {
        let path = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        guard let pngData = image else {
            print("no png data available")
            return}
        let imageRef = "users/\(path)/profile_picture.png"
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
    
    public func uploadUserWeightliftingRecords(email: String, weights: [String]?, completion: @escaping (Bool)->()) {
        let path = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        do {
            let data = try JSONEncoder().encode(weights)
            
            container
                .reference(withPath: "users/\(path)/weightlifting_records.json")
                .putData(data, metadata: nil) { metadata, error in
                    guard metadata != nil, error == nil else {
                        AlertManager.shared.showAlert(title: "Error", message: "Unable to upload new records".localized(), cancelAction: "Cancel".localized())
                        completion(false)
                        return
                    }
                    completion(true)
                }
        } catch {
            AlertManager.shared.showAlert(title: "Error", message: "Unable to upload new records".localized(), cancelAction: "Cancel".localized())
            completion(false)
        }
    }
    
    public func uploadUserGymnasticRecords(email: String, reps: [String]?, completion: @escaping (Bool)->()) {
        let path = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        do {
            let data = try JSONEncoder().encode(reps)
            
            container
                .reference(withPath: "users/\(path)/gymnastic_records.json")
                .putData(data, metadata: nil) { metadata, error in
                    guard metadata != nil, error == nil else {
                        AlertManager.shared.showAlert(title: "Error", message: "Unable to upload new records".localized(), cancelAction: "Cancel".localized())
                        completion(false)
                        return
                    }
                    completion(true)
                }
        } catch {
            AlertManager.shared.showAlert(title: "Error", message: "Unable to upload new records".localized(), cancelAction: "Cancel".localized())
            completion(false)
        }
    }
    
    public func uploadLikedPosts(email: String, likedPosts: [String]?, completion: @escaping (Bool)->()) {
        let path = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        do {
            let data = try JSONEncoder().encode(likedPosts)
            
            container
                .reference(withPath: "users/\(path)/liked_posts.json")
                .putData(data, metadata: nil) { metadata, error in
                    guard metadata != nil, error == nil else {
                   //     AlertManager.shared.showAlert(title: "Error", message: "Unable to upload liked posts".localized(), cancelAction: "Cancel".localized())
                        print ("error uploading liked posts")
                        completion(false)
                        return
                    }
                    completion(true)
                }
        } catch {
        //    AlertManager.shared.showAlert(title: "Error", message: "Unable to upload liked posts".localized(), cancelAction: "Cancel".localized())
            print ("error encoding liked posts")
            completion(false)
        }
    }
    
    public func uploadLikedWorkouts(email: String, likedWorkouts: [String]?, completion: @escaping (Bool)->()) {
        let path = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        do {
            let data = try JSONEncoder().encode(likedWorkouts)
            
            container
                .reference(withPath: "users/\(path)/liked_workouts.json")
                .putData(data, metadata: nil) { metadata, error in
                    guard metadata != nil, error == nil else {
                        print ("error uploading liked workouts")
//                        AlertManager.shared.showAlert(title: "Error", message: "Unable to upload liked workouts".localized(), cancelAction: "Cancel".localized())
                        completion(false)
                        return
                    }
                    completion(true)
                }
        } catch {
      //      AlertManager.shared.showAlert(title: "Error", message: "Unable to upload liked workouts".localized(), cancelAction: "Cancel".localized())
            print ("error encoding json with liked workouts")
            completion(false)
        }
    }
    
    public func downloadUrl(path: String, completion: @escaping (URL?)->()){
        container.reference(withPath: path)
            .downloadURL { url, _ in
                completion(url)
            }
    }

    public func deleteUserData(email: String, completion: @escaping (Bool, Error?) -> Void) {
        let path = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        let userFolderRef = "users/\(path)"
        
        let storageReference = container.reference().child(userFolderRef)
        storageReference.listAll { (result, error) in
            if let error = error {
                print("Error listing folder contents: \(error.localizedDescription)")
                completion(false, error) // Call the completion block with error if an error occurs
                return
            }  else if let result = result {
                print ("Number of files to delete:\(result.items.count)")
                
                
                let dispatchGroup = DispatchGroup() // Create a dispatch group
                
                for item in result.items {
                    dispatchGroup.enter()
                    
                    item.delete { error in
                        if let error = error {
                            print("Error deleting item:", error)
                            completion(false, error) // Call the completion block with error if an error occurs
                        }
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    completion(true, nil) // Call the completion block with success when all items are deleted
                    print("Deletion of user data completed")
                }
            }
        }
    }
}
