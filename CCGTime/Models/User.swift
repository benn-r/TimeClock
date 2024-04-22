//
//  Utilities.swift
//  CCGTime
//
//  Created by ben on 4/7/24.
//

import Foundation
import FirebaseAuth

class User: ObservableObject {
    
    var isLoggedIn: Bool = Auth.auth().currentUser == nil ? false : true
    
    init() {
        
    }
    
    func login(user: String, pass: String) {
        Auth.auth().signIn(withEmail: user, password: pass, completion: { result, error in
            print("error: \(error)")
            print("result \(result)")
            
            if (error == nil) {
                self.isLoggedIn = true
            }
        })
    }
    
    func createAccount(user: String, pass: String) {
        Auth.auth().createUser(withEmail: user, password: pass, completion: { result, error  in
            print("error: \(error)")
            print("result \(result)")
            
        })
    }
    
}
