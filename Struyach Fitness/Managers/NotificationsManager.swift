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
    
    
    
    
//    public func sendNotification(for workout: Workout, programName: String) {
//        // Create the notification content
//        let content = UNMutableNotificationContent()
//        content.title = "New Workout Posted"
//        content.body = "New workout \(workout.timestamp) for training plan \(programName) is posted"
//
//        // Create a unique identifier for the notification
//        let identifier = "NewWorkoutNotification"
//
//        // Create the notification trigger (can be immediate or scheduled)
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//
//        // Create the notification request
//        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
//
//        // Add the notification request to the notification center
//        UNUserNotificationCenter.current().add(request) { error in
//            if let error = error {
//                print("Error adding notification request: \(error)")
//            } else {
//                print("Notification request added successfully")
//            }
//        }
//    }
    
    
}
