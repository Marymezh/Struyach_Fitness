//
//  Post.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 5/4/23.
//

import Foundation
import FirebaseFirestoreSwift

struct Post: Codable, Equatable {
    var id: String
    var description: String
    let date: String
    let timestamp: TimeInterval
    var likes: Int = 0
    var comments: Int = 0 
}
