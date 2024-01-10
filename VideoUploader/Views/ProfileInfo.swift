//
//  ProfileInfo.swift
//  VideoUploader
//
//  Created by Elena Kim on 1/5/24.
//

import SwiftUI

struct ProfileInfo: View {
    @EnvironmentObject var vm: YoutubeViewModel
    
    var body: some View {
        HStack {
            profilePic()
            Text(vm.currentUser.username)

        }.onAppear {
            
        }
    }
    private func profilePic() -> some View {
        AsyncImage(url: vm.currentUser.profileImageUrl) {
            image in
            image.resizable()
        } placeholder: {
            Image(systemName: "person.circle.fill")
        }
        .frame(width: 20, height: 20)
        .cornerRadius(10)
    }
}
