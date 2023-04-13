//
//  Post.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 5/4/23.
//

import Foundation
import FirebaseFirestoreSwift
import RealmSwift

class Post: Object, Codable {
    @objc dynamic var id: String = ""
    @objc dynamic var text: String = ""
    @objc dynamic var date: String = ""
    @objc dynamic var timestamp: TimeInterval = 0.0
    @objc dynamic var likes: Int = 0
    
    override static func primaryKey() -> String? {
            return "id"
        }
}
