//
//  DGPAssetZoomableView.swift
//  DGPImagePicker
//
//  Created by Daniel Gallego Peralta on 08/07/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import UIKit
import Photos

protocol DGPAssetZoomableViewDelegate: class {
    func assetZoomableDidLayoutSubviews(_ view: DGPAssetZoomableView)
    func assetZoomableDidZoom()
    func assetZoomableDidEndZooming()
}

class DGPAssetZoomableView: UIScrollView {

    public weak var assetDelegate : DGPAssetZoomableViewDelegate?
    public var cropAreaDidChange = {}
    var photoImageView = UIImageView()
    var videoView = DGPVideoView()
    
    public var isVideoMode = false
    public var squaredZoomScale: CGFloat = 1
    fileprivate var currentAsset: PHAsset?
    
    public var minWidth: CGFloat? = DGPConfig.shared.library.minWidthForItem
    
    // Image view of the asset for convenience. Can be video preview image view or photo image view.
    public var assetImageView: UIImageView {
        //return isVideoMode ? videoView.previewImageView : photoImageView
        return photoImageView
    }
    
    //MARK: - Life cicle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        assetDelegate?.assetZoomableDidLayoutSubviews(self)
    }
    
    private func setup() {
        frame.size = .zero
        clipsToBounds = true
        photoImageView.frame = .zero
        videoView.frame = .zero
        maximumZoomScale = 4
        minimumZoomScale = 1
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        delegate = self
        alwaysBounceVertical = true
        alwaysBounceHorizontal = true
        isScrollEnabled = true
    }
    
    //MARK: - Manage scroll and image zoom
    
    public func fitImage(_ fit: Bool, animated: Bool = false) {
        squaredZoomScale = fit ? calculateSquaredZoomScale() : 1.0
        setZoomScale(squaredZoomScale, animated: animated)
    }
    
    public func setImage(_ photo: PHAsset,
                         mediaManager: LibraryMediaManager,
                         completion: @escaping (Bool) -> Void,
                         updateCropInfo: @escaping () -> Void) {
        guard currentAsset != photo else {
            DispatchQueue.main.async { completion(false) }
            return
        }
        currentAsset = photo
        
        
        mediaManager.imageManager?.fetch(photo: photo) { [weak self] image, isLowResIntermediaryImage in
            guard let strongSelf = self else { return }
            
            if strongSelf.photoImageView.isDescendant(of: strongSelf) == false {
                strongSelf.isVideoMode = false
                strongSelf.videoView.removeFromSuperview()
                //strongSelf.videoView.showPlayImage(show: false)
                //strongSelf.videoView.deallocate()
                strongSelf.addSubview(strongSelf.photoImageView)
            
                strongSelf.photoImageView.contentMode = .scaleAspectFill
                strongSelf.photoImageView.clipsToBounds = true
            }
            
            strongSelf.photoImageView.image = image
           
            strongSelf.setAssetFrame(for: strongSelf.photoImageView, with: image)
                
            // Stored crop position in multiple selection
           // if let scp173 = storedCropPosition {
            //    strongSelf.applyStoredCropPosition(scp173)
                //MARK: add update CropInfo after multiple
             //   updateCropInfo()
            //}
            
            completion(isLowResIntermediaryImage)
        }
    }
    
    fileprivate func setAssetFrame(`for` view: UIView, with image: UIImage) {
        // Reseting the previous scale
        self.minimumZoomScale = 1
        self.zoomScale = 1
        
        // Calculating and setting the image view frame depending on screenWidth
        let screenWidth: CGFloat = UIScreen.main.bounds.width
        let w = image.size.width
        let h = image.size.height

        var aspectRatio: CGFloat = 1
        var zoomScale: CGFloat = 1

        if w > h { // Landscape
            aspectRatio = h / w
            view.frame.size.width = screenWidth
            view.frame.size.height = screenWidth * aspectRatio
        } else if h > w { // Portrait
            aspectRatio = w / h
            view.frame.size.width = screenWidth * aspectRatio
            view.frame.size.height = screenWidth
            
            if let minWidth = minWidth {
                let k = minWidth / screenWidth
                zoomScale = (h / w) * k
            }
        } else { // Square
            view.frame.size.width = screenWidth
            view.frame.size.height = screenWidth
        }
        
        // Centering image view
        view.center = center
        centerAssetView()
        
        // Setting new scale
        minimumZoomScale = zoomScale
        self.zoomScale = zoomScale
    }
    
    /// Calculate zoom scale which will fit the image to square
    fileprivate func calculateSquaredZoomScale() -> CGFloat {
        guard let image = assetImageView.image else {
            return 1.0
        }
        
        var squareZoomScale: CGFloat = 1.0
        let w = image.size.width
        let h = image.size.height
        
        if w > h { // Landscape
            squareZoomScale = (w / h)
        } else if h > w { // Portrait
            squareZoomScale = (h / w)
        }
        
        return squareZoomScale
    }
    
    // Centring the image frame
    fileprivate func centerAssetView() {
        let assetView = isVideoMode ? videoView : photoImageView
        let scrollViewBoundsSize = self.bounds.size
        var assetFrame = assetView.frame
        let assetSize = assetView.frame.size
        
        assetFrame.origin.x = (assetSize.width < scrollViewBoundsSize.width) ?
            (scrollViewBoundsSize.width - assetSize.width) / 2.0 : 0
        assetFrame.origin.y = (assetSize.height < scrollViewBoundsSize.height) ?
            (scrollViewBoundsSize.height - assetSize.height) / 2.0 : 0.0
        
        assetView.frame = assetFrame
    }

}

extension DGPAssetZoomableView : UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return isVideoMode ? videoView : photoImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        assetDelegate?.assetZoomableDidZoom()
        centerAssetView()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        guard let _ = view else {
            return
        }
        
        if DGPConfig.shared.library.onlySquare && scale < squaredZoomScale {
            fitImage(true, animated: true)
        }
        
        assetDelegate?.assetZoomableDidEndZooming()
        cropAreaDidChange()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        cropAreaDidChange()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        cropAreaDidChange()
    }
}
