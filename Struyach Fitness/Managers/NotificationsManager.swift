//
//  NotificationsManager.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 19/5/23.
//

import Foundation
import UserNotifications
import FirebaseMessaging

final class NotificationsManager {
    
    static let shared = NotificationsManager()
    private let messaging = Messaging.messaging()
    
    private init() {}
    
    public func subscribe(to topic: String) {
        messaging.subscribe(toTopic: topic) { error in
            if error != nil {
                print ("error subscribing to a topic: \(topic)")
            } else {
                print("Subscribed to \(topic) topic")
            }
          
        }
    }
    public func unsubscribe(from topic: String) {
        messaging.unsubscribe(fromTopic: topic) { error in
            if error != nil {
                print ("error unsubscribing from a topic: \(topic)")
            } else {
                print("Unsubscribed from \(topic) topic")
            }
          
        }
    }
    
    func checkNotificationPermissions() -> Bool {
        let semaphore = DispatchSemaphore(value: 0)
        var isAllowed = false

        UNUserNotificationCenter.current().getNotificationSettings { settings in
            isAllowed = settings.authorizationStatus == .authorized
            semaphore.signal()
        }

        semaphore.wait()
        return isAllowed
    }
}
