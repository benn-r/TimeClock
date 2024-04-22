//
//  SignupView.swift
//  CCGTime
//
//  Created by ben on 4/8/24.
//

import SwiftUI

struct SignupView: View {
    
    @State var username: String = ""
    @State var password: String = ""
    @State var confirmpassword: String = ""
    
    @ObservedObject var user = User()
    
    var body: some View {
        VStack(alignment: .center, spacing: 25, content: {
            
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.cyan)
                    .frame(width: 400, height: 350)
                
                VStack {
                    Text("Sign up for TimeClock")
                        .font(.system(size: 36))
                        .bold()
                        .foregroundStyle(Color.white)
                    
                    TextField("Email", text: $username)
                        .frame(width: 200, height: 30)
                        .keyboardType(.emailAddress)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .strokeBorder(.blue, lineWidth: 2.25)
                                .scaleEffect(1.25)
                        )
                    
                    Spacer()
                        .frame(height: 18)
                    
                    SecureField("Password", text: $password)
                        .frame(width: 200, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .strokeBorder(.blue, lineWidth: 2.25)
                                //.fill(Color.blue)
                                .scaleEffect(1.25)
                        )
                    
                    Spacer()
                        .frame(height: 18)
                    
                    SecureField("Confirm Password", text: $confirmpassword)
                        .frame(width: 200, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .strokeBorder(.blue, lineWidth: 2.25)
                                //.fill(Color.blue)
                                .scaleEffect(1.25)
                        )
                }
            }
            
            Button("Create Account") {
                if (confirmpassword == password) {
                    user.createAccount(user: username, pass: password)
                } else {
                    Alert.error("Passwords do not match!")
                }
            }
            .foregroundColor(Color.white)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.black)
                    .scaleEffect(2.6)
            )
            
        })
    }
}

#Preview {
    SignupView()
}
