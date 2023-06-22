//
//  AuthManager.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import Foundation
import FirebaseAuth
import UIKit
import AuthenticationServices
import CryptoKit

enum AuthError: Error {
    case emailAlreadyExists
    case passwordTooShort
    case unknownError
}

protocol AuthManagerDelegate: AnyObject {
    func didCompleteAppleSignIn(with result: AuthDataResult)
}

final class AuthManager: NSObject {
    
    
    static let shared = AuthManager()
    private let auth = Auth.auth()
    public var userId = Auth.auth().currentUser?.email
    public var userUID = Auth.auth().currentUser?.uid
    public var isSignedIn: Bool {
        return auth.currentUser != nil
    }
    fileprivate var currentNonce: String?
    
    weak var delegate: AuthManagerDelegate?

    public func signUp(email: String, password: String, completion: @escaping (Result<Void, AuthError>) -> ()) {
        auth.fetchSignInMethods(forEmail: email) { signInMethods, error in
            if let error = error {
                print (error.localizedDescription)
                completion(.failure(.unknownError))
                return
            }
            
            if let signInMethods = signInMethods, !signInMethods.isEmpty {
                completion(.failure(.emailAlreadyExists))
                return
            }
            
            if password.count < 6 {
                completion(.failure(.passwordTooShort))
                return
            }
            
            self.auth.createUser(withEmail: email, password: password) { (authResult, error) in
                if let error = error {
                    print("Failed to sign up user: \(error.localizedDescription)")
                    completion(.failure(.unknownError))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    public func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> ()) {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              password.count >= 6 else { return }

        auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    
    public func signOut(completion: (Bool) -> ()) {
        do {
            try auth.signOut()
            completion(true)
        } catch {
            print(error)
            completion(false)
        }
    }
    
    public func deleteAccount(completion: @escaping (Result<Void, Error>) -> ()) {
        let user = Auth.auth().currentUser
        user?.delete { error in
            if let error = error {
                completion (.failure(error))
                print (error.localizedDescription)
            } else {
                completion(.success(()))
            }
        }
    }
    
    public func restorePassword(email: String, completion: @escaping (Result<Void, Error>) -> ()) {
        auth.sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    // MARK: - Sign-up with Apple
    
//    public func signUpWithApple(completion: @escaping (Result<Void, Error>) -> ()) {
    public func signUpWithApple() {
        let nonce = randomNonceString()
         currentNonce = nonce
         let appleIDProvider = ASAuthorizationAppleIDProvider()
         let request = appleIDProvider.createRequest()
         request.requestedScopes = [.fullName, .email]
         request.nonce = sha256(nonce)

         let authorizationController = ASAuthorizationController(authorizationRequests: [request])
         authorizationController.delegate = self
         authorizationController.presentationContextProvider = self
         authorizationController.performRequests()
    }
    
    // MARK: - Utility Methods
    
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      var randomBytes = [UInt8](repeating: 0, count: length)
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
      if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
      }

      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

      let nonce = randomBytes.map { byte in
        // Pick a random character from the set, wrapping around if needed.
        charset[Int(byte) % charset.count]
      }

      return String(nonce)
    }

    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }
}

extension AuthManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // Return the presentation anchor for the sign-in controller
        // This should be the window or view controller where the sign-in controller will be presented
        // Example: return UIApplication.shared.windows.first!
        // You may need to adjust this based on your app's UI structure
        // Make sure to return a valid presentation anchor to avoid crashes
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return window
        }
        
        fatalError("Unable to find a valid presentation anchor.")
    }
}

extension AuthManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            UserDefaults.standard.set(appleIDCredential.user, forKey: "appleAuthorizedUserIdKey")
                guard let nonce = currentNonce else {
                    fatalError("Invalid state: A login callback was received, but no login request was sent.")
                }
                guard let appleIDToken = appleIDCredential.identityToken else {
                    print("Unable to fetch identity token")
                    return
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                    return
                }
                let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: idTokenString,
                                                          rawNonce: nonce)
          auth.signIn(with: credential) { (authResult, error) in
            if let error = error {
              // Error. If error.code == .MissingOrInvalidNonce, make sure
              // you're sending the SHA256-hashed nonce as a hex string with
              // your request to Apple.
              print(error.localizedDescription)
              return
            }
              guard let authResult = authResult else {return}
              self.delegate?.didCompleteAppleSignIn(with: authResult)
            // User is signed in to Firebase with Apple.
            // ...
          }
        }
      }

//    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//        print ("authorizationController did Complete With Authorization")
//        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
//            print("Unable to retrieve Apple ID credential")
//            return
//        }
//
//        guard let idToken = appleIDCredential.identityToken,
//              let idTokenString = String(data: idToken, encoding: .utf8) else {
//            print("Unable to fetch identity token from Apple ID credential")
//            return
//        }
//
//        guard let nonce = currentNonce else {
//            print("Invalid state: A login callback was received, but no login request was sent.")
//            return
//        }
////
////        guard let appleIDTokenData = appleIDCredential.identityToken,
////              let appleIDToken = String(data: appleIDTokenData, encoding: .utf8) else {
////            print("Unable to fetch identity token from Apple ID credential")
////            return
////        }
//
//
//        // Authenticate user with Firebase using Apple credential
//        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
//
//        auth.signIn(with: credential) { [weak self] (authResult, error) in
//            print ("auth sign in with credential")
//            guard let self = self else {return}
//
//            if let error = error {
//                print("Failed to sign in user with Apple credential: \(error.localizedDescription)")
//                let message = String(format: "Unable to sign in with Apple: %@", error.localizedDescription)
//                AlertManager.shared.showAlert(title: "Error".localized(), message: message.localized(), cancelAction: "Ok")
//            } else {
//                // Sign-in successful
//                self.delegate?.didCompleteAppleSignIn(with: appleIDCredential)
//            }
//        }
//    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple errored: \(error.localizedDescription)")
        AlertManager.shared.showAlert(title: "Error".localized(), message: "Unable to sign in with Apple".localized(), cancelAction: "Ok")
    }
}
