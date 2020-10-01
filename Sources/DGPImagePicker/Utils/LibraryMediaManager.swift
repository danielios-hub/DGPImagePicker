//
//  LibraryMediaManager.swift
//  DGPImagePicker
//
//  Created by Daniel Gallego Peralta on 08/07/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import UIKit
import Photos

class LibraryMediaManager {
    weak var v: DGPViewLibrary?
    var collection: PHAssetCollection?
    internal var fetchResult: PHFetchResult<PHAsset>!
    internal var imageManager: PHCachingImageManager?
    
    internal var lastCacheFrameCenter: CGFloat = 0
    internal var numOffscreenAssetToCache = 60
    internal var cachedIndexed: [IndexPath] = []
    
    //internal var exportTimer: Timer?
    //internal var currentExportSessions: [AVAssetExportSession] = []
    
    func initialize() {
        imageManager = PHCachingImageManager()
        resetCachedAssets()
    }
    
    func resetCachedAssets() {
        imageManager?.stopCachingImagesForAllAssets()
        lastCacheFrameCenter = .zero
        cachedIndexed = []
    }
    
    func refreshMediaRequest() {
        let options = buildPHFetchOptions()
        
        if let collection = collection {
            fetchResult = PHAsset.fetchAssets(in: collection, options: options)
        } else {
            fetchResult = PHAsset.fetchAssets(with: options)
        }
    }
    
    func buildPHFetchOptions() -> PHFetchOptions {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.predicate = DGPConfig.shared.library.mediaType.predicate()
        return options
    }
    
    func PHCacheOptions() -> PHImageRequestOptions {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.resizeMode = .fast
        return options
    }
    
    func updateCachedAssets(in collectionView: UICollectionView) {
        let size = UIScreen.main.bounds.width/4 * UIScreen.main.scale
        let cellSize = CGSize(width: size, height: size)
        
        let currentFrameCenter = collectionView.bounds.midY
        let height = collectionView.bounds.height
        let visibleIndexes = collectionView.indexPathsForVisibleItems.sorted {
            $0.item < $1.item
        }
        
        //minimum offset before reload cache, half of collection view
        guard abs(currentFrameCenter - lastCacheFrameCenter) >= height/2.0,
            visibleIndexes.count > 0,
            let lastIndexPath = visibleIndexes.last else {
                return
        }
        
        lastCacheFrameCenter = currentFrameCenter
        
        let totalItemCount = fetchResult.count
        let firstItemToCache = max(visibleIndexes[0].item - numOffscreenAssetToCache/2, 0)
        let lastItemToCache = min(lastIndexPath.item + numOffscreenAssetToCache/2, totalItemCount - 1)
        
        var indexesToStartCaching : [IndexPath] = []
        var indexesToStopCaching : [IndexPath] = []
        
        for i in firstItemToCache..<lastItemToCache {
            let indexPath = IndexPath(item: i, section: 0)
            if !cachedIndexed.contains(indexPath) {
                indexesToStartCaching.append(indexPath)
            }
        }
        
        cachedIndexed.append(contentsOf: indexesToStartCaching)
        
        imageManager?.startCachingImages(for: assetsAtIndexPaths(indexesToStartCaching), targetSize: cellSize, contentMode: .aspectFill, options: PHCacheOptions())
        
        
        cachedIndexed = cachedIndexed.filter { indexPath -> Bool in
            if indexPath.item < firstItemToCache || indexPath.item > lastItemToCache {
                indexesToStopCaching.append(indexPath)
                return false
            }
            return true
        }
        
        imageManager?.stopCachingImages(for: assetsAtIndexPaths(indexesToStopCaching), targetSize: cellSize, contentMode: .aspectFill, options: PHCacheOptions())
    }
    
