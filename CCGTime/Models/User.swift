//
//  User.swift
//  CCGTime
//
//  Created by ben on 4/7/24.
//

import Foundation
import Firebase
import FirebaseAuth
import SwiftUI
import Combine



class SessionStore : ObservableObject {
    
    @Published var session: User?
    
    var handle: AuthStateDidChangeListenerHandle?
    
    init () {
        self.listen()
    }
    
    func listen() {
        // monitor auth changes using firebase
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                // if we have a user, create a new user model
                print("Got user: \(user)")
                self.session = user
                
            } else {
                // if we don't have a user, set our session to nil
                self.session = nil
            }
            
        }
    }
    
    func signUp(
        email: String,
        password: String,
        firstName: String,
        lastName: String
        ) {
            Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
                if let error = error {
                    print("Error creating user: \(error)")
                    Alert.message("Error Creating Account", error.localizedDescription)
                    return
                }
                self.session = authResult?.user
                let changeRequest = self.session?.createProfileChangeRequest()
                changeRequest?.displayName = "\(firstName) \(lastName)"
                changeRequest?.commitChanges { error in
                    if let error = error {
                        print("Error Commiting Account Changes: \(error)")
                    } else {
                        print("Succesfully Signed Up")
                    }
                }
                
            })
        }
    
    func signIn(
        email: String,
        password: String
        ) {
            Auth.auth().signIn(withEmail: email, password: password, completion: { authResult, error in
                if let error = error {
                    print("Error Signing In: \(error)")
                    Alert.message("Error Signing In", error.localizedDescription)
                    return
                }
                self.session = authResult?.user
                print("Succesfully Signed In")
            })
        }
    
    func signOut() -> Bool {
        do {
            try Auth.auth().signOut()
            self.session = nil
            print("Succesfully Signed Out")
            return true
        } catch {
            print("Error Signing Out: \(error)")
            Alert.message("Error Signing Out", error.localizedDescription)
            return false
        }
    }
    
    func unbind() {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
