//
//  Comment.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 9/2/23.
//

import Foundation
import MessageKit

struct Comment: MessageType {    
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
    let userImage: Data
    let workoutId: String?
    let programId: String?
}

extension MessageKind {
    var messageKindString: String {
        switch self {
        case .text(_): return "text"
        case .attributedText(_): return "attributed_text"
        case .photo(_): return "photo"
        case .video(_): return "video"
        case .audio(_): return "audio"
        default: return ""
        }
    }
}

