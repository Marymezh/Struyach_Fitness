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
    
   func sendPush(with token: String, push: UserPush, completion: @escaping (Bool) -> Void) {
            guard let url = URL(string: "https://fcm.googleapis.com/fcm/send") else { return }
            
            let json: [String:Any] = [
                "to": token,
                "notification": [
                    "title": "\(push.title)",
                    "body": "\(push.body)"
                ]
            ]
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("key=\(K.pushAuthKey)", forHTTPHeaderField: "Authorization")
            
            let session = URLSession(configuration: .default)
            session.dataTask(with: request, completionHandler: { _, _, error in
                completion(error == nil)
            }).resume()
        }
}
