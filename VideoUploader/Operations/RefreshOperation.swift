//
//  RefreshOperation.swift
//  VideoUploader
//
//  Created by Elena Kim on 1/5/24.
//

import Foundation

final class RefreshOperation: AsyncOperation {
    private let youtubeService = YoutubeService.shared
    private let viewModel: YoutubeViewModel
    
    init(viewModel: YoutubeViewModel) {
        self.viewModel = viewModel
    }
    
    override func main() {
        viewModel.syncAllVideos { [weak self] in
            self?.viewModel.getUploadOperations()
            self?.state = .finished
        }
    }
    
}
