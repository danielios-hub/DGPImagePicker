//
//  DGPLibraryViewController.swift
//  DGPImagePicker
//
//  Created by Daniel Gallego Peralta on 05/07/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import UIKit
import Photos

class DGPLibraryViewController: UIViewController, DGPPermissionCheck {
    internal var v: DGPViewLibrary!
    
    private var libraryConfig = DGPConfig.shared.library
    internal var multipleSelectionActive = DGPConfig.shared.library.multipleSelectionAllowed && DGPConfig.shared.library.multipleSelectionActive {
        didSet {
            DGPConfig.shared.library.multipleSelectionActive = multipleSelectionActive
        }
    }
    internal var initialized = false
    internal var selection = [DGPLibrarySelection]()
    internal let mediaManager = LibraryMediaManager()
    internal var currentlySelectedIndex: Int = 0
    internal var latestImageTapped = ""
    
    //MARK: - Life cicle
    
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
    
    public override func loadView() {
        v = DGPViewLibrary(frame: .zero)
        view = v
        v.setupButtons()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        v.buttonExpand.addTarget(self, action: #selector(squareButtonTapped), for: .touchDown)
        v.buttonMultiple.addTarget(self, action: #selector(toggleMultipleSelection), for: .touchDown)
        
        v.assetZoomableView.cropAreaDidChange = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.updateCropInfo()
        }
    }
    
    //MARK: - Setup
    
    func start() {
        checkPermissionToAccessPhotoLibrary { [weak self] granted in
            guard let strongSelf = self else {
                return
            }
            
            if granted {
                if !strongSelf.initialized {
                    strongSelf.initialize()
                    strongSelf.initialized = true
                }
            } else {
                let permissionView = DeniedPermissionView(title: textConstants.titleDenied,
                                                          descriptionText: textConstants.allowAccessLibrary,
                                                          linkText: textConstants.grantAccessLibrary)
                permissionView.translatesAutoresizingMaskIntoConstraints = false
                strongSelf.v.addSubview(permissionView)
                adjustToContainer(view: permissionView, parentContainer: strongSelf.v)
            }
            
        }
    }
    
    func initialize() {
        mediaManager.initialize()
        mediaManager.v = v

        if mediaManager.fetchResult != nil {
            return
        }
        
        setupCollectionView()
        registerForLibraryChanges()
        /*
        
        panGestureHelper.registerForPanGesture(on: v)
        registerForTapOnPreview()
        */
        updateLibrary()
        
      

        /*
        
        v.assetViewContainer.multipleSelectionButton.isHidden = !(YPConfig.library.maxNumberOfItems > 1)
        v.maxNumberWarningLabel.text = String(format: YPConfig.wordings.warningMaxItemsLimit, YPConfig.library.maxNumberOfItems)
        
        if let preselectedItems = YPConfig.library.preselectedItems {
            selection = preselectedItems.compactMap { item -> YPLibrarySelection? in
                var itemAsset: PHAsset?
                switch item {
                case .photo(let photo):
                    itemAsset = photo.asset
                case .video(let video):
                    itemAsset = video.asset
                }
                guard let asset = itemAsset else {
                    return nil
                }
                
                // The negative index will be corrected in the collectionView:cellForItemAt:
                return YPLibrarySelection(index: -1, assetIdentifier: asset.localIdentifier)
            }

            multipleSelectionEnabled = selection.count > 1
            v.assetViewContainer.setMultipleSelectionMode(on: multipleSelectionEnabled)
            v.collectionView.reloadData()
        }*/
    }
    
    func updateLibrary() {
        mediaManager.refreshMediaRequest()
        
        if mediaManager.fetchResult.count > 0 {
            changeAsset(mediaManager.fetchResult[0], squareByDefault: libraryConfig.onlySquare || libraryConfig.isSquareByDefault)
            v.collectionView.reloadData()
            v.collectionView.selectItem(at: IndexPath(row: 0, section: 0),
                                             animated: false,
                                             scrollPosition: UICollectionView.ScrollPosition())
            if !multipleSelectionActive {
                addToSelection(indexPath: IndexPath(row: 0, section: 0))
            }
        } else {
            // no photos
        }
        
        scrollToTop()
        
    }
    
    func changeAlbum(_ album: DGPAlbum) {
        mediaManager.collection = album.collection
        selection.removeAll()
        currentlySelectedIndex = 0
        mediaManager.resetCachedAssets()
        updateLibrary()
    }
    
    func scrollToTop() {
        //tappedImage()
        v.collectionView.contentOffset = CGPoint.zero
    }
    
    //MARK: - Register Observers
    
    func registerForLibraryChanges() {
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    // MARK: - ScrollViewDelegate
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == v.collectionView {
            mediaManager.updateCachedAssets(in: self.v.collectionView)
        }
    }
    
    func changeAsset(_ asset: PHAsset, squareByDefault: Bool = false) {
        latestImageTapped = asset.localIdentifier

        let completion = { (isLowResIntermediaryImage: Bool) in
            //self.v.hideGrid()
            //self.v.setupButtons()
            let shouldfit = (self.libraryConfig.onlySquare || squareByDefault) ? true : self.v.assetZoomableView.squaredZoomScale > 1
            self.fitImage(shouldfit)
            self.updateCropInfo()
            //if !isLowResIntermediaryImage {
            //    self.v.hideLoader()
            //}
        }
        
        //MARK: add a func(updateCropInfo) after crop multiple
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            switch asset.mediaType {
            case .image:
                strongSelf.v.assetZoomableView.setImage(asset,
                                                  mediaManager: strongSelf.mediaManager,
                                                  completion: completion,
                                                  updateCropInfo: strongSelf.updateCropInfo)
            case .video:
                break
                //self.v.assetZoomableView.setVideo(asset,
                //                                  mediaManager: self.mediaManager,
               //                                   storedCropPosition: self.fetchStoredCrop(),
                //                                  completion: { completion(false) },
                //                                  updateCropInfo: updateCropInfo)
            case .audio, .unknown:
                ()
            @unknown default:
                fatalError()
            }
        }
    }
    
