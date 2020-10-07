//
//  DGPController.swift
//  DGPImagePicker
//
//  Created by Daniel Gallego Peralta on 05/07/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import UIKit

internal class DGPController: DGPMenuViewController {
    
    weak var delegateImagePicker: DGPImagePickerDelegate?
    private var mode : DGPMode = .library
    
    private var libraryVC: DGPLibraryViewController?
    private var cameraVC: DGPCameraViewController?
    private var videoVC: DGPVideoViewController?
    
    private var albumsManager = DGPAlbumManager()
    
    //MARK: - Life cicle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        
        var listControllers = [UIViewController]()
        
        if DGPConfig.shared.screens.contains(.library) {
            libraryVC = DGPLibraryViewController()
            if let vc = libraryVC {
                listControllers.append(vc)
                libraryVC!.title = textConstants.library
            }
        }
        
        if DGPConfig.shared.screens.contains(.camera) {
            cameraVC = DGPCameraViewController()
            if let vc = cameraVC {
                vc.didSelectImage = { [weak self] img in
                    
                    guard let strongSelf = self, let nav = strongSelf.navigationController as? DGPImagePicker else {
                        return
                    }
                    
                    let media = DGPMediaPhoto(image: img)
                    self?.delegateImagePicker?.DGP_ImagePickerDidSelectItems(nav, items: [media])
                }
                listControllers.append(vc)
                cameraVC!.title = textConstants.photo
            }
        }
        
        if DGPConfig.shared.screens.contains(.video) {
            videoVC = DGPVideoViewController()
            if let vc = videoVC {
                vc.didSelectVideo = { [weak self] url in
                    if let strongSelf = self, let nav = self?.navigationController as? DGPImagePicker {
                        let media = DGPMediaVideo(url: url, fromCamera: true)
                        strongSelf.delegateImagePicker?.DGP_ImagePickerDidSelectItems(nav, items: [media])
                    }
                }
                listControllers.append(vc)
                videoVC!.title = textConstants.video
            }
        }
        
        controllers = listControllers
        
