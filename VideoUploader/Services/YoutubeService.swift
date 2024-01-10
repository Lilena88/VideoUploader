//
//  YoutubeService.swift
//  VideoUploader
//
//  Created by Elena Kim on 12/13/23.
//

import Foundation
import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher


final class YoutubeService {
    static let shared = YoutubeService()
    private var service: GTLRYouTubeService
    
    private init() {
        service = GTLRYouTubeService()
        service.apiKey = "API KEY"
    }
    
    func restorePreviosSignIn(completion: @escaping (User?) -> Void) {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error = error {
                completion(nil)
            }
            if let safeUser = user, let profile = safeUser.profile {
                self.service.authorizer = safeUser.fetcherAuthorizer
                let currentUser = User(username: profile.name, profileImageUrl: profile.imageURL(withDimension: 30), isLoggedIn: true)
                completion(currentUser)
            }
        }
    }
    
    func signIn(completion: @escaping (User?) -> Void) {
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else { return }
        let youtubeScope = kGTLRAuthScopeYouTube
        let signInConfig = GIDConfiguration.init(clientID: "Client ID")
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController, hint: nil, additionalScopes: [youtubeScope]) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    ErrorPublisher.shared.sendError(error)
                    completion(nil)
                }
                
                if let safeResult = result, let profile = safeResult.user.profile {
                    let user = User(username: profile.name, profileImageUrl: profile.imageURL(withDimension: 20), isLoggedIn: true)
                    self.service.authorizer = safeResult.user.fetcherAuthorizer
                    completion(user)
                }
            }
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
    }
    
    private func fetchChannel(completion: @escaping(Result<GTLRYouTube_Channel, Error>)->Void) {
        let query = GTLRYouTubeQuery_ChannelsList.query(withPart: ["contentDetails"])
        query.mine = true
        service.executeQuery(query) { _, result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let channelListResponse = result as? GTLRYouTube_ChannelListResponse,
               let mychannel = channelListResponse.items?.first {
                completion(.success(mychannel))
            }
        }
    }
    
    private func getUploadedVideos(channel: GTLRYouTube_Channel, completion: @escaping(Result<[GTLRYouTube_PlaylistItem], Error>)->Void) {
        let query = GTLRYouTubeQuery_PlaylistItemsList.query(withPart: ["snippet","contentDetails"])
        query.playlistId = channel.contentDetails?.relatedPlaylists?.uploads
        query.maxResults = 50
        service.executeQuery(query) { _, result, error in
            if let error = error {
                ErrorPublisher.shared.sendError(error)
                return
            }
            
            if let videoListResult = result as? GTLRYouTube_PlaylistItemListResponse,
               let items = videoListResult.items {
                completion(.success(items))
            }
        }
    }
    
    func getAllUploadedVideos(completion: @escaping(Result<[GTLRYouTube_PlaylistItem], Error>)->Void) {
        self.fetchChannel { result in
            switch result {
            case .success(let channel):
                self.getUploadedVideos(channel: channel) { result in
                    completion(result)
                }
            case .failure(let error):
                ErrorPublisher.shared.sendError(error)
                completion(.failure(error))
                
            }
        }
    }
    
    func uploadVideo(for videoURL: URL, with title: String, completion: @escaping(Error?) -> Void, progressBlock: GTLRServiceUploadProgressBlock?) {
        let status = GTLRYouTube_VideoStatus()
        status.privacyStatus = "private"
        status.madeForKids = false
        let snippet = GTLRYouTube_VideoSnippet()
        snippet.title = title
        let video = GTLRYouTube_Video()
        video.status = status
        video.snippet = snippet
        
        let parameters = GTLRUploadParameters(fileURL: videoURL, mimeType: "video/mov")
        parameters.useBackgroundSession = true
        let query = GTLRYouTubeQuery_VideosInsert.query(withObject: video, part: ["snippet", "status"], uploadParameters: parameters)
        query.executionParameters.uploadProgressBlock = progressBlock
        service.executeQuery(query) { ticket, result, error in
            if let error = error {
                ErrorPublisher.shared.sendError(error)
                completion(error)
                return
            } else {
                completion(nil)
            }
        }
    }
    
}

