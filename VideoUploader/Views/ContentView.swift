//
//  ContentView.swift
//  VideoUploader
//
//  Created by Elena Kim on 9/4/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: YoutubeViewModel
    @State private var error: Error?
    @State private var isPresentedError: Bool = false
    
    var body: some View {
        NavigationView {
            VStack{
                List(vm.syncDeviceVideoList, id: \.asset.localIdentifier) { video in
                    VideoThumbnail(video: video, vm: _vm)
                }
                .listStyle(.inset)
                .navigationBarTitleDisplayMode(.inline)
                .refreshable { vm.syncAllVideos(completion: nil) }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        ProfileInfo(vm: _vm)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        SignButton(isLoggedIn: $vm.currentUser.isLoggedIn, signOutAction: {
                            vm.signOut()
                        }, signInAction: { vm.signIn()
                        })
                    }
                }
            }
            .onAppear {
                vm.registerBGTask()
            }
            .onReceive(ErrorPublisher.shared.$error, perform: { error in
                if let safeError = error {
                    self.error = safeError
                    self.isPresentedError = true
                }
            })
           .alert("Error", isPresented: $isPresentedError) {
                Button("Ok") {
                    self.isPresentedError = false
                }
            } message: {
                Text(self.error?.localizedDescription ?? "")
            }
        }
    }

}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(YoutubeViewModel())
    }
}