    /*
    func fetchVideoUrlAndCrop(for videoAsset: PHAsset, cropRect: CGRect, callback: @escaping (_ videoURL: URL?) -> Void) {
        let videosOptions = PHVideoRequestOptions()
        videosOptions.isNetworkAccessAllowed = true
        videosOptions.deliveryMode = .highQualityFormat
        imageManager?.requestAVAsset(forVideo: videoAsset, options: videosOptions) { asset, _, _ in
            do {
                guard let asset = asset else { print("⚠️ PHCachingImageManager >>> Don't have the asset"); return }
                
                let assetComposition = AVMutableComposition()
                let trackTimeRange = CMTimeRangeMake(start: CMTime.zero, duration: asset.duration)
                
                // 1. Inserting audio and video tracks in composition
                
                guard let videoTrack = asset.tracks(withMediaType: AVMediaType.video).first,
                    let videoCompositionTrack = assetComposition
                        .addMutableTrack(withMediaType: .video,
                                         preferredTrackID: kCMPersistentTrackID_Invalid) else {
                                            print("⚠️ PHCachingImageManager >>> Problems with video track")
                                            return
                                            
                }
                if let audioTrack = asset.tracks(withMediaType: AVMediaType.audio).first,
                    let audioCompositionTrack = assetComposition
                        .addMutableTrack(withMediaType: AVMediaType.audio,
                                         preferredTrackID: kCMPersistentTrackID_Invalid) {
                    try audioCompositionTrack.insertTimeRange(trackTimeRange, of: audioTrack, at: CMTime.zero)
                }
                
                try videoCompositionTrack.insertTimeRange(trackTimeRange, of: videoTrack, at: CMTime.zero)
                
                // Layer Instructions
                let layerInstructions = AVMutableVideoCompositionLayerInstruction(assetTrack: videoCompositionTrack)
                var transform = videoTrack.preferredTransform
                let videoSize = videoTrack.naturalSize.applying(transform)
                transform.tx = (videoSize.width < 0) ? abs(videoSize.width) : 0.0
                transform.ty = (videoSize.height < 0) ? abs(videoSize.height) : 0.0
                transform.tx -= cropRect.minX
                transform.ty -= cropRect.minY
                layerInstructions.setTransform(transform, at: CMTime.zero)
                
                // CompositionInstruction
                let mainInstructions = AVMutableVideoCompositionInstruction()
                mainInstructions.timeRange = trackTimeRange
                mainInstructions.layerInstructions = [layerInstructions]
                
                // Video Composition
                let videoComposition = AVMutableVideoComposition(propertiesOf: asset)
                videoComposition.instructions = [mainInstructions]
                videoComposition.renderSize = cropRect.size // needed?
                
                // 5. Configuring export session

                let fileURL = URL(fileURLWithPath: NSTemporaryDirectory())
                    .appendingUniquePathComponent(pathExtension: YPConfig.video.fileType.fileExtension)
                let exportSession = assetComposition
                    .export(to: fileURL,
                            videoComposition: videoComposition,
                            removeOldFile: true) { [weak self] session in
                                DispatchQueue.main.async {
                                    switch session.status {
                                    case .completed:
                                        if let url = session.outputURL {
                                            if let index = self?.currentExportSessions.firstIndex(of: session) {
                                                self?.currentExportSessions.remove(at: index)
                                            }
                                            callback(url)
                                        } else {
                                            print("LibraryMediaManager -> Don't have URL.")
                                            callback(nil)
                                        }
                                    case .failed:
                                        print("LibraryMediaManager -> Export of the video failed. Reason: \(String(describing: session.error))")
                                        callback(nil)
                                    default:
                                        print("LibraryMediaManager -> Export session completed with \(session.status) status. Not handling.")
                                        callback(nil)
                                    }
                                }
                }

                // 6. Exporting
                DispatchQueue.main.async {
                    self.exportTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                                            target: self,
                                                            selector: #selector(self.onTickExportTimer),
                                                            userInfo: exportSession,
                                                            repeats: true)
                }

                if let s = exportSession {
                    self.currentExportSessions.append(s)
                }
            } catch let error {
                print("⚠️ PHCachingImageManager >>> \(error)")
            }
        }
    }
    
    @objc func onTickExportTimer(sender: Timer) {
        /*
        if let exportSession = sender.userInfo as? AVAssetExportSession {
            if let v = v {
                if exportSession.progress > 0 {
                    v.updateProgress(exportSession.progress)
                }
            }
            
            if exportSession.progress > 0.99 {
                sender.invalidate()
                v?.updateProgress(0)
                self.exportTimer = nil
            }
        }*/
    }
    
    func forseCancelExporting() {
        for s in self.currentExportSessions {
            s.cancelExport()
        }
    }*/
    
    func assetsAtIndexPaths(_ indexPaths: [IndexPath]) -> [PHAsset] {
        return indexPaths.map { index -> PHAsset in
            return fetchResult[index.item]
        }
    }
}
