//
//  DGPAssetContainerView.swift
//  DGPImagePicker
//
//  Created by Daniel Gallego Peralta on 08/07/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import UIKit

class DGPAssetContainerView: UIView {
    
    var assetZoomView : DGPAssetZoomableView?
    
    private var isMultipleSelection = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        assetZoomView?.assetDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
