//
//  DGPMenu.swift
//  DGPImagePicker
//
//  Created by Daniel Gallego Peralta on 05/10/2020.
//

import UIKit

class DGPMenu: UIView {

    var stackButtons : UIStackView!
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
        stackButtons = UIStackView(frame: .zero)
        scrollView = UIScrollView(frame: .zero)
        
        stackButtons.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(scrollView)
        addSubview(stackButtons)
        
        NSLayoutConstraint.activate([
            stackButtons.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            stackButtons.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackButtons.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stackButtons.heightAnchor.constraint(equalToConstant: defaultHeightToolbar),
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: stackButtons.topAnchor)
        ])
        
        scrollView.clipsToBounds = true
        
        stackButtons.axis = .horizontal
        stackButtons.distribution = .equalSpacing
        stackButtons.alignment = .center
        
        stackButtons.backgroundColor = .red
    }
    
    public func addButtons(buttonItems: [UIButton]) {
        stackButtons.subviews.forEach {
            $0.removeFromSuperview()
        }
        
        for buttonItem in buttonItems {
            buttonItem.setTitleColor(.black, for: .focused)
            buttonItem.setTitleColor(.lightGray, for: .normal)
            stackButtons.addArrangedSubview(buttonItem)
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
