//
//  DGPAlbum.swift
//  DGPImagePicker
//
//  Created by Daniel Gallego Peralta on 05/09/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import UIKit 
import Photos

struct DGPAlbum {
    var title : String
    var numberOfItems = 0
    var thumb: UIImage?
    var collection: PHAssetCollection?
}
