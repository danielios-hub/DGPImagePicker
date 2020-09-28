//
//  DGPLibraryViewCell.swift
//  SocialGaming
//
//  Created by Daniel Gallego Peralta on 08/07/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import UIKit

class DGPLibraryViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView : UIImageView!
    @IBOutlet weak var overlayView : UIView!
    @IBOutlet weak var checkmark : Checkmark!
    
    var representedAssetIdentifier: String!
    
    static func returnID() -> String {
        return "DGPLibraryViewCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        overlayView.alpha = 0
        imageView.contentMode = .scaleAspectFill
    }
    
    override var isSelected: Bool {
        didSet {refreshSelection()}
    }
    
    private func refreshSelection() {
        let config = DGPConfig.shared.library
        if config.multipleSelectionAllowed &&  config.multipleSelectionActive {
            checkmark.isHidden = isSelected ? false : true
            overlayView.alpha = 0
        } else {
            
            overlayView.alpha = isSelected ? 0.6 : 0
            checkmark.isHidden = true
        }
    }

}
