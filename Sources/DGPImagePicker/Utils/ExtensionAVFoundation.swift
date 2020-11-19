//
//  ExtensionAVFile.swift
//  DGPImagePicker
//
//  Created by Daniel Gallego Peralta on 27/08/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import Foundation
import AVFoundation 
import MobileCoreServices

extension AVFileType {
    /// Fetch and extension for a file from UTI string
    var fileExtension: String {
        if let ext = UTTypeCopyPreferredTagWithClass(self as CFString, kUTTagClassFilenameExtension)?.takeRetainedValue() {
            return ext as String
        }
        return "None"
    }
}

extension AVCaptureSession {
    func resetInputs() {
        self.inputs.forEach {
            self.removeInput($0)
        }
    }
}

import AVFoundation

// MARK: Trim

extension AVAsset {
    func assetByTrimming(startTime: CMTime, endTime: CMTime) throws -> AVAsset {
        let timeRange = CMTimeRangeFromTimeToTime(start: startTime, end: endTime)
        let composition = AVMutableComposition()
        do {
            for track in tracks {
                let compositionTrack = composition.addMutableTrack(withMediaType: track.mediaType,
                                                                   preferredTrackID: track.trackID)
                try compositionTrack?.insertTimeRange(timeRange, of: track, at: CMTime.zero)
            }
        } catch let error {
            print("error during composition")
            
        }
        
        // Reaply correct transform to keep original orientation.
        if let videoTrack = self.tracks(withMediaType: .video).last,
            let compositionTrack = composition.tracks(withMediaType: .video).last {
            compositionTrack.preferredTransform = videoTrack.preferredTransform
        }

        return composition
    }
    
    /// Export the video
    ///
    /// - Parameters:
    ///   - destination: The url to export
    ///   - videoComposition: video composition settings, for example like crop
    ///   - removeOldFile: remove old video
    ///   - completion: resulting export closure
    /// - Throws: YPTrimError with description
    func export(to destination: URL,
                videoComposition: AVVideoComposition? = nil,
                removeOldFile: Bool = false,
                completion: @escaping (_ exportSession: AVAssetExportSession) -> Void) -> AVAssetExportSession? {
        guard let exportSession = AVAssetExportSession(asset: self, presetName: AVAssetExportPresetHighestQuality) else {
            print("YPImagePicker -> AVAsset -> Could not create an export session.")
            return nil
        }
        
        exportSession.outputURL = destination
        exportSession.outputFileType = DGPConfig.shared.video.fileType
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.videoComposition = videoComposition
        
        if removeOldFile { try? FileManager.default.removeItem(at: destination)}
        
        exportSession.exportAsynchronously(completionHandler: {
            completion(exportSession)
        })

        return exportSession
    }
}

