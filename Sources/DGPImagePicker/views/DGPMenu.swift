//
//  DGPMenu.swift
//  DGPImagePicker
//
//  Created by Daniel Gallego Peralta on 05/10/2020.
//

import UIKit

class DGPMenu: UIView {

    var toolbar : UIToolbar!
    var scrollView  :UIScrollView!
    
    let defaultHeightToolbar : CGFloat = 44
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupScrollView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        toolbar = UIToolbar(frame: .zero)
        scrollView = UIScrollView(frame: .zero)
        
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(scrollView)
        addSubview(toolbar)
        
        NSLayoutConstraint.activate([
            toolbar.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            toolbar.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: defaultHeightToolbar),
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: toolbar.topAnchor)
        ])
        
        scrollView.clipsToBounds = true 
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
