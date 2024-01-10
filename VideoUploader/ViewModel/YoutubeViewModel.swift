//
//  YoutubeViewModel.swift
//  VideoUploader
//
//  Created by Elena Kim on 12/13/23.
//

import Photos
import GoogleAPIClientForREST
import BackgroundTasks

class YoutubeViewModel: ObservableObject {
    private let youtubeService = YoutubeService.shared
    private let taskIdentifier = "com.elenakim.VideoUploader.upload"
    
    @Published var currentUser: User = User() {
        didSet {
            if currentUser.isLoggedIn {
                self.syncAllVideos(completion: nil)
            }
        }
    }
    
    @Published var youtubeUploadedVideoList: [GTLRYouTube_PlaylistItem] = []
    @Published var deviceVideoList: [PHAsset] = []
    @Published var syncDeviceVideoList: [DeviceVideo] = []
    private var uploadOperations: [UploadAsyncOperation] = []
    private let operationQueue: OperationQueue = OperationQueue()
    
    init() {
        operationQueue.maxConcurrentOperationCount = 1
        checkPermissions()
    }
    
    //MARK: Checking up
    func restoreSighIn() {
        self.youtubeService.restorePreviosSignIn { user in
            guard let safeUser = user else {
                self.signOut()
                self.getDeviceVideoList { assetList in
                    self.syncDeviceVideoList = assetList.map { DeviceVideo(isUploaded: false, asset: $0)}
                }
                return
            }
            self.currentUser = safeUser
        }
    }
    
    func checkPermissions() {
        PHPhotoLibrary.requestAuthorization(for: PHAccessLevel.readWrite) { status in
            switch status {
            case .notDetermined,.restricted, .denied:
                //TODO: show alert
                return
            case .authorized, .limited:
                self.restoreSighIn()
            @unknown default:
                return
            }
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
    }
    
    //MARK: Sign in
    func signIn() {
        self.youtubeService.signIn { user in
            guard let safeUser = user else { return }
            self.currentUser = safeUser
        }
    }
    
    func signOut() {
        self.youtubeService.signOut()
        self.currentUser = User()
    }
    
    //MARK: Youtube
    func getUploadedVideosList(completion: @escaping ()-> Void) {
        self.youtubeService.getAllUploadedVideos { result in
            switch result {
            case .success(let playlistItems):
                self.youtubeUploadedVideoList = playlistItems
                completion()
            case .failure(let error):
                completion()
            }
        }
    }
    
    func uploadVideoToYoutube(video: DeviceVideo, completion: @escaping(Error?) -> Void, progressBlock: GTLRServiceUploadProgressBlock?, asOperation: Bool) {
        PhotosService.getVideoURL(for: video.asset) { [weak self] url in
            guard let videoUrl = url else { return }
            if asOperation {
                let op = UploadAsyncOperation(operationId: video.asset.localIdentifier, url: videoUrl, title: video.title, completion: completion, progressBlock: progressBlock)
                self?.uploadOperations.append(op)
            } else {
                self?.youtubeService.uploadVideo(for: videoUrl, with: video.title, completion: completion, progressBlock: progressBlock)
            }
        }
    }
    
    //MARK: Device
    func getDeviceVideoList(completion: @escaping ([PHAsset])-> Void) {
        PhotosService.fetchVideos {videoList in
            completion(videoList)
        }
    }
    
    //MARK: Synchronization
    func compareVideos() {
        self.syncDeviceVideoList = []
        let arrayYTTitles = Set(self.youtubeUploadedVideoList.compactMap { $0.snippet?.title })
        let notUploaded = self.deviceVideoList.filter { !arrayYTTitles.contains($0.value(forKey: "filename" as String) as! String)}.map { DeviceVideo(isUploaded: false, asset: $0)}
        let uploaded = self.deviceVideoList.filter { arrayYTTitles.contains($0.value(forKey: "filename" as String) as! String)}.map { DeviceVideo(isUploaded: true, asset: $0)}
        let list = notUploaded + uploaded
        self.syncDeviceVideoList = list.sorted(by: { $0.asset.creationDate ?? Date() > $1.asset.creationDate ?? Date()})
    }
    
    func syncAllVideos(completion: (() -> Void)?) {
        let group = DispatchGroup()
        group.enter()
        self.getUploadedVideosList {
            group.leave()
        }
        group.enter()
        self.getDeviceVideoList { [weak self] videoList in
            self?.deviceVideoList = videoList
            group.leave()
        }
        group.notify(queue: .main) {
            self.compareVideos()
            completion?()
        }
    }
    
    //MARK: Schedule background task
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: self.taskIdentifier)
        // Fetch no earlier than 30 minutes from now.
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Submitted task request")
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    private func handleAppRefresh(task: BGTask) {
        let operation = uploadOperations.first ?? RefreshOperation(viewModel: self)
        task.expirationHandler = {
            operation.cancel()
        }
        operation.completionBlock = {
            task.setTaskCompleted(success: !operation.isCancelled)
            
        }
        operationQueue.addOperation(operation)
        self.uploadOperations.removeFirst()
        scheduleAppRefresh()
    }
    
    func registerBGTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: self.taskIdentifier, using: nil) { task in
            self.handleAppRefresh(task: task)
        }
    }
    
    func getUploadOperations() {
        let notUploaded = self.syncDeviceVideoList.filter({ !$0.isUploaded })
        for video in notUploaded {
            uploadVideoToYoutube(video: video, completion: { error in
                video.isUploaded = error == nil
                error == nil ? NotificationService.sendPush(body: "Video \(video.title) is uploaded") : NotificationService.sendPush(body: "Error upload video \(video.title)")
            }, progressBlock: nil, asOperation: true)
        }
    }
    
    func removeOperation(id: String) {
        self.uploadOperations.removeAll { $0.id == id }
    }
    
}
