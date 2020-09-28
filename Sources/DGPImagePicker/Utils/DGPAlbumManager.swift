//
//  DGPAlbumManager.swift
//  SocialGaming
//
//  Created by Daniel Gallego Peralta on 05/09/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import UIKit
import Photos

public class DGPAlbumManager {
    
    private var cacheAlbums : [DGPAlbum]
    private let imageSize : CGFloat = 70
    
    init() {
        cacheAlbums = []
    }
    
    func fetchAlbums() -> [DGPAlbum] {
        if !cacheAlbums.isEmpty {
            return cacheAlbums
        }
        
        let options = PHFetchOptions()
        
        let smartAlbumsFav = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumFavorites, options: options)
        let smartAlbumRecent = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumRecentlyAdded, options: options)
        let albumsResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: options)
        
        var albums : [DGPAlbum] = []
        
        for result in [smartAlbumRecent, smartAlbumsFav, albumsResult] {
            result.enumerateObjects { (collection, _, _) in
                
             
                let title = collection.localizedTitle ?? ""
                let numbers = self.mediaCount(for: collection)
                
                var album = DGPAlbum(title: title, numberOfItems: numbers, thumb: nil, collection: collection)
                if numbers > 0 {
                    let keyAssetResult = PHAsset.fetchKeyAssets(in: collection, options: nil)
                    if let keyAsset = keyAssetResult?.firstObject {
                        let scale = UIScreen.main.scale
                        let targetSizeImage = CGSize(width: self.imageSize * scale, height: self.imageSize * scale)
                        let options = PHImageRequestOptions()
                        options.isSynchronous = true
                        options.deliveryMode = .opportunistic
                        PHImageManager.default().requestImage(for: keyAsset, targetSize: targetSizeImage, contentMode: .aspectFill, options: options) { (img, _) in
                            album.thumb = img
                        }
                    }
                }
                
                //albums.append(album)
                
                
                if DGPConfig.shared.library.mediaType == .photo {
                    if !(collection.assetCollectionSubtype == .smartAlbumSlomoVideos
                        || collection.assetCollectionSubtype == .smartAlbumVideos) {
                        albums.append(album)
                    }
                } else {
                    albums.append(album)
                }
            }
        }
        
        cacheAlbums = albums
        return cacheAlbums
    }
    
    func mediaCount(for collection: PHAssetCollection) -> Int {
        let options = PHFetchOptions()
        options.predicate = DGPConfig.shared.library.mediaType.predicate()
        let result = PHAsset.fetchAssets(in: collection, options: options)
        return result.count
    }
    
}
