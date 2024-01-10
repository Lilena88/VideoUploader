//
//  VideoThumbnail.swift
//  VideoUploader
//
//  Created by Elena Kim on 12/29/23.
//

import SwiftUI
import Photos

struct VideoThumbnail: View {
    let video: DeviceVideo
    @EnvironmentObject var vm: YoutubeViewModel
    @State private var placeholderImage = UIImage(named: "image1") ?? UIImage()
    @State private var isUploaded = false
    @State private var currentProgress: Double = 0
    @State private var uploading: Bool = false
    
    
    var body: some View {
        HStack {
            ZStack(alignment: Alignment(horizontal: .trailing, vertical: .bottom)) {
                Image(uiImage: placeholderImage)
                    .frame(width: 50, height: 50)
                    .cornerRadius(5.0)
                
                Text(video.asset.duration.formatTimeInterval(allowedUnits: [.minute, .second]) ?? "00:00")
                    .font(.system(size: 10))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(1), radius: 2, x: 0, y: 0)
                    .padding(2)
            }
            .onAppear {
                PhotosService.playerItem(for: video.asset) { image in
                    guard let safeImage = image else { return }
                    self.placeholderImage = safeImage
                }
            }
            VStack(alignment: .leading) {
                HStack {
                    Text(video.title)
                        .font(.system(size: 14))
                    Spacer()
                    Button {
                        uploading = true
                        self.upload(asOperation: false)
                    } label: {
                        Image(systemName: "icloud.and.arrow.up")
                            .font(.system(size: 15, weight: .semibold))
                            .accentColor(.blue)
                    }
                    .disabled(video.isUploaded || !vm.currentUser.isLoggedIn)
                    
                }
                if uploading {
                    ProgressView("Uploading...", value: currentProgress, total: 1.0)
                        .font(.system(size: 10))
                }
                if video.isUploaded {
                    Text("Uploaded")
                        .font(.system(size: 12))
                }
            }
        }
        .padding([.leading,.trailing], 10)
        .padding([.top, .bottom], 0)
        .onAppear {
            if !video.isUploaded {
                self.upload(asOperation: true)
            }
        }
        
    }
    private func upload(asOperation: Bool) {
        vm.uploadVideoToYoutube(
            video: video,
            completion: { error in
                video.isUploaded = error == nil
                uploading = false
                if error == nil {
                    NotificationService.sendPush(body: "Video \(video.title) uploaded ")
                    vm.removeOperation(id: video.asset.localIdentifier)
                } else {
                    NotificationService.sendPush(body: "Error upload video \(video.title)")
                }
            },
            progressBlock: { progress, totalBytesSent, totalBytesExpectedToSend in
                currentProgress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
            },
            asOperation: asOperation)
    }
    
}

struct VideoThumbnail_Previews: PreviewProvider {
    static var previews: some View {
        VideoThumbnail(video: DeviceVideo(isUploaded: true, asset: PHAsset())).environmentObject(YoutubeViewModel())
    }
}
