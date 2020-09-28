//
//  DGPPermissionCheck.swift
//  SocialGaming
//
//  Created by Daniel Gallego Peralta on 06/07/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

protocol DGPPermissionCheck {
    func checkPermissionLibrary()
    func checkPermissionCamera()
}

extension DGPPermissionCheck where Self:UIViewController {
    
    func checkPermissionCamera() {
        checkPermissionToAccessVideo { _ in }
    }
    
    func checkPermissionLibrary() {
        checkPermissionToAccessPhotoLibrary { _ in }
    }
    
    func doAfterPermissionCheckCamera(block:@escaping () -> Void) {
        checkPermissionToAccessVideo { hasPermission in
            if hasPermission {
                block()
            }
        }
    }
    
    func doAfterPermissionCheckLibrary(block:@escaping () -> Void) {
        checkPermissionToAccessPhotoLibrary { hasPermission in
            if hasPermission {
                block()
            }
        }
    }
    
    
    func checkPermissionToAccessVideo(block: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized:
            block(true)
        case .restricted, .denied:
            block(false)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                DispatchQueue.main.async {
                    block(granted)
                }
            })
        @unknown default:
            fatalError()
        }
    }

    func checkPermissionToAccessPhotoLibrary(block: @escaping (Bool) -> Void) {
        // Only intilialize picker if photo permission is Allowed by user.
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            block(true)
        case .restricted, .denied:
                block(false)
        case .notDetermined:
            // Show permission popup and get new status
            PHPhotoLibrary.requestAuthorization { s in
                DispatchQueue.main.async {
                    block(s == .authorized)
                }
            }
        @unknown default:
            fatalError()
        }
    }

}