        startOnPage(0)
        setupNav()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DGP_DidSelectController(currentController)
    }
    
    //MARK: - Setup
    
    private func setTitleViewWithTitle(aTitle: String) {
        let titleView = UIView()
        
        let label = UILabel()
        label.text = aTitle
        
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 17)
        
        if let navBarTitleFont = UINavigationBar.appearance().titleTextAttributes?[.font] as? UIFont {
            label.font = navBarTitleFont
        }
        
        let tintColor : UIColor
        if let navBarTitleColor = DGPConfig.shared.titleColor {
            tintColor = navBarTitleColor
        } else if let navBarTitleColor = UINavigationBar.appearance().titleTextAttributes?[.foregroundColor] as? UIColor {
            tintColor = navBarTitleColor
        } else {
            tintColor = DGPConfig.shared.tintColor
        }
        
        label.textColor = tintColor
        titleView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        titleView.addConstraints([
            NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: label.superview, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: label.superview, attribute: .centerY, multiplier: 1, constant: 0),
        ])
        
        if mode == .library {
            let arrow = UIImageView()
            arrow.image = UIImage(symbol: .chevronDown)
            arrow.image = arrow.image?.withRenderingMode(.alwaysTemplate)
            arrow.tintColor = tintColor
            
            titleView.addSubview(arrow)
            arrow.translatesAutoresizingMaskIntoConstraints = false
            
            titleView.addConstraints([
                NSLayoutConstraint(item: arrow, attribute: .leading, relatedBy: .equal, toItem: label, attribute: .trailing, multiplier: 1, constant: 5),
                NSLayoutConstraint(item: arrow, attribute: .centerY, relatedBy: .equal, toItem: arrow.superview, attribute: .centerY, multiplier: 1, constant: 0),
            ])
            
            let button = UIButton()
            titleView.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            titleView.addConstraints([
                NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: button.superview, attribute: .width, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: button.superview, attribute: .height, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: button.superview, attribute: .centerX, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: button, attribute: .centerY, relatedBy: .equal, toItem: button.superview, attribute: .centerY, multiplier: 1, constant: 0)
            ])
            
            button.addTarget(self, action: #selector(selectAlbumbs), for: .touchUpInside)
        }
        
        titleView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        navigationItem.titleView = titleView
    }
    
    private func setupNav() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: textConstants.cancel,
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(closeAction))
        switch mode {
        case .library:
            setTitleViewWithTitle(aTitle: libraryVC?.title ?? "")
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: textConstants.next,
                                                                style: .done,
                                                                target: self,
                                                                action: #selector(nextAction))
            navigationItem.rightBarButtonItem?.tintColor = DGPConfig.shared.tintColor
            
            
            checkEnabledButton()

        case .camera:
            navigationItem.titleView = nil
            setTitleViewWithTitle(aTitle: cameraVC?.title ?? "")
            navigationItem.rightBarButtonItem = nil
        case .video:
            navigationItem.titleView = nil
            setTitleViewWithTitle(aTitle: videoVC?.title ?? "")
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    //MARK: - Actions
    
    @objc func closeAction() {
        delegateImagePicker?.DGP_ImagePickercancel(self.navigationController! as! DGPImagePicker)
        
    }
    
    @objc func nextAction() {
        guard let libraryVC = libraryVC else {
            return
        }
        
        if mode == .library {
            libraryVC.doAfterPermissionCheckLibrary { [weak self] in
                libraryVC.selectedMedia(photoCallback: { (photo) in
                    self?.delegateImagePicker?.DGP_ImagePickerDidSelectItems(self?.navigationController as! DGPImagePicker, items: [photo])
                }, videoCallback: { (video) in
                    self?.delegateImagePicker?.DGP_ImagePickerDidSelectItems(self?.navigationController as! DGPImagePicker, items: [video])
                }) { (items) in
                    self?.delegateImagePicker?.DGP_ImagePickerDidSelectItems(self?.navigationController as! DGPImagePicker, items: items)
                }
            }
        }
    }
    
    @objc func selectAlbumbs() {
        let albumVC = AlbumsViewController(manager: albumsManager)
        let nav = UINavigationController(rootViewController: albumVC)
        
        albumVC.didSelectAlbum = { [weak self] album in
            self?.libraryVC?.changeAlbum(album)
            self?.setTitleViewWithTitle(aTitle: album.title)
            nav.dismiss(animated: true, completion: nil)
        }
        
        present(nav, animated: true, completion: nil)
    }
    
    //MARK: - Utils
    
    func checkEnabledButton() {
        navigationItem.rightBarButtonItem?.isEnabled = libraryVC?.selection.count ?? 0 >= 1
    }
    
    func stopCurrentCamera() {
        switch mode {
        case .library:
            //stop player library when has one
            break
        case .camera:
            cameraVC?.stopCamera()
        case .video:
            videoVC?.stopCamera()
        }
    }

}

extension DGPController : DGPMenuPageDelegate {
    //MARK: - MenuPageDelegate
    
    func DGP_DidSelectController(_ vc: UIViewController) {
        stopCurrentCamera()
        
        // Re-trigger permission check
        if let libraryVC = vc as? DGPLibraryViewController {
            mode = .library
            libraryVC.start()
        } else if let cameraVC = vc as? DGPCameraViewController {
            mode = .camera
            cameraVC.start()
        } else if let videoVC = vc as? DGPVideoViewController {
            mode = .video
            videoVC.start()
        }
    
        setupNav()
    }
}

struct textConstants {
    static let cancel = "Cancel"
    static let next = "Next"
    
    static let library = "Library"
    static let photo = "Photo"
    static let video = "Video"
    
    static let ok = "ok"
    
    static let titleDenied = "Permission denied"
    static let allowAccessLibrary = "Please allow access to the library"
    static let allowAccessCamera = "Please allow access to the camera"
    
    static let grantAccessLibrary = "Grant Permission"
    static let grantAccessCamera = "Grant Permission"
    
    static let albums = "Albums"
}
