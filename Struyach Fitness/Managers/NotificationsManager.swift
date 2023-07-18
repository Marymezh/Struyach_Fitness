//
//  NotificationsManager.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 19/5/23.
//

import Foundation
import UserNotifications
import FirebaseMessaging
import UIKit

final class NotificationsManager {
    
    static let shared = NotificationsManager()
    private let messaging = Messaging.messaging()
    
    public var coachToken: String {
      get {
        guard let filePath = Bundle.main.path(forResource: "Admin-Info", ofType: "plist") else {
          fatalError("Couldn't find file 'Admin-Info.plist'.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "CoachToken") as? String else {
          fatalError("Couldn't find key 'CoachToken' in 'Admin-Info.plist'.")
        }
        return value
      }
    }
    
    private var pushAuthKey: String {
        get {
          guard let filePath = Bundle.main.path(forResource: "Admin-Info", ofType: "plist") else {
            fatalError("Couldn't find file 'Admin-Info.plist'.")
          }
          let plist = NSDictionary(contentsOfFile: filePath)
          guard let value = plist?.object(forKey: "pushAuthKey") as? String else {
            fatalError("Couldn't find key 'pushAuthKey' in 'Admin-Info.plist'.")
          }
          return value
        }
      }
    
    
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
    
   public func checkNotificationPermissions() -> Bool {
        let semaphore = DispatchSemaphore(value: 0)
        var isAllowed = false

        UNUserNotificationCenter.current().getNotificationSettings { settings in
            isAllowed = settings.authorizationStatus == .authorized
            semaphore.signal()
        }

        semaphore.wait()
        return isAllowed
    }
    
  public func sendPush(withToken token: String, push: UserPush, completion: @escaping (Bool) -> Void) {
            guard let url = URL(string: "https://fcm.googleapis.com/fcm/send") else { return }
            
            let json: [String:Any] = [
                "to": token,
                "notification": [
                    "title": "\(push.title)",
                    "body": "\(push.body)"
                ],
                "data": [
                    "notificationType": "\(push.type)",
                    "destination": "\(push.destination)",
                    "collectionId": "\(push.collectionId ?? "no id")"
                ]
            ]
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("key=\(pushAuthKey)", forHTTPHeaderField: "Authorization")
            
            let session = URLSession(configuration: .default)
            session.dataTask(with: request, completionHandler: { _, _, error in
                completion(error == nil)
            }).resume()
        }
    
    public func sendPush(toTopic topic: String, push: UserPush, completion: @escaping (Bool) -> Void) {
        print("sending push to topic")
        guard let url = URL(string: "https://fcm.googleapis.com/fcm/send") else { return }
        
        let json: [String:Any] = [
            "to": "/topics/\(topic)",
            "notification": [
                "title": "\(push.title)",
                "body": "\(push.body)"
            ],
            "data": [
                "notificationType": "\(push.type)",
                "destination": "\(push.destination)",
                "collectionId": "\(push.collectionId ?? "no id")"
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(pushAuthKey)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: request, completionHandler: { _, _, error in
            completion(error == nil)
        }).resume()
    }
}
