//
//  CustomTableViewCell.swift
//  CollectionViewInsideTableView
//
//  Created by Yash Patel on 08/04/18.
//  Copyright © 2018 Yash Patel. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    func setCollectionViewdelegate<D: UICollectionViewDelegate & UICollectionViewDataSource> (delegate: D, forRow row: Int) {
        collectionView.delegate = delegate
        collectionView.dataSource = delegate
        collectionView.tag = row
        collectionView.reloadData()
    }

}
