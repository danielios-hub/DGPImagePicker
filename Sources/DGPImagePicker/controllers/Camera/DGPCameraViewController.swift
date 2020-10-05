//
//  DGPCameraViewController.swift
//  DGPImagePicker
//
//  Created by Daniel Gallego Peralta on 05/07/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import UIKit

class DGPCameraViewController: UIViewController, DGPPermissionCheck {

    public var didCapturaPhoto : ((UIImage) -> Void)?
    let photoCapture = DGPPhotoCapture()
    
    internal var v: DGPCameraView!
    var isInited = false
    
    var didSelectImage: ((UIImage) -> Void)?
    
    public required init(items: [Any]?) {
        super.init(nibName: nil, bundle: nil)
        title = textConstants.library
    }
    
    public convenience init() {
        self.init(items: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Lifecycle
    
    public override func loadView() {
        v = DGPCameraView(frame: .zero)
        view = v
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        v.buttonFlash.addTarget(self, action: #selector(toggleFlash), for: .touchDown)
        v.buttonRotate.addTarget(self, action: #selector(rotateCamera), for: .touchDown)
        v.buttonShoot.addTarget(self, action: #selector(takePhoto), for: .touchDown)
    }
    
    
    
    //MARK: - Actions
    
    @objc func toggleFlash() {
        photoCapture.toggleFlash()
        refreshButtons()
    }
    
    @objc func rotateCamera() {
        photoCapture.toggleCamera(completion: refreshButtons)
    }
    
    @objc func takePhoto() {
        v.buttonShoot.isEnabled = false
        photoCapture.takePhoto()
    }
    
    func refreshButtons() {
        v.buttonFlash.isHidden = !photoCapture.hasFlash
        v.setButtonFlashImage(photoCapture.currentFlashMode)
        v.setButtonPhoto()
    }
    
    
    func start() {
        checkPermissionToAccessVideo { [weak self] granted in
            guard let strongSelf = self else {
                return
            }
            
            if granted {
                strongSelf.photoCapture.delegate = self
                strongSelf.photoCapture.start(with: strongSelf.v.previewContainer, completion: {
                    DispatchQueue.main.async {
                        strongSelf.isInited = true
                        strongSelf.refreshButtons()
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
        photoCapture.stopCamera()
    }
}

extension DGPCameraViewController : DGPCapturePhotoDelegate {
    func didCapturePhoto(_ data: Data) {
        if let image = UIImage(data: data) {
            let imageResize = image.resetOrientation().resizedImageIfNeeded()
            DispatchQueue.main.async {
                self.didSelectImage?(imageResize)
            }
        }
    }
    
    func errorCapturePhoto(_ error: Error?) {
        
    }
}
