//
//  DGPLibraryViewController+CollectionView.swift
//  DGPImagePicker
//
//  Created by Daniel Gallego Peralta on 08/07/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import UIKit 

extension DGPLibraryViewController {
    
    func setupCollectionView() {
        v.collectionView.delegate = self
        v.collectionView.dataSource = self
        v.collectionView.register(UINib(nibName: DGPLibraryViewCell.returnID(), bundle: nil), forCellWithReuseIdentifier: DGPLibraryViewCell.returnID())
    }
    
    
    //MARK: - Multiple Selection
    
    func refreshMultipleSelection() {
        v.setButtonMultiple()
        let selectedIndexPaths = v.collectionView.indexPathsForSelectedItems
        
        selectedIndexPaths?.forEach {
            v.collectionView.deselectItem(at: $0, animated: false)
        }
        
        v.collectionView.allowsMultipleSelection = multipleSelectionActive
        v.collectionView.selectItem(at: selectedIndexPaths?.first, animated: false, scrollPosition: UICollectionView.ScrollPosition())
    }
    
    func addToSelection(indexPath: IndexPath) {
        let asset = mediaManager.fetchResult[indexPath.item]
        selection.append(
            DGPLibrarySelection(
                index: indexPath.row,
                assetIdentifier: asset.localIdentifier
            )
        )
    }
    
    func isInSelectionPool(indexPath: IndexPath) -> Bool {
        return selection.contains(where: { $0.assetIdentifier == mediaManager.fetchResult[indexPath.row].localIdentifier })
    }
    
    func removeFromSelection(indexPath: IndexPath) {
        selection.removeAll {
            $0.assetIdentifier == mediaManager.fetchResult[indexPath.row].localIdentifier
        }
    }
    
}

extension DGPLibraryViewController : UICollectionViewDataSource {
    
    //MARK: - UICollectionView DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaManager.fetchResult.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = mediaManager.fetchResult[indexPath.item]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DGPLibraryViewCell.returnID(),
                                                            for: indexPath) as? DGPLibraryViewCell else {
                                                                fatalError("unexpected cell in collection view")
        }
        
        cell.representedAssetIdentifier = asset.localIdentifier
        //cell.multipleSelectionIndicator.selectionColor =
         //   YPConfig.colors.multipleItemsSelectedCircleColor ?? YPConfig.colors.tintColor
        mediaManager.imageManager?.requestImage(for: asset,
                                   targetSize: cellSize(),
                                   contentMode: .aspectFill,
                                   options: nil) { image, _ in
                                    // The cell may have been recycled when the time this gets called
                                    // set image only if it's still showing the same asset.
                                    if cell.representedAssetIdentifier == asset.localIdentifier && image != nil {
                                        cell.imageView.image = image
                                    }
        }
        
        /*let isVideo = (asset.mediaType == .video)
        cell.durationLabel.isHidden = !isVideo
        cell.durationLabel.text = isVideo ? YPHelper.formattedStrigFrom(asset.duration) : ""
        cell.multipleSelectionIndicator.isHidden = !multipleSelectionEnabled*/
        //cell.isSelected = currentlySelectedIndex == indexPath.row
        
        // Set correct selection number
        /*
        if let index = selection.firstIndex(where: { $0.assetIdentifier == asset.localIdentifier }) {
            let currentSelection = selection[index]
            if currentSelection.index < 0 {
                selection[index] = YPLibrarySelection(index: indexPath.row,
                                                      cropRect: currentSelection.cropRect,
                                                      scrollViewContentOffset: currentSelection.scrollViewContentOffset,
                                                      scrollViewZoomScale: currentSelection.scrollViewZoomScale,
                                                      assetIdentifier: currentSelection.assetIdentifier)
            }
            cell.multipleSelectionIndicator.set(number: index + 1) // start at 1, not 0
        } else {
            cell.multipleSelectionIndicator.set(number: nil)
        }*/

        // Prevent weird animation where thumbnail fills cell on first scrolls.
        UIView.performWithoutAnimation {
            cell.layoutIfNeeded()
        }
        return cell
    }
    
    
}

extension DGPLibraryViewController : UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //let previouslySelectedIndexPath = IndexPath(row: currentlySelectedIndex, section: 0)
        currentlySelectedIndex = indexPath.row

        
        changeAsset(mediaManager.fetchResult[indexPath.row])
        /*
        panGestureHelper.resetToOriginalState()
        
        // Only scroll cell to top if preview is hidden.
        if !panGestureHelper.isImageShown {
            collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        }
        v.refreshImageCurtainAlpha()
        */
        if multipleSelectionActive {
            if !isInSelectionPool(indexPath: indexPath) {
                addToSelection(indexPath: indexPath)
            }
        } else {
            addToSelection(indexPath: indexPath)
            
            
            // Force deseletion of previously selected cell.
            // In the case where the previous cell was loaded from iCloud, a new image was fetched
            // which triggered photoLibraryDidChange() and reloadItems() which breaks selection.
            //
            //if let previousCell = collectionView.cellForItem(at: previouslySelectedIndexPath) as? DGPLibraryViewCell {
            //    previousCell.isSelected = false
            //}
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        removeFromSelection(indexPath: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        //return isProcessing == false
        return true
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        //return isProcessing == false
        if currentlySelectedIndex == indexPath.item {
            return true
        } else {
            currentlySelectedIndex = indexPath.row
            changeAsset(mediaManager.fetchResult[indexPath.row])
            return false
        }
    }
    
    func cellSize() -> CGSize {
        let size = UIScreen.main.bounds.width/4 * UIScreen.main.scale
        return CGSize(width: size, height: size)
    }
}

extension DGPLibraryViewController : UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let margins = DGPConfig.shared.library.spacingBetweenItems * CGFloat(DGPConfig.shared.library.numberOfItemsInRow - 1)
        let width = (collectionView.frame.width - margins) / CGFloat(DGPConfig.shared.library.numberOfItemsInRow)
        return CGSize(width: width, height: width)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return DGPConfig.shared.library.spacingBetweenItems
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return DGPConfig.shared.library.spacingBetweenItems
    }
}
