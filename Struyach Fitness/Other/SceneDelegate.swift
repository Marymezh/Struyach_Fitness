//
//  SceneDelegate.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit
import IQKeyboardManagerSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var originalNavigationStack: [UIViewController] = []
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        var vc: UIViewController?
        let hasAgreedToPrivacyPolicy = UserDefaults.standard.bool(forKey: "HasAgreedToPrivacyPolicy")
        
        UNUserNotificationCenter.current().delegate = self
        
        if AuthManager.shared.isSignedIn  && hasAgreedToPrivacyPolicy {
           
            let userEmail = UserDefaults.standard.string(forKey: "email")
            if let email = userEmail, !email.isEmpty {
                print ("there is a current user with data")
                vc = TabBarController()
            } else {
                // user is signed in but there is no user data for him or her, need to logout user and present loginVC
                print ("user is signed in but there is no user data for him or her, need to logout user and present loginVC")
                AuthManager.shared.signOut { success in
                    if success {
                        let signInVC = LoginViewController()
                        signInVC.navigationItem.largeTitleDisplayMode = .never
                        let navVC = UINavigationController(rootViewController: signInVC)
                        navVC.navigationBar.prefersLargeTitles = false
                        vc = navVC
                    } else {
                        print ("error loging out user without data")
                    }
                }
            }
        } else {
            //user is not signed in
            let signInVC = LoginViewController()
            signInVC.navigationItem.largeTitleDisplayMode = .never
            let navVC = UINavigationController(rootViewController: signInVC)
            navVC.navigationBar.prefersLargeTitles = false
            vc = navVC
        }
        
        if let navVC = vc as? UINavigationController {
                   originalNavigationStack = navVC.viewControllers
               }
        
        window.rootViewController = vc
        window.makeKeyAndVisible()
        self.window = window
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(CommentsViewController.self)
        IQKeyboardManager.shared.disabledToolbarClasses.append(CommentsViewController.self)
        IQKeyboardManager.shared.toolbarTintColor = .contrastGreen
        
        print ("lastCheckedDate: \(UserDefaults.standard.value(forKey: "lastCheckedDate") ?? "No date")")
        checkAppVersion()
        
    }
    
    func checkAppVersion() {
        let cacheExpirationInterval: TimeInterval = 7 * 24 * 60 * 60

        if let lastCheckedDate = UserDefaults.standard.object(forKey: "lastCheckedDate") as? Date {
              if Date().timeIntervalSince(lastCheckedDate) < cacheExpirationInterval {
                  return
              }
          }

          if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
              print("Current app version: \(appVersion)")
#if Admin
               let appId = "6449380820"
#else
               let appId = "6448619309"
#endif
               let iTunesLookupURL = URL(string: "https://itunes.apple.com/lookup?id=\(appId)")!
               URLSession.shared.dataTask(with: iTunesLookupURL) { [weak self] (data, response, error) in
                   guard let self = self else {return}
                   if let data = data {
                                  do {
                                      let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                                      if let results = json?["results"] as? [[String: Any]], let latestVersion = results.first?["version"] as? String {
                                          print("Latest version: \(latestVersion)")
                                          if appVersion < latestVersion {
                                              self.showUpdateAlert()
                                          } else {
                                              print("App version is up to date")
                                          }
                                          let currentDate = Date()
                                          UserDefaults.standard.set(currentDate, forKey: "lastCheckedDate")
                                      }
                                  } catch {
                                      print("Error parsing JSON response: \(error)")
                                  }
                              }
                          }.resume()
                      }
                  }
    
    func showUpdateAlert() {
        AlertManager.shared.showAlert(title: "Update Available".localized(), message: "A new version of the app is available! Tap \"Update\" to find out more on our app's page.".localized(), continueAction: "Update".localized(), continueCompletion: { _ in
            #if Admin
            let urlString = "itms-apps://itunes.apple.com/app/id6449380820"
            #else
            let urlString = "itms-apps://itunes.apple.com/app/id6448619309"
            #endif
            if let appStoreURL = URL(string: urlString) {
                UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
            }
        }, cancelAction: "Cancel".localized())
    }
}

extension SceneDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print ("responding to notification tap")
        let notificationInfo = response.notification.request.content.userInfo
  //      let navVC = UINavigationController()
        let tabBarController = TabBarController()
        window?.rootViewController = tabBarController
        if let pushType = notificationInfo["notificationType"] as? String {
            print(pushType)
            switch pushType {
            case "postComment":
                if let postId = notificationInfo["destination"] as? String {
                    DatabaseManager.shared.fetchBlogPost(postId: postId) { post in
                        if let post = post {
                            let commentsVC = CommentsViewController(blogPost: post)
                            commentsVC.title = "Comments".localized()
                            commentsVC.navigationItem.backButtonTitle = "Back".localized()
                            tabBarController.selectedIndex = 1
                            if let blogVC = tabBarController.selectedViewController as? UINavigationController {
                                blogVC.pushViewController(commentsVC, animated: true)
                            }
                        }
                        //                            navVC.pushViewController(commentsVC, animated: true)
                    }
                }
            case "workoutComment":
                if let workoutId = notificationInfo["destination"] as? String,
                   let programId = notificationInfo["collectionId"] as? String {
                    DatabaseManager.shared.fetchWorkout(programId: programId, workoutId: workoutId) { workout in
                        if let workout = workout {
                            let commentsVC = CommentsViewController(workout: workout)
                            commentsVC.title = "Comments".localized()
                            commentsVC.navigationItem.backButtonTitle = "Back".localized()
                            tabBarController.selectedIndex = 0
                            if let programsVC = tabBarController.selectedViewController as? UINavigationController {
                                let workoutVC = WorkoutsViewController()
                                workoutVC.title = programId.localized()
                                programsVC.pushViewController(workoutVC, animated: true)
                                programsVC.pushViewController(commentsVC, animated: true)
                            }
                        }
                    }
                }
            default:
                if let programName = notificationInfo["destination"] as? String {
                    tabBarController.selectedIndex = 0
                   if let programsVC = tabBarController.selectedViewController as? UINavigationController{
                        let workoutVC = WorkoutsViewController()
                        workoutVC.title = programName.localized()
                        programsVC.pushViewController(workoutVC, animated: true)
                    }
                }
            }
        } else {
            print("Error receiving notification type")
        }
        
//        if AuthManager.shared.isSignedIn {
//            window?.rootViewController = navVC
//        }
    }
}

