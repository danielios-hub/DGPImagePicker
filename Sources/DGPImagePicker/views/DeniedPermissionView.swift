//
//  DeniedPermissionView.swift
//  DGPImagePicker
//
//  Created by Daniel Gallego Peralta on 07/09/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import UIKit

class DeniedPermissionView: UIView {

    var title: String
    var descriptionText : String
    var linkText : String
    
    init(title: String, descriptionText: String, linkText: String) {
        self.title = title
        self.descriptionText = descriptionText
        self.linkText = linkText
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        backgroundColor = .gray_light_dusty
        
        let labelTitle = UILabel()
        let labelDescription = UILabel()
        let buttonLink = UIButton(type: .custom)
        
        labelTitle.translatesAutoresizingMaskIntoConstraints = false
        labelDescription.translatesAutoresizingMaskIntoConstraints = false
        buttonLink.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(labelTitle)
        addSubview(labelDescription)
        addSubview(buttonLink)
        
        NSLayoutConstraint.activate([
            labelTitle.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -100),
            labelTitle.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            labelDescription.topAnchor.constraint(equalTo: labelTitle.bottomAnchor, constant: 40),
            labelDescription.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            buttonLink.topAnchor.constraint(equalTo: labelDescription.bottomAnchor, constant: 40),
            buttonLink.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
        
        labelTitle.text = title
        labelDescription.text = descriptionText
        buttonLink.setTitle(linkText, for: .normal)
        
        buttonLink.setTitleColor(.systemBlue, for: .normal)
        buttonLink.addTarget(self, action: #selector(openSettings), for: .touchDown)
        
        labelTitle.font = .boldSystemFont(ofSize: 22)
        labelDescription.font = .systemFont(ofSize: 14)
    
    }
    
    @objc func openSettings() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
}
