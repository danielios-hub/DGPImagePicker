//
//  DGPMediaType.swift
//  SocialGaming
//
//  Created by Daniel Gallego Peralta on 23/08/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import UIKit 
import Photos

public protocol DGPMediaType {}

public class DGPMediaPhoto : DGPMediaType {
    public var image: UIImage
    public let fromCamera: Bool
    public var asset: PHAsset?
    
    init(image: UIImage, fromCamera : Bool = false, asset: PHAsset? = nil) {
        self.image = image
        self.fromCamera = fromCamera
        self.asset = asset
    }
    
}

public class DGPMediaVideo : DGPMediaType {
    public var url: URL
    public let fromCamera: Bool
    public var asset: PHAsset?
    
    init(url: URL, fromCamera: Bool = false, asset: PHAsset? = nil) {
        self.url = url
        self.fromCamera = fromCamera
        self.asset = asset
    }
}
