//
//  UserPush.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 13.07.2023.
//

import Foundation

struct UserPush: Codable {
    let title: String
    let body: String
    let type: String
    let destination: String
    let collectionId: String?
}
