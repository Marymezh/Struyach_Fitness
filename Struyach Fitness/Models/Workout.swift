//
//  Workout.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import Foundation
import FirebaseFirestoreSwift

struct Workout: Codable, Equatable {
    var id: String
    let programID: String
    var description: String
    let date: String
    let timestamp: TimeInterval
    var likes: Int = 0 
//    var comments: [Comment] = []
}
