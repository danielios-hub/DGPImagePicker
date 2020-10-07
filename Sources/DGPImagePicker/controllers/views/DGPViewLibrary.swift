//
//  DGPViewLibrary.swift
//  DGPImagePicker
//
//  Created by Daniel Gallego Peralta on 06/07/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import UIKit

class DGPViewLibrary: UIView {
    
    var collectionView: UICollectionView!
    var assetZoomableView: DGPAssetZoomableView!
    var assetViewContainer: DGPAssetContainerView!
    
    var buttonExpand : UIButton!
    var buttonMultiple : UIButton!
    
    let maxNumberWarningView = UIView()
    let maxNumberWarningLabel = UILabel()
    let progressView = UIProgressView()
    let line = UIView()
    var shouldShowLoader = false
    
    var flowLayout: UICollectionViewFlowLayout {
        let _flowLayout = UICollectionViewFlowLayout()
        _flowLayout.scrollDirection = UICollectionView.ScrollDirection.vertical
        return _flowLayout
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        assetViewContainer = DGPAssetContainerView(frame: .zero)
        assetZoomableView = DGPAssetZoomableView(frame: .zero)
        buttonExpand = UIButton()
        buttonMultiple = UIButton()
        let containerCollection = UIView()
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        assetViewContainer.translatesAutoresizingMaskIntoConstraints = false
        assetZoomableView.translatesAutoresizingMaskIntoConstraints = false
        buttonExpand.translatesAutoresizingMaskIntoConstraints = false
        buttonMultiple.translatesAutoresizingMaskIntoConstraints = false
        containerCollection.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        assetViewContainer.addSubview(assetZoomableView)
        addSubview(assetViewContainer)
        addSubview(buttonExpand)
        addSubview(buttonMultiple)
        containerCollection.addSubview(collectionView)
        addSubview(containerCollection)
        
        let sizeButton: CGFloat = 40.0
        
        NSLayoutConstraint.activate([
            assetZoomableView.topAnchor.constraint(equalTo: assetViewContainer.topAnchor),
            assetZoomableView.leadingAnchor.constraint(equalTo: assetViewContainer.leadingAnchor),
            assetZoomableView.trailingAnchor.constraint(equalTo: assetViewContainer.trailingAnchor),
            assetZoomableView.bottomAnchor.constraint(equalTo: assetViewContainer.bottomAnchor),
            
            //aspect ratio
            assetViewContainer.heightAnchor.constraint(equalTo: self.widthAnchor),
            assetViewContainer.topAnchor.constraint(equalTo: self.topAnchor),
            assetViewContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            assetViewContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            assetViewContainer.bottomAnchor.constraint(equalTo: containerCollection.topAnchor),
            
            buttonExpand.widthAnchor.constraint(equalToConstant: sizeButton),
            buttonExpand.heightAnchor.constraint(equalToConstant: sizeButton),
            buttonExpand.leadingAnchor.constraint(equalTo: assetViewContainer.leadingAnchor, constant: 10),
            buttonExpand.bottomAnchor.constraint(equalTo: assetViewContainer.bottomAnchor, constant: -10),
            
            //
            buttonMultiple.widthAnchor.constraint(equalToConstant: sizeButton),
            buttonMultiple.heightAnchor.constraint(equalToConstant: sizeButton),
            buttonMultiple.trailingAnchor.constraint(equalTo: assetViewContainer.trailingAnchor, constant: -10),
            buttonMultiple.bottomAnchor.constraint(equalTo: assetViewContainer.bottomAnchor, constant: -10),
            
            //
            
            collectionView.topAnchor.constraint(equalTo: containerCollection.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: containerCollection.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: containerCollection.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: containerCollection.bottomAnchor),
            
            //
            
            containerCollection.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerCollection.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            containerCollection.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        assetViewContainer.assetZoomView = assetZoomableView
        buttonExpand.isHidden = true
        buttonMultiple.isHidden = true
        
        collectionView.backgroundColor = .red
        assetViewContainer.backgroundColor = .blue
        assetZoomableView.backgroundColor = .yellow
        
        setupButtons()
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
