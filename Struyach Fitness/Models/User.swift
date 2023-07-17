//
//  User.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import Foundation

struct User: Codable {
    let name: String
    let email: String
    let profilePictureRef: String?
    let weightliftingRecords: String?
    let gymnasticRecords: String?
    let isAdmin: Bool
    let fcmToken: String?
    let emailIsHidden: Bool
    let likedWorkouts: String?
    let likedPosts: String?
    let userLanguage: String?
}
