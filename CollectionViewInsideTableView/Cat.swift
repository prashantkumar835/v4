//
//  Cat.swift
//  CollectionViewInsideTableView
//
//  Created by Madhuri kumari on 14/05/18.
//  Copyright © 2018 Yash Patel. All rights reserved.
//

import Foundation
class Cat {
    
    var _id: Int
    var name: String?
    var img: String?
    var pid: Int
    
    init(_id: Int, name: String?, img: String?, pid: Int){
        self._id = _id
        self.name = name
        self.img = img
        self.pid = pid
    }
}
