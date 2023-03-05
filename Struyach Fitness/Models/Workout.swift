//
//  Workout.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import Foundation

struct Workout: Codable {
    let id: String
    let programID: String
    var description: String
    let date: String
    let timestamp: TimeInterval
}
