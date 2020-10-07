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
        let containerStack = UIView()
        stackButtons = UIStackView(frame: .zero)
        scrollView = UIScrollView(frame: .zero)
        
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        stackButtons.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(scrollView)
        containerStack.addSubview(stackButtons)
        addSubview(containerStack)
        
        NSLayoutConstraint.activate([
            containerStack.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            containerStack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerStack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            containerStack.heightAnchor.constraint(equalToConstant: defaultHeightToolbar),
            stackButtons.topAnchor.constraint(equalTo: containerStack.topAnchor),
            stackButtons.leadingAnchor.constraint(equalTo: containerStack.leadingAnchor, constant: 10),
            stackButtons.trailingAnchor.constraint(equalTo: containerStack.trailingAnchor, constant: -10),
            stackButtons.bottomAnchor.constraint(equalTo: containerStack.bottomAnchor),
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: stackButtons.topAnchor)
        ])
        
        scrollView.clipsToBounds = true
        
        stackButtons.axis = .horizontal
        stackButtons.distribution = .equalSpacing
        stackButtons.alignment = .center
        containerStack.backgroundColor = .systemGroupedBackground
        
        
        
       
    }
    
    public func addButtons(buttonItems: [UIButton]) {
        //stackButtons.subviews.forEach {
        //    $0.removeFromSuperview()
        //}
        
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
