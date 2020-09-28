//
//  DGPVideoViewController.swift
//  SocialGaming
//
//  Created by Daniel Gallego Peralta on 05/07/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import UIKit

class DGPVideoViewController: UIViewController, DGPPermissionCheck {

    var didSelectVideo: ((URL) -> Void)?
    internal var v: DGPCameraView!
    
    fileprivate var videoCapture = DGPVideoCapture()
    
    var isInited = false
    
    struct ViewState {
        var isRecording = false
        var flash = FlashMode.noFlash
        var progress : Float = 0
        var timeElapsed: TimeInterval = 0
        
        mutating func reset() {
            isRecording = false
            flash = .noFlash
            progress = 0
            timeElapsed = 0
        }
    }
    
    var state = ViewState()
    
    public required init(items: [Any]?) {
        super.init(nibName: nil, bundle: nil)
        title = textConstants.video
    }
    
    public convenience init() {
        self.init(items: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has nots been implemented")
    }
    
    
    // MARK: - View Lifecycle
    
    public override func loadView() {
        v = DGPCameraView.xibView()
        view = v
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        v.buttonFlash.addTarget(self, action: #selector(toggleFlash), for: .touchDown)
        v.buttonRotate.addTarget(self, action: #selector(rotateCamera), for: .touchDown)
        v.buttonShoot.addTarget(self, action: #selector(toggleRecording), for: .touchDown)
    }
    
    //MARK: - Actions
    
    @objc func toggleFlash() {
        videoCapture.toggleTorch()
        refreshState()
        updateUI()
    }
    
    @objc func rotateCamera() {
        videoCapture.toggleCamera {
            self.refreshState()
            self.updateUI()
        }
    }
    
    @objc func toggleRecording() {
        videoCapture.isRecording ? videoCapture.stopRecording() : videoCapture.startRecording()
        state.isRecording.toggle()
        updateUI()
    }
    
    
    func start() {
        v.buttonShoot.isEnabled = false
        
        checkPermissionToAccessVideo { [weak self] granted in
            guard let strongSelf = self else {
                return
            }
            
            if granted {
                strongSelf.videoCapture.delegate = self
                
                strongSelf.videoCapture.start(previewView: strongSelf.v.previewContainer, timeLimit: DGPConfig.shared.video.timitLimit, completion: {
                    DispatchQueue.main.async {
                        strongSelf.isInited = true
                        strongSelf.v.buttonShoot.isEnabled = true
                        strongSelf.refreshState()
                        strongSelf.updateUI()
                        
                    }
                })
            } else {
                let permissionView = DeniedPermissionView(title: textConstants.titleDenied,
                                                          descriptionText: textConstants.allowAccessCamera,
                                                          linkText: textConstants.grantAccessCamera)
                permissionView.translatesAutoresizingMaskIntoConstraints = false
                strongSelf.v.addSubview(permissionView)
                adjustToContainer(view: permissionView, parentContainer: strongSelf.v)
            }
            
        }
    }
    
    func stopCamera() {
        videoCapture.stopCamera()
    }
    
    //MARK: - State
    
    func refreshState() {
        state.isRecording = videoCapture.isRecording
        state.flash = videoCapture.currentFlashMode()
    }
    
    func updateUI() {
        v.setButtonFlashImage(state.flash)
        v.buttonFlash.isEnabled = !state.isRecording
        
        v.setRecordButtons(isRecording: state.isRecording)
        v.buttonRotate.isEnabled = !state.isRecording
        
        v.labelTimeVideo.isHidden = !state.isRecording
        //animate progressbar and setup rogress bar
        
    }
    
    func resetUI() {
        state.reset()
        updateUI()
    }
}

extension DGPVideoViewController : DGPVideoCaptureDelegate {
    func didCaptureVideo(_ url: URL) {
        print("did capture video \(url.path)")
        
    }
    
    func videoInProgress(value: Float, time: TimeInterval) {
        v.labelTimeVideo.text = "\(Int(time))"
    }
    
    
}
