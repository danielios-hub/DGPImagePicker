//
//  DGPCameraView.swift
//  DGPImagePicker
//
//  Created by Daniel Gallego Peralta on 24/08/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import UIKit

class DGPCameraView : UIView {
    
    var previewContainer : UIView!
    var buttonsContainer: UIView!
    
    var buttonFlash : UIButton!
    var buttonRotate: UIButton!
    var buttonShoot: UIButton!
    
    var labelTimeVideo : UILabel!
    
    static let sizeButton : CGFloat = 30.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        previewContainer = UIView()
        
        labelTimeVideo = UILabel()
        buttonFlash = UIButton()
        buttonRotate = UIButton()
        
        let containerButton = UIView()
        buttonShoot = UIButton()
        
        previewContainer.translatesAutoresizingMaskIntoConstraints = false
        labelTimeVideo.translatesAutoresizingMaskIntoConstraints = false
        buttonFlash.translatesAutoresizingMaskIntoConstraints = false
        buttonRotate.translatesAutoresizingMaskIntoConstraints = false
        containerButton.translatesAutoresizingMaskIntoConstraints = false
        buttonShoot.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(previewContainer)
        addSubview(labelTimeVideo)
        addSubview(buttonFlash)
        addSubview(buttonRotate)
        containerButton.addSubview(buttonShoot)
        addSubview(containerButton)
        
        let sizeShoot : CGFloat = 80.0
        
        NSLayoutConstraint.activate( [
            previewContainer.topAnchor.constraint(equalTo: self.topAnchor),
            previewContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            previewContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            previewContainer.bottomAnchor.constraint(equalTo: containerButton.topAnchor),
            
            //
            
            labelTimeVideo.heightAnchor.constraint(equalToConstant: 25.0),
            labelTimeVideo.widthAnchor.constraint(greaterThanOrEqualToConstant: 45),
            labelTimeVideo.topAnchor.constraint(equalTo: previewContainer.topAnchor, constant: 15),
            labelTimeVideo.trailingAnchor.constraint(equalTo: previewContainer.trailingAnchor, constant: -15),
            
            //
            
            buttonFlash.heightAnchor.constraint(equalToConstant: DGPCameraView.sizeButton),
            buttonFlash.widthAnchor.constraint(greaterThanOrEqualToConstant: DGPCameraView.sizeButton),
            buttonFlash.leadingAnchor.constraint(equalTo: previewContainer.leadingAnchor, constant: 10),
            buttonFlash.bottomAnchor.constraint(equalTo: previewContainer.bottomAnchor, constant: -10),
            
            //
            
            buttonRotate.heightAnchor.constraint(equalToConstant: DGPCameraView.sizeButton),
            buttonRotate.widthAnchor.constraint(greaterThanOrEqualToConstant: DGPCameraView.sizeButton),
            buttonRotate.trailingAnchor.constraint(equalTo: previewContainer.trailingAnchor, constant: -10),
            buttonRotate.bottomAnchor.constraint(equalTo: previewContainer.bottomAnchor, constant: -10),
            
            //
            
            buttonShoot.heightAnchor.constraint(equalToConstant: sizeShoot),
            buttonShoot.widthAnchor.constraint(greaterThanOrEqualToConstant: sizeShoot),
            buttonShoot.centerXAnchor.constraint(equalTo: containerButton.centerXAnchor),
            buttonShoot.centerYAnchor.constraint(equalTo: containerButton.centerYAnchor),
            
            //
            
            containerButton.heightAnchor.constraint(equalToConstant: 100),
            containerButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            containerButton.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        containerButton.backgroundColor = .white
        buttonShoot.tintColor = DGPConfig.shared.emerald()
        
        labelTimeVideo.layer.cornerRadius = 6
        labelTimeVideo.clipsToBounds = true
        labelTimeVideo.textColor = .white
        labelTimeVideo.backgroundColor = .black_midnight_light
        labelTimeVideo.textAlignment = .center
        labelTimeVideo.font = .monospacedDigitSystemFont(ofSize: 13, weight: .medium)
        labelTimeVideo.text = "00:00"
        labelTimeVideo.alpha = 0.9
        labelTimeVideo.isHidden = true
        
        setButtonFlipCamera()
    }
    
    func setButtonFlashImage(_ mode: FlashMode) {
        guard let img = getButtonFlashImage(mode) else {
            buttonFlash.isHidden = true
            return
        }
        
        buttonFlash.isHidden = false
        buttonFlash.setImage(img, for: .normal)
        applyDesignButtons(buttonFlash, radius: DGPCameraView.sizeButton / 2)
    }
    
    func setButtonFlipCamera() {
        buttonRotate.setImage(UIImage(symbol: .cameraRotate), for: .normal)
        applyDesignButtons(buttonRotate, radius: DGPCameraView.sizeButton / 2)
    }
    
    func setButtonPhoto() {
        buttonShoot.setBackgroundImage(getButtonCamera()?.withRenderingMode(.alwaysTemplate), for: .normal)
    }
    
    func setRecordButtons(isRecording: Bool) {
        buttonShoot.setBackgroundImage(getButtonVideo(recording: isRecording)?.withRenderingMode(.alwaysTemplate), for: .normal)
    }
    
}
