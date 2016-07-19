//
//  Constants.swift
//  dbManager
//
//  Created by guest on 6/28/16.
//  Copyright © 2016 guest. All rights reserved.
//

import Foundation
class Constans{
    class func hashDict(key:String)->[String]?{
        let dict:[String:[String]] = ["Doctors":["firstname","email"],"Persons":["firstname","email"],"Test2":["email","id"]]
        if(dict.keys.contains(key)){
            return dict[key]
        }
        return ["day","time"]
    }
}