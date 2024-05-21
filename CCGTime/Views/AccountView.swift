//
//  AccountView.swift
//  CCGTime
//
//  Created by ben on 4/21/24.
//

import SwiftUI

struct AccountView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @StateObject var session : SessionStore
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Name")
                    .bold()
                    .font(.system(size:24))
                Text(session.session?.displayName ?? "No Name Found")
                
                Text("Email")
                    .bold()
                    .font(.system(size:24))
                Text((session.session?.email ?? "No Email Found"))
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
                        if session.signOut() {
                            Alert.message("Success!", "You are now signed out.")
                        }
                    } label: {
                        Text("Sign Out")
                    }
                    
                }
            }
        }
    }
}

#Preview {
    AccountView(session: SessionStore())
}
