//
//  ItemV2.swift
//  dbManager
//
//  Created by guest on 9/4/16.
//  Copyright © 2016 guest. All rights reserved.
//

import Foundation
import CoreData

class ItemV2:NSObject{
    var dict:[String:AnyObject]
    init(object:NSManagedObject){
        dict = [String:AnyObject]()
        super.init()
        var keys_dict = object.entity.attributesByName
        for (key,description) in keys_dict {
            var anyobject:AnyObject? = object.valueForKey(key)
            if(anyobject != nil){
                dict[key] = transForm(anyobject!)
            }
        }
    }
    init(dictObject:[String:AnyObject]){
        dict = [String:AnyObject]()
        super.init()
        for (key,buffer) in dictObject {
            dict[key] = transForm(buffer)
        }
    }
    func transForm(object:AnyObject)->[AnyObject]{
        var arry:[AnyObject] = [AnyObject]()
        if let str = object as? String{
            arry.append("String")
            arry.append(str)
        }else if let num = object as? NSNumber{
            arry.append("Number")
            arry.append(num)
        }else if let flag = object as? Bool{
            arry.append("Boolean")
            arry.append(flag)
        }else if var arry = object as? [AnyObject]{
            arry.append("List")
            for element in arry{
                arry.append(transForm(element))
            }
        }else if let str_set = object as? Set<String>{
            arry.append("StringSet")
            arry.append([String](str_set))
        }else if let num_set = object as? Set<NSNumber>{
            arry.append("NumberSet")
            arry.append([NSNumber](num_set))
        }else if var dict = object as? [String:AnyObject]{
            arry.append("Map")
            for (key,buffer) in dict{
                dict[key] = transForm(buffer)
            }
        }else{
            print("Error!!'")
        }
        return arry
    }
}