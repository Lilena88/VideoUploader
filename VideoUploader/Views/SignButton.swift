//
//  SignButton.swift
//  VideoUploader
//
//  Created by Elena Kim on 1/5/24.
//

import SwiftUI

struct SignButton: View {
    @Binding var isLoggedIn: Bool
    var signOutAction: () -> Void
    var signInAction: () -> Void
    
    var body: some View {
        HStack {
            if isLoggedIn {
                Button(action: signOutAction) {
                    Text("Sign out")
                        .fontWeight(.semibold)
                        .padding()
                        
                }
            } else {
                Button(action: signInAction) {
                    Text("Sign in")
                        .fontWeight(.semibold)
                        .padding()
                }
            }
        }
    }
    
}
