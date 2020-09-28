//
//  GeneralUtils.swift
//  SocialGaming
//
//  Created by Daniel Gallego Peralta on 24/08/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

struct DGPGHelper {
    static func makeVideoPathURL(temporaryFolder: Bool = true, fileName: String) -> URL {
        var outputURL: URL
        let endName = "\(fileName).\(DGPConfig.shared.video.fileType.fileExtension)"
        if temporaryFolder {
            outputURL = getTemporaryUrl(endName)
        } else {
            guard let documentsURL = FileManager.default.urls(for: .documentDirectory,
                                                              in: .userDomainMask).first else {
                return getTemporaryUrl(endName)
            }
            
            outputURL = documentsURL.appendingPathComponent(endName)
        }
        
        
        if FileManager.default.fileExists(atPath: outputURL.path) {
            try? FileManager.default.removeItem(at: outputURL)
        }
        
        return outputURL
    }
    
    static func getTemporaryUrl(_ endName: String) -> URL {
        let strUrl = "\(NSTemporaryDirectory())\(endName)"
        return URL(fileURLWithPath: strUrl)
    }
    
    func thumbnailFromVideoPath(_ path: URL) -> UIImage {
        let asset = AVURLAsset(url: path, options: nil)
        let gen = AVAssetImageGenerator(asset: asset)
        gen.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(0.0, preferredTimescale: 600)
        var actualTime = CMTimeMake(value: 0, timescale: 0)
        let image: CGImage
        do {
            image = try gen.copyCGImage(at: time, actualTime: &actualTime)
            let thumbnail = UIImage(cgImage: image)
            return thumbnail
        } catch { }
        return UIImage()
    }
    
    
}

enum FlashMode {
    case noFlash
    case auto
    case on
    case off
}

func device(forPosition position: AVCaptureDevice.Position) -> AVCaptureDevice? {
    let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                            mediaType: AVMediaType.video,
                                                            position: position)
    return discoverySession.devices.first
}

func getButtonFlashImage(_ mode: FlashMode) -> UIImage? {
    var img : UIImage?
    switch mode {
    case .auto:
        img = UIImage(symbol: .boltbadgeautofill)
    case .on:
        img = UIImage(symbol: .boltFill)
    case .off:
        img = UIImage(symbol: .boltSlashFill)
    case .noFlash:
        break
    }
    return img
}

func getButtonVideo(recording: Bool) -> UIImage? {
    if recording {
        return UIImage(symbol: .stopCircleFill)
    } else {
        return UIImage(symbol: .playCircleFill)
    }
}

func getButtonCamera() -> UIImage? {
    return UIImage(symbol: .cameraCircleFill)
}

func applyDesignButtons(_ button: UIButton, showActive: Bool = false) {
    button.tintColor = .white
    
    if !showActive {
        button.backgroundColor = .black_midnight_light
    } else {
        button.backgroundColor = .systemBlue
    }
    
    button.layer.cornerRadius = button.frame.width / 2
}

func adjustToContainer(view: UIView, parentContainer: UIView, heightValue: CGFloat? = nil) {
    parentContainer.addConstraints([
        NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: view.superview, attribute: .leading, multiplier: 1, constant: 0),
        NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: view.superview, attribute: .bottom, multiplier: 1, constant: 0),
        NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: view.superview, attribute: .trailing, multiplier: 1, constant: 0),
        NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: view.superview, attribute: .top, multiplier: 1, constant: 0),
    ])
    
    if let heightValue = heightValue {
        parentContainer.addConstraint(NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: heightValue))
    }
}


  // Create an array of index paths from an index set
func indexPaths(section: Int, set: IndexSet) -> [IndexPath] {
    let indexPaths = set.map { (i) -> IndexPath in
        return IndexPath(item: i, section: section)
    }
    return indexPaths
}

