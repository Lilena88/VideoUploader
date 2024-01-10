//
//  UploadAsyncOperation.swift
//  VideoUploader
//
//  Created by Elena Kim on 12/29/23.
//

import Foundation
import GoogleAPIClientForREST

final class UploadAsyncOperation: AsyncOperation {
    let id: String
    private let youtubeService = YoutubeService.shared
    private let url: URL
    private let title: String
    private let completion: (Error?) -> Void
    private let progressBlock: GTLRServiceUploadProgressBlock?
    
    init(operationId: String, url: URL, title: String, completion: @escaping (Error?) -> Void, progressBlock: GTLRServiceUploadProgressBlock?) {
        self.url = url
        self.title = title
        self.completion = completion
        self.progressBlock = progressBlock
        self.id = operationId
        super.init()
    }
    
    override func main() {
        youtubeService.uploadVideo(for: url, with: title, completion: { [weak self] error in
            guard let self else { return }
            defer { self.state = .finished }
            completion(error)
        }, progressBlock: progressBlock)
    }
}
