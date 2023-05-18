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
    let profilePictureRef: String
    let personalRecords: String?
    let isAdmin: Bool
}
