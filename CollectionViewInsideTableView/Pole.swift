//
//  Pole.swift
//  CollectionViewInsideTableView
//
//  Created by Madhuri kumari on 16/05/18.
//  Copyright © 2018 Yash Patel. All rights reserved.
//

import Foundation
class Pole {
    var _id: Int
    var title: String?
    var des: String?
    var img: String?
    var info: String?
    var cid: Int
    
    
    init(_id: Int, title: String?, des: String? , img: String?, info: String?, cid: Int){
        self._id = _id
        self.title = title
        self.des = des
        self.img = img
        self.info = info
        self.cid = cid
        
    }
}
