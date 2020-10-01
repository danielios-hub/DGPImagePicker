//
//  ExtensionPHCachingImageManager.swift
//  DGPImagePicker
//
//  Created by Daniel Gallego Peralta on 13/07/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import UIKit
import Photos

extension PHCachingImageManager {
    
    private func photoImageRequestOptions() -> PHImageRequestOptions {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.resizeMode = .exact
        options.isSynchronous = true // Ok since we're already in a background thread
        return options
    }
    
    func fetchImage(for asset: PHAsset, cropRect: CGRect? = nil, targetSize: CGSize? = nil, callback: @escaping (UIImage, [String: Any]) -> Void) {
        let options = photoImageRequestOptions()
    
        requestImageDataAndOrientation(for: asset, options: options) { (data, dataUTI, CTFontOrientation, info) in
            if let data = data, let image = UIImage(data: data)?.resetOrientation() {
                
                guard let cropRect = cropRect, let targetSize = targetSize else {
                    let exifs = self.metadataForImageData(data: data)
                    callback(image, exifs)
                    return
                }
                
                // Crop the high quality image manually.
                let xCrop: CGFloat = cropRect.origin.x * CGFloat(asset.pixelWidth)
                let yCrop: CGFloat = cropRect.origin.y * CGFloat(asset.pixelHeight)
                let scaledCropRect = CGRect(x: xCrop,
                                            y: yCrop,
                                            width: targetSize.width,
                                            height: targetSize.height)
                if let imageRef = image.cgImage?.cropping(to: scaledCropRect) {
                    let croppedImage = UIImage(cgImage: imageRef)
                    let exifs = self.metadataForImageData(data: data)
                    callback(croppedImage, exifs)
                }
            }
        }
    }
    
    private func metadataForImageData(data: Data) -> [String: Any] {
        if let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
        let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil),
        let metaData = imageProperties as? [String : Any] {
            return metaData
        }
        return [:]
    }
    
    func fetchPreviewFor(video asset: PHAsset, callback: @escaping (UIImage) -> Void) {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.isSynchronous = true
        let screenWidth = UIScreen.main.bounds.width
        let ts = CGSize(width: screenWidth, height: screenWidth)
        requestImage(for: asset, targetSize: ts, contentMode: .aspectFill, options: options) { image, _ in
            if let image = image {
                DispatchQueue.main.async {
                    callback(image)
                }
            }
        }
    }
    
    func fetchPlayerItem(for video: PHAsset, callback: @escaping (AVPlayerItem) -> Void) {
        let videosOptions = PHVideoRequestOptions()
        videosOptions.deliveryMode = PHVideoRequestOptionsDeliveryMode.automatic
        videosOptions.isNetworkAccessAllowed = true
        requestPlayerItem(forVideo: video, options: videosOptions, resultHandler: { playerItem, _ in
            DispatchQueue.main.async {
                if let playerItem = playerItem {
                    callback(playerItem)
                }
            }
        })
    }
    
    /// This method return two images in the callback. First is with low resolution, second with high.
    /// So the callback fires twice.
    func fetch(photo asset: PHAsset, callback: @escaping (UIImage, Bool) -> Void) {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true // Enables gettings iCloud photos over the network, this means PHImageResultIsInCloudKey will never be true.
        options.deliveryMode = .opportunistic // Get 2 results, one low res quickly and the high res one later.
        requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: options) { result, info in
            guard let image = result else {
                print("No Result 🛑")
                return
            }
            DispatchQueue.main.async {
                let isLowRes = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
                callback(image, isLowRes)
            }
        }
    }
}
