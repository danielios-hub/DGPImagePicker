//
//  DGPConfig.swift
//  SocialGaming
//
//  Created by Daniel Gallego Peralta on 05/07/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import UIKit 
import Photos

public struct DGPConfig {
    
    //Singleton +
    public static var shared = DGPConfig()
    public init() {
        queueVideo.maxConcurrentOperationCount = 1
    }
    
    var barTintColor : UIColor = .lightGray
    var tintColor : UIColor = .systemBlue
    let emerald = UIColor(red: 0, green: 155/255.0, blue: 119/255.0, alpha: 1)
    
    var titleColor : UIColor?
    var screens: [DGPMode] = [.library, .camera, .video]
    var library = DGPLibraryConfig()
    var video = DGPCameraVideo()
    var queueVideo = OperationQueue()
}

//config for library
public struct DGPLibraryConfig {
    public var options: PHFetchOptions? = nil

    /// Set this to true if you want to force the library output to be a squared image. Defaults to false.
    public var onlySquare = false
    
    /// Sets the cropping style to square or not. Ignored if `onlySquare` is true. Defaults to true.
    public var isSquareByDefault = true
    
    /// Minimum width, to prevent selectiong too high images. Have sense if onlySquare is true and the image is portrait.
    public var minWidthForItem: CGFloat?
    
    /// Choose what media types are available in the library. Defaults to `.photo`
    public var mediaType = DGPlibraryMediaType.photo

    /// Initial state of multiple selection button.
    public var multipleSelectionAllowed = false
    public var multipleSelectionActive = false

    /// Anything superior than 1 will enable the multiple selection feature.
    public var maxNumberOfItems = 1
    
    /// Anything greater than 1 will desactivate live photo and video modes (library only) and
    // force users to select at least the number of items defined.
    public var minNumberOfItems = 1

    /// Set the number of items per row in collection view. Defaults to 4.
    public var numberOfItemsInRow: Int = 4

    /// Set the spacing between items in collection view. Defaults to 1.0.
    public var spacingBetweenItems: CGFloat = 1.0

    /// Allow to skip the selections gallery when selecting the multiple media items. Defaults to false.
    //public var skipSelectionsGallery = false
    
    /// Allow to preselected media items
    //public var preselectedItems: [YPMediaItem]?
    
    public var showsPhotoFilters = true
    
    public var shouldSaveNewPicturesToAlbum = true
    
    public var albumName = "ImagePickerAlbumName"
    
    //maximum size
    public var targetImageSize :CGFloat?
    
}

//config for video
public struct DGPCameraVideo {
    public var timitLimit : TimeInterval = 60
    public let fileType: AVFileType = .mov
    public var forceSquareImage = false
    public var useFrontCamera = false
}

public enum DGPlibraryMediaType {
    case photo
    case video
    case photoAndVideo
    
    func predicate() -> NSPredicate {
        switch self {
        case .photo:
            return NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        case .video:
            return NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
        case .photoAndVideo:
            return NSPredicate(format: "mediaType = %d || mediaType = %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
            
        }
    }
}
