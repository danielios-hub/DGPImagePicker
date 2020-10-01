//
//  DGPMenuView.swift
//  DGPImagePicker
//
//  Created by Daniel Gallego Peralta on 05/07/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import UIKit

class DGPMenuView: UIView {

    @IBOutlet weak var toolbar : UIToolbar!
    @IBOutlet weak var scrollView  :UIScrollView!
    
    let defaultHeightToolbar : CGFloat = 44
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = false
        setupScrollView()
    }
    
    public func addButtons(buttonItems: [UIBarButtonItem]) {
        toolbar.items = []
       
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        for buttonItem in buttonItems {
            toolbar.items?.append(flexible)
            toolbar.items!.append(buttonItem)
            toolbar.items?.append(flexible)
        }
        
    }

    private func setupScrollView() {
        scrollView.clipsToBounds = false
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.bounces = false
    }

}

extension DGPMenuView {
    
    class func xibView() -> DGPMenuView? {
        let myCustomView: DGPMenuView = .fromNib3()
        return myCustomView
        
//        let bundle = Bundle(for: DGPImagePicker.self)
//        let nib = UINib(nibName: "DGPMenuView",
//                        bundle: bundle)
//        let xibView = nib.instantiate(withOwner: self, options: nil)[0] as? DGPMenuView
//        return xibView
        
        
//        let nib = UINib(nibName: String(describing: self), bundle: Bundle(for: type(of: self)))
//
//        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
//            fatalError("Failed to instantiate nib \(nib)")
//        }
        
        return nil
    }
    
}

extension UIView {
    
    class func fromNib2<T: UIView>(bundleID: String? = nil) -> T {
        if let bundleID = bundleID,
            let bundle = Bundle(identifier: bundleID) {
            return bundle.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
        } else {
            return Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
        }
    }
    
    class func fromNib3<T: UIView>() -> T {
        return Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}
