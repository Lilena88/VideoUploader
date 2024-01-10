//
//  DeviceVideo.swift
//  VideoUploader
//
//  Created by Elena Kim on 12/21/23.
//

import Photos

class DeviceVideo {
    var isUploaded: Bool
    let asset: PHAsset
    var title: String {
        return asset.value(forKey: "filename") as? String ?? ""
    }
    
    init(isUploaded: Bool, asset: PHAsset) {
        self.isUploaded = isUploaded
        self.asset = asset
    }
}
