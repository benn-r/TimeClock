//
//  AccountView.swift
//  CCGTime
//
//  Created by ben on 4/21/24.
//

import SwiftUI

struct AccountView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var user = User()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Email")
                    .bold()
                    .font(.system(size:24))
                Text("\(user.getEmail())")
            }
            .navigationTitle("Account Settings")
            .toolbar {
                ToolbarItem(placement: .topBarLeading){
                    
                    Button {
                        self.presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Back")
                    }
                    
                }
                ToolbarItem(placement: .topBarTrailing) {
                    
                    Button {
                        
                    } label: {
                        Text("Sign Out")
                    }
                    
                }
            }
        }
    }
}

#Preview {
    AccountView()
}