    internal func updateCropInfo() {
        guard let selectedAssetIndex = selection.firstIndex(where: { $0.index == currentlySelectedIndex }) else {
            return
        }
        
         //Fill new values
        var selectedAsset = selection[selectedAssetIndex]
        selectedAsset.cropRect = v.currentCropRect()
        
        //Replace
        selection.remove(at: selectedAssetIndex)
        selection.insert(selectedAsset, at: selectedAssetIndex)
        
    }
    
    //internal func fetchStoredCrop() -> YPLibrarySelection? {
        /*
        if self.multipleSelectionEnabled,
            self.selection.contains(where: { $0.index == self.currentlySelectedIndex }) {
            guard let selectedAssetIndex = self.selection
                .firstIndex(where: { $0.index == self.currentlySelectedIndex }) else {
                return nil
            }
            return self.selection[selectedAssetIndex]
        }*/
    //    return nil
    //}
    
    internal func hasStoredCrop(index: Int) -> Bool {
        return true
        //return self.selection.contains(where: { $0.index == index })
    }
    
    private func fetchImageAndCrop(for asset: PHAsset,
                                   withCropRect: CGRect? = nil,
                                   callback: @escaping (_ photo: UIImage, _ exif: [String : Any]) -> Void) {
        
        let cropRect = withCropRect ?? DispatchQueue.main.sync { v.currentCropRect() }
        let ts = targetSize(for: asset, cropRect: cropRect)
        mediaManager.imageManager?.fetchImage(for: asset, cropRect: cropRect, targetSize: ts, callback: callback)
    }
    
