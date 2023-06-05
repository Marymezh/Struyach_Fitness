//
//  AuthManager.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import Foundation
import FirebaseAuth

enum AuthError: Error {
    case emailAlreadyExists
    case passwordTooShort
    case unknownError
}

final class AuthManager {
    
    static let shared = AuthManager()
    private let auth = Auth.auth()
    public var userId = Auth.auth().currentUser?.email
    public var userUID = Auth.auth().currentUser?.uid
    public var isSignedIn: Bool {
        return auth.currentUser != nil
    }
    
    private init() {}
    
    public func signUp(email: String, password: String, completion: @escaping (Result<Void, AuthError>) -> ()) {
            
            auth.fetchSignInMethods(forEmail: email) { signInMethods, error in
                if error != nil {
                    completion(.failure(.unknownError))
                    return
                }
                
                if let signInMethods = signInMethods, !signInMethods.isEmpty {
                    completion(.failure(.emailAlreadyExists))
                    return
                }
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
    
    public func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> ()) {
            guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
                  !password.trimmingCharacters(in: .whitespaces).isEmpty,
                  password.count >= 6 else {return}
            
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
}
