//
//  User.swift
//  VideoUploader
//
//  Created by Elena Kim on 1/9/24.
//

import Foundation

struct User {
    let username: String
    let profileImageUrl: URL?
    var isLoggedIn: Bool
    
    init(username: String = "Not Logged in", profileImageUrl: URL? = nil, isLoggedIn: Bool = false) {
        self.username = username
        self.profileImageUrl = profileImageUrl
        self.isLoggedIn = isLoggedIn
    }
}
