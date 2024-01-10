//
//  VideoUploaderApp.swift
//  VideoUploader
//
//  Created by Elena Kim on 9/4/23.
//

import SwiftUI
import GoogleSignIn

@main
struct VideoUploaderApp: App {
    @StateObject var userAuth: YoutubeViewModel =  YoutubeViewModel()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification), perform: { _ in
                    userAuth.scheduleAppRefresh()
                })
                .environmentObject(userAuth)
                .navigationViewStyle(.stack)
            
        }
    }
}

