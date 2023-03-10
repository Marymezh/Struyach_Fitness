//
//  Comment.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 9/2/23.
//

import Foundation

struct Comment: Codable {
    let timeStamp: TimeInterval
    let userName: String
    let userImage: Data
    let date: String
    let text: String
    let imageRef: String?
    let id: String
    let workoutID: String
    let programID: String
}
