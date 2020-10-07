//
//  DGPMenuViewController.swift
//  DGPImagePicker
//
//  Created by Daniel Gallego Peralta on 05/07/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import UIKit

protocol DGPMenuPageDelegate: class {
    func DGP_DidSelectController(_ vc: UIViewController)
}

internal class DGPMenuViewController: UIViewController {

    weak var delegate: DGPMenuPageDelegate?
    public var controllers = [UIViewController]() { didSet { reload() } }
    
    private var currentPage = 0 {
        didSet {
            for (i, button) in buttonItems.enumerated() {
                button.isSelected = i == currentPage
            }
        }
    }
    
    public var currentController : UIViewController {
        return controllers[currentPage]
    }
    
    private var buttonItems = [UIButton]()
    
    private var myView: DGPMenu {
        return view as! DGPMenu
    }

    override func loadView() {
        view = DGPMenu(frame: .zero)
        
        myView.scrollView.contentInsetAdjustmentBehavior = .automatic
        myView.scrollView.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func selectPage(_ page: Int, scrollTo: Bool, animated: Bool = true) {
        if scrollTo {
            let x = CGFloat(page) * UIScreen.main.bounds.width
            myView.scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: animated)
        }
        
        guard page != currentPage && page >= 0 && page < controllers.count else {
            return
        }
        currentPage = page
        
        delegate?.DGP_DidSelectController(controllers[page])
    }
    
    public func startOnPage(_ page: Int) {
        selectPage(page, scrollTo: true, animated: false)
    }
    
    public func reload() {
        let viewWidth: CGFloat = UIScreen.main.bounds.width
        let scrollableWidth: CGFloat = CGFloat(controllers.count) * CGFloat(viewWidth)
        myView.scrollView.contentSize = CGSize(width: scrollableWidth, height: 0)
  
        for (index, viewController) in controllers.enumerated() {
            addChild(viewController)
            let originX : CGFloat = CGFloat(index) * viewWidth
            myView.scrollView.addSubview(viewController.view)
            
            viewController.view!.translatesAutoresizingMaskIntoConstraints = false
            let width = NSLayoutConstraint(item: viewController.view!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: viewWidth)
            
            let left = NSLayoutConstraint(item: viewController.view!, attribute: .left, relatedBy: .equal, toItem: myView.scrollView, attribute: .left, multiplier: 1, constant: originX)
            
            let top = NSLayoutConstraint(item: viewController.view!, attribute: .top, relatedBy: .equal, toItem: myView.scrollView, attribute: .top, multiplier: 1, constant: 0)
            let height = NSLayoutConstraint(item: viewController.view!, attribute: .height, relatedBy: .equal, toItem: myView.scrollView, attribute: .height, multiplier: 1, constant: 0)
            self.myView.addConstraints([width, height, top, left])
            
            
            viewController.didMove(toParent: self)
        }
        
        
        for (index, controller) in controllers.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(controller.title, for: .normal)
            button.titleLabel?.font = .boldSystemFont(ofSize: 14)
            button.addTarget(self, action:  #selector(changeController(_:)), for: .touchDown)
            button.tag = index
            buttonItems.append(button)
        }
        
        self.myView.addButtons(buttonItems: buttonItems)
        
    }
    
    @objc func changeController(_ sender: UIButton) {
        selectPage(sender.tag, scrollTo: true)
    }

}

extension DGPMenuViewController : UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }

    public func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                          withVelocity velocity: CGPoint,
                                          targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if !DGPConfig.shared.screens.isEmpty {
            let menuIndex = (targetContentOffset.pointee.x + myView.frame.size.width) / myView.frame.size.width
            let selectedIndex = Int(round(menuIndex)) - 1
            if selectedIndex != currentPage {
                selectPage(selectedIndex, scrollTo: false)
            }
        }
    }
}
