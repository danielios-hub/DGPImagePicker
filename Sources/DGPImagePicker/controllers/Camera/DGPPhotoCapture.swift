//
//  PhotoCapture.swift
//  DGPImagePicker
//
//  Created by Daniel Gallego Peralta on 24/08/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import AVFoundation
import UIKit

protocol DGPCapturePhotoDelegate {
    func didCapturePhoto(_ data: Data)
    func errorCapturePhoto(_ error: Error?)
}

class DGPPhotoCapture : NSObject {
    
    var delegate : DGPCapturePhotoDelegate?
    fileprivate let session = AVCaptureSession()
    var deviceInput: AVCaptureDeviceInput?
    let photoOutput = AVCapturePhotoOutput()
    fileprivate var isCaptureSessionSetup = false
    fileprivate var isPreviewSetup = false
    var previewView: UIView!
    var videoLayer: AVCaptureVideoPreviewLayer!
    
    private var cameraPosition: AVCaptureDevice.Position =  .back
    
    var currentFlashMode: FlashMode = FlashMode.auto
    
    var hasFlash: Bool {
        guard let device = deviceInput?.device else { return false }
        return device.hasFlash
    }
    
    private func setupCaptureSession() {
        session.beginConfiguration()
        session.sessionPreset = .photo
        
        updateInputOutputDevice(for: cameraPosition, updateOutput: true)
        
        session.commitConfiguration()
        isCaptureSessionSetup = true
    }
    
    func updateInputOutputDevice(for position: AVCaptureDevice.Position, updateOutput: Bool = false) {
        guard let aDevice = device(forPosition: cameraPosition) else {
            currentFlashMode = .noFlash
            return
        }
        
        
        deviceInput = try? AVCaptureDeviceInput(device: aDevice)
        refreshDefaultFlash()
        
        if let deviceInput = deviceInput {
            if session.canAddInput(deviceInput) {
                session.addInput(deviceInput)
            }
            
            if updateOutput && session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
                photoOutput.isHighResolutionCaptureEnabled = true
                photoOutput.setPreparedPhotoSettingsArray([settings()])
            }
        }
    }
    
    private func settings() -> AVCapturePhotoSettings {
        var settings = AVCapturePhotoSettings()
        
        if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        }
        
        settings.isHighResolutionPhotoEnabled = true
        
        if hasFlash {
            switch currentFlashMode {
            case .auto:
                setupFlashMode(.auto, in: settings)
            case .on:
                setupFlashMode(.on, in: settings)
            case .off:
                setupFlashMode(.off, in: settings)
            case .noFlash:
                break
            }
        }
        
        return settings
    }
    
    func start(with previewView: UIView, completion: @escaping () -> Void) {
        self.previewView = previewView
        
        let blockOperation = BlockOperation { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            
            if !strongSelf.isCaptureSessionSetup {
                strongSelf.setupCaptureSession()
            }
            
            strongSelf.startCamera(completion: completion)
        }
        
        blockOperation.queuePriority = .veryHigh
        DGPConfig.shared.queueVideo.addOperation(blockOperation)
    }
    
    func startCamera(completion: @escaping () -> Void) {
        if !session.isRunning {
            let blockOperation = BlockOperation { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.session.startRunning()
                completion()
                
                if !strongSelf.isPreviewSetup {
                    self?.setupPreview()
                    self?.isPreviewSetup = true
                }
            }
            
            blockOperation.queuePriority = .veryHigh
            DGPConfig.shared.queueVideo.addOperation(blockOperation)
        }
        
    }
    
    func stopCamera() {
        if session.isRunning {
            DGPConfig.shared.queueVideo.addOperation { [weak self] in
                self?.session.stopRunning()
            }
        }
    }
    
    func setupPreview() {
        videoLayer = AVCaptureVideoPreviewLayer(session: session)
        DispatchQueue.main.async {
            self.videoLayer.frame = self.previewView.bounds
            self.videoLayer.videoGravity = .resizeAspectFill
            self.previewView.layer.addSublayer(self.videoLayer)
        }
    }
    
    func setupFlashMode(_ mode: AVCaptureDevice.FlashMode, in settings: AVCapturePhotoSettings) {
        if photoOutput.supportedFlashModes.contains(mode) {
            settings.flashMode = mode
        }
    }
    
    func toggleFlash() {
        if hasFlash {
            switch currentFlashMode {
            case .auto:
                currentFlashMode = .on
            case .on:
                currentFlashMode = .off
            case .off:
                currentFlashMode = .auto
            case .noFlash:
                break
            }
        } else {
            currentFlashMode = .noFlash
        }
    }
    
    func refreshDefaultFlash() {
        if currentFlashMode == .noFlash && hasFlash {
            currentFlashMode = .auto
        }
    }
    
    func toggleCamera(completion: @escaping (() -> Void)) {
        cameraPosition = cameraPosition == .front ? .back : .front
        
        let blockOperation = BlockOperation { [weak self] in
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.session.resetInputs()
            strongSelf.updateInputOutputDevice(for: strongSelf.cameraPosition)
            
            DispatchQueue.main.async {
                completion()
            }
        }
        
        blockOperation.queuePriority = .veryHigh
        DGPConfig.shared.queueVideo.addOperation(blockOperation)
    }
    
    func takePhoto() {
        
        photoOutput.capturePhoto(with: settings(), delegate: self)
    }
}

extension DGPPhotoCapture : AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else {
            delegate?.errorCapturePhoto(error)
            return
        }
        
        delegate?.didCapturePhoto(data)
    }
    
}
