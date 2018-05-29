//
//  IconCustomCollectionViewCell.swift
//  CollectionViewInsideTableView
//
//  Created by Madhuri kumari on 18/05/18.
//  Copyright © 2018 Yash Patel. All rights reserved.
//

import UIKit

class IconCustomCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var iimageCell: UIImageView!
    
    
    //TO MAKE ROUND IMAGE
        override func layoutSubviews() {
            super.layoutSubviews()
            self.iimageCell.layoutIfNeeded() // Add this line
    
            //self.leaderImage.layer.cornerRadius = frame.size.width/2
            self.iimageCell.layer.cornerRadius = iimageCell.frame.width/2
            //self.leaderImage.layer.cornerRadius = self.leaderImage.frame.height / 2
            self.iimageCell.clipsToBounds = true
    
        }
    
    
}
