//
//  DGPVideoCapture.swift
//  SocialGaming
//
//  Created by Daniel Gallego Peralta on 26/08/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import UIKit
import AVFoundation

protocol DGPVideoCaptureDelegate {
    func didCaptureVideo(_ url: URL)
    func videoInProgress(value: Float, time: TimeInterval)
    func errorCaptureVideo(_ error: Error?)
}

extension DGPVideoCaptureDelegate {
    func errorCaptureVideo(_ error: Error?){}
}

class DGPVideoCapture : NSObject {
    
    public var isRecording: Bool {
        return videoOutput.isRecording
    }
    
    public var delegate : DGPVideoCaptureDelegate?
    private let session = AVCaptureSession()
    private var timer : Timer?
    
    private var videoInput: AVCaptureDeviceInput? = nil
    private var videoOutput = AVCaptureMovieFileOutput()
    
    private var currentLength : TimeInterval = 0
    private var timeLimit: TimeInterval = 0
    
    private var IsSessionSetup = false
    private var isPreviewSetup = false
    private var previewView : UIView!
    
    private var cameraPosition : AVCaptureDevice.Position = .back
    
    var hasTorch: Bool {
        guard let device = videoInput?.device else { return false }
        return device.hasTorch
    }
    
    //MARK: - AVCaptureSession
    
    private func setupCaptureSession() {
        session.beginConfiguration()
        updateInputOutputDevice(updateOutput: true)
        session.commitConfiguration()
        IsSessionSetup = true
    }
    
    func updateInputOutputDevice(updateOutput: Bool = false) {
        
        if let device = device(forPosition: cameraPosition) {
            videoInput = try? AVCaptureDeviceInput(device: device)
            
            if let videoInput = videoInput {
                if session.canAddInput(videoInput) {
                    session.addInput(videoInput)
                }
                
                //check if record sound
                
                if let audioDevice = AVCaptureDevice.default(for: .audio) {
                    if let audioInput = try? AVCaptureDeviceInput(device: audioDevice) {
                        if session.canAddInput(audioInput) {
                            session.addInput(audioInput)
                        }
                    }
                }
                
                
                if updateOutput && session.canAddOutput(videoOutput) {
                    let timeScale: Int32 = 30 // fps
                    let maxDuration = CMTimeMakeWithSeconds(timeLimit, preferredTimescale: timeScale)
                    
                    videoOutput.maxRecordedDuration = maxDuration
                    videoOutput.minFreeDiskSpaceLimit = 1024 * 1024
                    session.addOutput(videoOutput)
                }
                
                session.sessionPreset = .high
            } else {
                print("video input nil")
            }
        } else {
            print("device nil")
        }
    }
    
    
    
    //MARK: - Recording
    
    func start(previewView: UIView, timeLimit: TimeInterval, completion: @escaping () -> Void) {
        self.previewView = previewView
        self.timeLimit = timeLimit
        
        let blockOperation = BlockOperation { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            
            if !strongSelf.IsSessionSetup {
                strongSelf.setupCaptureSession()
            }
            
            strongSelf.startCamera(completion: completion)
        }
        
        blockOperation.queuePriority = .veryHigh
        DGPConfig.shared.queueVideo.addOperation(blockOperation)
    }
    
    func startCamera(completion: @escaping () -> Void) {
        if !session.isRunning  {
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
    
    public func stopCamera() {
        if session.isRunning {
            DGPConfig.shared.queueVideo.addOperation { [weak self] in
                self?.session.stopRunning()
            }
        }
    }
    
    public func startRecording() {
        let url = DGPGHelper.makeVideoPathURL(fileName: UUID().uuidString)
        
        //need check orientation device todo
        
        if let connection = videoOutput.connection(with: .video) {
            //connection is for change orientation
            videoOutput.startRecording(to: url, recordingDelegate: self)
        }
    }
    
    public func stopRecording() {
        videoOutput.stopRecording()
    }
    
    
    func setupPreview() {
        let videoLayer = AVCaptureVideoPreviewLayer(session: session)
        
        DispatchQueue.main.async {
            videoLayer.frame = self.previewView.bounds
            videoLayer.videoGravity = .resizeAspectFill
            self.previewView.layer.addSublayer(videoLayer)
        }
    }
    
    //MARK: - Flash
    
    func currentFlashMode() -> FlashMode {
        guard let device = videoInput?.device, device.hasTorch else {
            return .noFlash
        }
        
        switch device.torchMode {
        case .auto:
            return .auto
        case .on:
            return .on
        case .off:
            return .off
        default:
            return .noFlash
        }
    }
    
    func toggleTorch() {
        guard let device = videoInput?.device, hasTorch  else { return }
        
        do {
            try device.lockForConfiguration()
            
            switch device.torchMode {
            case .auto:
                device.torchMode = .on
            case .on:
                device.torchMode = .off
            case .off:
                device.torchMode = .auto
            default:
                break
            }
            device.unlockForConfiguration()
        } catch {}
    }
    
    func toggleCamera(completion: @escaping (() -> Void)) {
        let blockOperation = BlockOperation { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.session.beginConfiguration()
            strongSelf.session.resetInputs()
            strongSelf.cameraPosition = strongSelf.cameraPosition == .front ? .back : .front
            strongSelf.updateInputOutputDevice()
            strongSelf.session.commitConfiguration()
            
            DispatchQueue.main.async {
                completion()
            }
        }
        
        blockOperation.queuePriority = .veryHigh
        DGPConfig.shared.queueVideo.addOperation(blockOperation)
    }
    
    
}

extension DGPVideoCapture : AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            self.currentLength += 1
            self.delegate?.videoInProgress(value: 0, time: self.currentLength)
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        timer?.invalidate()
        currentLength = 0
        delegate?.didCaptureVideo(outputFileURL)
    }
    
    
}
