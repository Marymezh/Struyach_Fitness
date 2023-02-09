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
    private let container = Storage.storage().reference()
    
    private init() {}
    
    
    public func uploadUserProfilePicture( email: String, image: UIImage?, completion: @escaping (Bool)->()) {
        
    }
    
    public func downloadUrlForProfilePicture(user: User, compleion: @escaping (URL?)->()){
        
    }
}
