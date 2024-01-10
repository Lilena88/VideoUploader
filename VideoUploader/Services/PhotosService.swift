//
//  PhotosService.swift
//  VideoUploader
//
//  Created by Elena Kim on 12/19/23.
//

import Photos
import UIKit

class PhotosService {
    
    static func fetchVideos(completion: @escaping(([PHAsset]) -> Void)){
        let queue = DispatchQueue(label: "Fetching videos", qos: .userInitiated, attributes: .concurrent)
        queue.async {
            let fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.video, options: nil)
            
            var videoAssets: [PHAsset] = []
            fetchResult.enumerateObjects { asset, _, _ in
                videoAssets.append(asset)
            }
            
            DispatchQueue.main.async {
                completion(videoAssets)
            }
        }
    }
    
    static func getVideoURL(for video: PHAsset, completion: @escaping (URL?) -> Void) {
        let requestOptions = PHVideoRequestOptions()
        requestOptions.isNetworkAccessAllowed = false
        
        PHImageManager.default().requestAVAsset(forVideo: video, options: requestOptions) { avAsset, _, _ in
            guard let urlAsset = avAsset as? AVURLAsset else {
                completion(nil)
                return
            }
            
            let videoURL = urlAsset.url
            completion(videoURL)
        }
    }
    
    static func playerItem(for asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 30, height: 30), contentMode: .aspectFill, options: nil) { image, _ in
            completion(image)
        }
    }
}
