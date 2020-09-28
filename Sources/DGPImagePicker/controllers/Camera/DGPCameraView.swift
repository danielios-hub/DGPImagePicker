//
//  DGPCameraView.swift
//  SocialGaming
//
//  Created by Daniel Gallego Peralta on 24/08/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import UIKit

class DGPCameraView : UIView {
    
    @IBOutlet weak var previewContainer : UIView!
    @IBOutlet weak var buttonsContainer: UIView!
    
    @IBOutlet weak var buttonFlash : UIButton!
    @IBOutlet weak var buttonRotate: UIButton!
    @IBOutlet weak var buttonShoot: UIButton!
    
    @IBOutlet weak var labelTimeVideo : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        buttonShoot.tintColor = DGPConfig.shared.emerald
        labelTimeVideo.layer.cornerRadius = 6
        labelTimeVideo.clipsToBounds = true
        
        setButtonFlipCamera()
    }
    
    func setButtonFlashImage(_ mode: FlashMode) {
        guard let img = getButtonFlashImage(mode) else {
            buttonFlash.isHidden = true
            return
        }
        
        buttonFlash.isHidden = false
        buttonFlash.setImage(img, for: .normal)
        applyDesignButtons(buttonFlash)
    }
    
    func setButtonFlipCamera() {
        buttonRotate.setImage(UIImage(symbol: .cameraRotate), for: .normal)
        applyDesignButtons(buttonRotate)
    }
    
    func setButtonPhoto() {
        buttonShoot.setBackgroundImage(getButtonCamera()?.withRenderingMode(.alwaysTemplate), for: .normal)
    }
    
    func setRecordButtons(isRecording: Bool) {
        buttonShoot.setBackgroundImage(getButtonVideo(recording: isRecording)?.withRenderingMode(.alwaysTemplate), for: .normal)
    }
    
}

extension DGPCameraView {
    class func xibView() -> DGPCameraView? {
        return Bundle(for: DGPCameraView.self).loadNibNamed(String(describing: DGPCameraView.self), owner: nil, options: nil)![0] as? DGPCameraView
    }
}
