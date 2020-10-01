//
//  DGPAlbumView.swift
//  DGPImagePicker
//
//  Created by Daniel Gallego Peralta on 05/09/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import UIKit

class DGPAlbumView: UIView {

    let tableView : UITableView
    
    override init(frame: CGRect) {
        tableView = UITableView(frame: frame)
        super.init(frame: frame)
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        adjustToContainer(view: tableView, parentContainer: self)
    }
    

}
