//
//  DGPMenuView.swift
//  SocialGaming
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
        let myCustomView: DGPMenuView = .fromNib()
        return myCustomView
    }
    
}
