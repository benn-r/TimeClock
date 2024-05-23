//
//  AuthModel.swift
//  CCGTime
//
//  Created by ben on 5/21/24.
//

import Foundation
import LocalAuthentication

class AuthModel: ObservableObject {
    
    @Published var isUnlocked : Bool = false
    
    func lock() {
        self.isUnlocked = false
    }
    
    func authenticate() {
        if isUnlocked == false {
            let context = LAContext()
            var error: NSError?
            
            // check whether biometric authentication is possible
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                // it's possible, so go ahead and use it
                let reason = "To protect the manager section of the app."
                
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                    // authentication has now completed
                    DispatchQueue.main.async {
                        if success {
                            self.isUnlocked = true
                        } else {
                            self.isUnlocked = false
                            Alert.message("Authentication Error", authenticationError.debugDescription)
                        }
                    }
                }
            } else {
                // no biometrics
            }
        // runs isUnlocked is true
        } else {
            print("View is already unlocked")
        }
    }
}
