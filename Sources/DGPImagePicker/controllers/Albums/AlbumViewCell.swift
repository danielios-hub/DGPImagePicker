//
//  AlbumViewCell.swift
//  DGPImagePicker
//
//  Created by Daniel Gallego Peralta on 05/09/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import UIKit

class AlbumViewCell: UITableViewCell {

    var labelTitle : UILabel
    var imageAlbum : UIImageView
    var labelNumber : UILabel
    
    static let IMAGE_SIZE : CGFloat = 70
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        labelTitle = UILabel()
        imageAlbum = UIImageView()
        labelNumber = UILabel()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        contentView.clipsToBounds = true
        
        labelTitle.translatesAutoresizingMaskIntoConstraints = false
        imageAlbum.translatesAutoresizingMaskIntoConstraints = false
        labelNumber.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(labelTitle)
        contentView.addSubview(imageAlbum)
        contentView.addSubview(labelNumber)
        
        contentView.addConstraints([
            imageAlbum.widthAnchor.constraint(equalToConstant: AlbumViewCell.IMAGE_SIZE),
            imageAlbum.heightAnchor.constraint(equalToConstant: AlbumViewCell.IMAGE_SIZE),
            imageAlbum.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            imageAlbum.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            labelTitle.leadingAnchor.constraint(equalTo: imageAlbum.trailingAnchor, constant: 20),
            labelTitle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -15)
        ])
        
        NSLayoutConstraint.activate([
            labelNumber.leadingAnchor.constraint(equalTo: imageAlbum.trailingAnchor, constant: 20),
            labelNumber.topAnchor.constraint(equalTo: labelTitle.bottomAnchor, constant: 5)
        ])
        
        labelTitle.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.regular)
        labelNumber.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
    }


}