    public func selectedMedia(photoCallback: @escaping (_ photo: DGPMediaPhoto) -> Void,
                              videoCallback: @escaping (_ videoURL: DGPMediaVideo) -> Void,
                              multipleItemsCallback: @escaping (_ items: [DGPMediaType]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            
            let selectedAssets: [(asset: PHAsset, cropRect: CGRect?)] = self.selection.map {
                guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [$0.assetIdentifier], options: PHFetchOptions()).firstObject else { fatalError() }
                return (asset, $0.cropRect)
            }
            
            // Multiple selection
            
            if self.multipleSelectionActive && self.selection.count > 1 {
                
                // Check video length
//                for asset in selectedAssets {
//                    if self.fitsVideoLengthLimits(asset: asset.asset) == false {
//                        return
//                    }
//                }
                
                // Fill result media items array
                var resultMediaItems: [DGPMediaType] = []
                let asyncGroup = DispatchGroup()
                
                for item in selectedAssets {
                    asyncGroup.enter()
                    
                    switch item.asset.mediaType {
                    case .image:
                        self.fetchImageAndCrop(for: item.asset, withCropRect: item.cropRect) { image, exifMeta in
                            let photo = DGPMediaPhoto(image: image.resizedImageIfNeeded(), fromCamera: false, asset: item.asset)
                            resultMediaItems.append(photo)
                            asyncGroup.leave()
                        }
                        
                    case .video:
//                        self.checkVideoLengthAndCrop(for: asset.asset, withCropRect: asset.cropRect) { videoURL in
//                            if let videoURL = videoURL {
//                                let videoItem = YPMediaVideo(thumbnail: thumbnailFromVideoPath(videoURL),
//                                                             videoURL: videoURL, asset: asset.asset)
//                                resultMediaItems.append(YPMediaItem.video(v: videoItem))
//                            } else {
//                                print("YPLibraryVC -> selectedMedia -> Problems with fetching videoURL.")
//                            }
//                            asyncGroup.leave()
//                        }
                        break
                    default:
                        break
                    }
                }
                
                asyncGroup.notify(queue: .main) {
                    multipleItemsCallback(resultMediaItems)
                }
            } else {
            
                let asset = selectedAssets.first!.asset
                switch asset.mediaType {
                case .audio, .unknown:
                    return
                case .video:
                    break
                    /*
                    self.checkVideoLengthAndCrop(for: asset, callback: { videoURL in
                        DispatchQueue.main.async {
                            if let videoURL = videoURL {
                                self.delegate?.libraryViewFinishedLoading()
                                let video = YPMediaVideo(thumbnail: thumbnailFromVideoPath(videoURL),
                                                         videoURL: videoURL, asset: asset)
                                videoCallback(video)
                            } else {
                                print("YPLibraryVC -> selectedMedia -> Problems with fetching videoURL.")
                            }
                        }
                    })*/
                case .image:
                    self.fetchImageAndCrop(for: asset) { image, exifMeta in
                        DispatchQueue.main.async {
                            let photo = DGPMediaPhoto(image: image.resizedImageIfNeeded(), fromCamera: false, asset: asset)
                            photoCallback(photo)
                        }
                    }
                @unknown default:
                    fatalError()
                }
                return
            }
        }
    }
    
    private func targetSize(for asset: PHAsset, cropRect: CGRect) -> CGSize {
           var width = (CGFloat(asset.pixelWidth) * cropRect.width).rounded(.toNearestOrEven)
           var height = (CGFloat(asset.pixelHeight) * cropRect.height).rounded(.toNearestOrEven)
           // round to lowest even number
           width = (width.truncatingRemainder(dividingBy: 2) == 0) ? width : width - 1
           height = (height.truncatingRemainder(dividingBy: 2) == 0) ? height : height - 1
           return CGSize(width: width, height: height)
       }
    
    //MARK: - Actions
    
    @objc func squareButtonTapped() {
        toggleSquareImage()
    }
    
    @objc func toggleMultipleSelection() {
        multipleSelectionActive.toggle()
        refreshMultipleSelection()
    }
    
    public func toggleSquareImage() {
        guard let zoomView = v.assetZoomableView else {
            return
        }
        
        let scale = zoomView.zoomScale
        //let shouldCrop = scale >= 1 && scale < zoomView.squaredZoomScale
        let shouldFit = DGPConfig.shared.library.onlySquare ? true : scale == 1
        fitImage(shouldFit)
    }
    
    public func fitImage(_ fit: Bool) {
        v.assetZoomableView.fitImage(fit)
        v.assetZoomableView.layoutSubviews()
    }
    
}

// MARK: - PHPhotoLibraryChangeObserver

extension DGPLibraryViewController: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange)  {
        DispatchQueue.main.async {
            let collectionView = self.v.collectionView
            if let assetsFetchResults = self.mediaManager.fetchResult,
            let collectionChanges = changeInstance.changeDetails(for: assetsFetchResults) {
                self.mediaManager.fetchResult = collectionChanges.fetchResultAfterChanges
                if collectionChanges.hasMoves || !collectionChanges.hasIncrementalChanges {
                    collectionView?.reloadData()
                } else {
                    collectionView?.performBatchUpdates({
                        if let removedIndexes = collectionChanges.removedIndexes, removedIndexes.count > 0 {
                            collectionView?.deleteItems(at: indexPaths(section: 0, set: removedIndexes))
                        }
                        if let insertedIndexes = collectionChanges.insertedIndexes, insertedIndexes.count > 0 {
                            collectionView?.insertItems(at: indexPaths(section: 0, set: insertedIndexes))
                        }
                        if let changedIndexes = collectionChanges.changedIndexes, changedIndexes.count > 0 {
                            collectionView?.reloadItems(at: indexPaths(section: 0, set: changedIndexes))
                        }
                    })
                }
            }
        }
    }
}
