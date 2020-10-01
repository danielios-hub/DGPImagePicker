//
//  DGPImagePicker.swift
//  DGPImagePicker
//
//  Created by Daniel Gallego Peralta on 05/07/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import UIKit
import DGPExtensionCore
import DGPLibrary

public protocol DGPImagePickerDelegate: class {
    func DGP_ImagePickerDidSelectItems(_ DGPImagePicker: DGPImagePicker,  items: [DGPMediaType])
    func DGP_ImagePickercancel(_ DGPImagePicker: DGPImagePicker)
}

public class DGPImagePicker: UINavigationController {

    private let picker: DGPController!

    public convenience init(delegate: DGPImagePickerDelegate) {
        self.init(configuration: DGPConfig.shared, delegateImagePicker: delegate)
    }
    
    public required init(configuration: DGPConfig, delegateImagePicker: DGPImagePickerDelegate) {
        picker = DGPController()
        DGPConfig.shared = configuration
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        picker.delegateImagePicker = delegateImagePicker
        navigationBar.tintColor = DGPConfig.shared.barTintColor
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [picker]
    }
    

    

}
