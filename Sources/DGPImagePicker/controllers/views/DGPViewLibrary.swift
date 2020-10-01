//
//  DGPViewLibrary.swift
//  DGPImagePicker
//
//  Created by Daniel Gallego Peralta on 06/07/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import UIKit

class DGPViewLibrary: UIView {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var assetZoomableView: DGPAssetZoomableView!
    @IBOutlet weak var assetViewContainer: DGPAssetContainerView!
    
    //this for show bigger collection view when scroll
    //@IBOutlet weak var assetViewContainerConstraintTop: NSLayoutConstraint!
    
    @IBOutlet weak var buttonExpand : UIButton!
    @IBOutlet weak var buttonMultiple : UIButton!
    
    let maxNumberWarningView = UIView()
    let maxNumberWarningLabel = UILabel()
    let progressView = UIProgressView()
    let line = UIView()
    var shouldShowLoader = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        assetViewContainer.assetZoomView = assetZoomableView
        buttonExpand.isHidden = true
        buttonMultiple.isHidden = true
        
    }
    
    public func setupButtons() {
        let config = DGPConfig.shared.library
        if !config.onlySquare {
            buttonExpand.setImage(UIImage(symbol: .rectangleExpandVertical), for: .normal)
            applyDesignButtons(buttonExpand)
            buttonExpand.isHidden = false
        } else {
            buttonExpand.isHidden = true
        }
        
        setButtonMultiple()
    }
    
    public func setButtonMultiple() {
        let config = DGPConfig.shared.library
        if config.multipleSelectionAllowed {
            buttonMultiple.setImage(UIImage(symbol: .plus), for: .normal)
            applyDesignButtons(buttonMultiple, showActive: config.multipleSelectionActive)
            buttonMultiple.isHidden = false
        } else {
            buttonMultiple.isHidden = true
        }
    }

    //MARK: - Crop Rect
    
    func currentCropRect() -> CGRect {
        guard let cropView = assetZoomableView else {
            return .zero
        }
        
        let normalizedX = min(1, cropView.contentOffset.x / cropView.contentSize.width)
        let normalizedY = min(1, cropView.contentOffset.y / cropView.contentSize.height)
        let normalizedWidth = min(1, cropView.frame.width / cropView.contentSize.width)
        let normalizedHeight = min(1, cropView.frame.height / cropView.contentSize.height)
        let finalrect = CGRect(x: normalizedX, y: normalizedY, width: normalizedWidth, height: normalizedHeight)
        
        return finalrect
    }
}


// MARK: - UI Helpers

extension DGPViewLibrary {
    class func xibView() -> DGPViewLibrary? {
        return Bundle(for: DGPViewLibrary.self).loadNibNamed(String(describing: DGPViewLibrary.self), owner: nil, options: nil)![0] as? DGPViewLibrary
    }
}
