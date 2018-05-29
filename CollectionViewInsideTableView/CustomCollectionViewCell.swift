//
//  CustomCollectionViewCell.swift
//  CollectionViewInsideTableView
//
//  Created by Madhuri kumari on 11/05/18.
//  Copyright © 2018 Yash Patel. All rights reserved.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var labelHeading: UILabel!
    @IBOutlet weak var lblCell: UILabel!
    
    @IBOutlet weak var leaderImage: UIImageView!
    
    
// //TO MAKE ROUND IMAGE
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        self.leaderImage.layoutIfNeeded() // Add this line
//        
//        //self.leaderImage.layer.cornerRadius = frame.size.width/2
//        self.leaderImage.layer.cornerRadius = leaderImage.frame.width/2
//        //self.leaderImage.layer.cornerRadius = self.leaderImage.frame.height / 2
//        self.leaderImage.clipsToBounds = true
//        
//    }
    
    
}
