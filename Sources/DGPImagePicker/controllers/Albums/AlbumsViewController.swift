//
//  AlbumsViewController.swift
//  SocialGaming
//
//  Created by Daniel Gallego Peralta on 05/09/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import UIKit

class AlbumsViewController: UIViewController {

    var customView : DGPAlbumView!
    var albumManager : DGPAlbumManager
    var albums : [DGPAlbum]
    
    var didSelectAlbum : ((DGPAlbum) -> Void)?
    
    //MARK: - Life cicle
    
    required init(manager: DGPAlbumManager) {
        albumManager = manager
        albums = []
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        super.loadView()
        customView = DGPAlbumView(frame: view.frame)
        view = customView
        
        setup()
        setupTableView()
        fetchAlbums()
    }
    
    //MARK: - Setup
    
    func setup() {
        title = textConstants.albums
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: textConstants.cancel,
        style: .plain,
        target: self,
        action: #selector(closeAction))
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: DGPConfig.shared.tintColor]
    }
    
    func setupTableView() {
        customView.tableView.register(AlbumViewCell.self, forCellReuseIdentifier: AlbumViewCell.getIdentifier())
        customView.tableView.dataSource = self
        customView.tableView.delegate = self
        
    }
    
    func fetchAlbums() {
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.albums = self?.albumManager.fetchAlbums() ?? []
            
            DispatchQueue.main.async {
                self?.customView.tableView.reloadData()
            }
        }
    }
    
    //MARK: - Actions
    
    @objc func closeAction() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

}

extension AlbumsViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = customView.tableView.dequeueReusableCell(withIdentifier: AlbumViewCell.getIdentifier()) as? AlbumViewCell else {
            return UITableViewCell()
        }
        
        let album = albums[indexPath.row]
        cell.labelTitle.text = album.title
        cell.imageAlbum.image = album.thumb
        cell.labelNumber.text = String(album.numberOfItems)
        return cell
        
    }
    
    
}

extension AlbumsViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let collection = albums[indexPath.row]
        didSelectAlbum?(collection)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
