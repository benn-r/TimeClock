//
//  Utilities.swift
//  CCGTime
//
//  Created by ben on 4/7/24.
//

import Foundation
import FirebaseAuth

class User: ObservableObject {
    
    init() {
        
    }
    
    func isLoggedIn() -> Bool {
        if Auth.auth().currentUser != nil {
            // User is signed in.
            print("User is logged in")
            return true
        } else {
            // No user is signed in.
            print("User is NOT logged in")
            return false
        }
    }
    
    func login(user: String, pass: String) {
        Auth.auth().signIn(withEmail: user, password: pass)
    }
    
    func createAccount(user: String, pass: String) {
        Auth.auth().createUser(withEmail: user, password: pass, completion: { result,error  in
            print("error: \(error)")
            print("result \(result)")
            
        })
    }
    
}
