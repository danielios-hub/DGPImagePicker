//
//  DGPAssetContainerView.swift
//  SocialGaming
//
//  Created by Daniel Gallego Peralta on 08/07/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import UIKit

class DGPAssetContainerView: UIView {
    
    var assetZoomView : DGPAssetZoomableView?
    
    private var isMultipleSelection = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        assetZoomView?.assetDelegate = self
    }

}

extension DGPAssetContainerView: DGPAssetZoomableViewDelegate {
    
    //needed for grid implementation
    
    func assetZoomableDidLayoutSubviews(_ view: DGPAssetZoomableView) {
        
    }
    
    func assetZoomableDidZoom() {
        
    }
    
    func assetZoomableDidEndZooming() {
        
    }
    
    
}
