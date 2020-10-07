//
//  DGPLibraryViewCell.swift
//  DGPImagePicker
//
//  Created by Daniel Gallego Peralta on 08/07/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import UIKit
import DGPLibrary

class DGPLibraryViewCell: UICollectionViewCell {

    var imageView : UIImageView!
    var overlayView : UIView!
    var checkmark : Checkmark!
    
    var representedAssetIdentifier: String!
    
    static func returnID() -> String {
        return "DGPLibraryViewCell"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        imageView = UIImageView()
        overlayView = UIView()
        checkmark = Checkmark()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        checkmark.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(imageView)
        contentView.addSubview(overlayView)
        contentView.addSubview(checkmark)
        
        let sizeButton : CGFloat = 25.0
        
        NSLayoutConstraint.activate( [
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            //
            
            overlayView.topAnchor.constraint(equalTo: imageView.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            
            //
            
            checkmark.widthAnchor.constraint(equalToConstant: sizeButton),
            checkmark.heightAnchor.constraint(equalToConstant: sizeButton),
            checkmark.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            checkmark.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            
            
        ])
        
        
        imageView.contentMode = .scaleAspectFill
        refreshSelection()
        clipsToBounds = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
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
