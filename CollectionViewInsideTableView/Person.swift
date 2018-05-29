//
//  Person.swift
//  CollectionViewInsideTableView
//
//  Created by Madhuri kumari on 16/05/18.
//  Copyright © 2018 Yash Patel. All rights reserved.
//

import Foundation
class Person {
    
    var _id: Int
    var name: String?
    var info: String?
    var img: String?
    var cid: Int
    
    init(_id: Int, name: String?, info: String?, img: String?, cid: Int){
        self._id = _id
        self.name = name
        self.info = info
        self.img = img
        self.cid = cid
    }
}
