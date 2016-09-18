//
//  ItemV2.swift
//  dbManager
// This item is used as bridge for AWSDynamodbAttributeValue and JSON object

import Foundation
import CoreData
import AWSDynamoDB
class ItemV2:NSObject{
    var dict:[String:AnyObject]
    init(object:NSManagedObject){
        dict = [String:AnyObject]()
        super.init()
        var keys_dict = object.entity.attributesByName
        for (key,description) in keys_dict {
            var anyobject:AnyObject? = object.valueForKey(key)
            if(anyobject != nil){
                var buffer = transForm(anyobject!)
                if(buffer != nil){
                    dict[key] = buffer!
                }
            }
        }
    }
    init(dictionary:[String:AWSDynamoDBAttributeValue]){
        dict = [String:AnyObject]()
        super.init()
        for (key,attr) in dictionary{
            dict[key] = Parse(attr)
        }
    }
    init(dictObject:[String:AnyObject]){
        dict = [String:AnyObject]()
        super.init()
        for (key,buffer) in dictObject {
            dict[key] = transForm(buffer)
        }
    }
    override init(){
        dict = [String:AnyObject]()
        super.init()
    }
    //Parse the object to prefix with suitable string
    func transForm(object:AnyObject)->[AnyObject]?{
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
        }else if var list_buff = object as? [AnyObject]{
            arry.append("List")
            var new_list = [[AnyObject]]()
            for element in list_buff{
                var buffer = transForm(element)
                if(buffer != nil){
                    new_list.append(buffer!)
                }
            }
            arry.append(new_list)
        }else if let str_set = object as? Set<String>{
            arry.append("StringSet")
            arry.append([String](str_set))
        }else if let num_set = object as? Set<NSNumber>{
            arry.append("NumberSet")
            arry.append([NSNumber](num_set))
        }else if var dict = object as? [String:AnyObject]{
            arry.append("Map")
            arry.append(ItemV2(dictObject: dict))
        }else if var itemv2 = object as? ItemV2{
            arry.append("Map")
            arry.append(itemv2)
        }else{
            print("Error!!'")
            return nil
        }
        return arry
    }
    func put(key:String,object:AnyObject){
        dict[key] = transForm(object)
    }
    func get(key:String)->AnyObject?{
        var object = dict[key]
        if let arry = object as? [AnyObject]{
            return arry[1]
        }else{
            return nil
        }
    }
    //Convert the dict to AttributeValue Map
    func toAttirbuteValue()->[String:AWSDynamoDBAttributeValue]{
        var returned_dict:[String:AWSDynamoDBAttributeValue] = [String:AWSDynamoDBAttributeValue]()
        for (key,object) in dict{
            returned_dict[key] = toAttributeValue(object as! [AnyObject])
        }
        return returned_dict
    }
    //convert AWSDynamoDBAttributeValue to array
    func Parse(attr:AWSDynamoDBAttributeValue)->[AnyObject]{
        var string = attr.S
        var bool = attr.BOOLEAN
        var list = attr.L
        var map = attr.M
        var string_set = attr.SS
        var number_set = attr.NS
        var number = attr.N
        var arry = [AnyObject]()
        if(string != nil){
            arry.append("String")
            arry.append(string!)
        }else if(bool != nil){
            var boolean = bool!.boolValue
            arry.append("Boolean")
            arry.append(boolean)
        }else if(list != nil){
            var new_list = [[AnyObject]]()
            for attr in list!{
                new_list.append(Parse(attr))
            }
            arry.append("List")
            arry.append(new_list)
        }else if(map != nil){
            arry.append("Map")
            arry.append(ItemV2(dictionary:map!))
        }else if(string_set != nil){
            arry.append("StringSet")
            arry.append(string_set!)
        }else if(number_set != nil){
            var new_number_set = [NSNumber]()
            for num in number_set!{
                new_number_set.append(NSDecimalNumber(string: num))
            }
            arry.append("NumberSet")
            arry.append(new_number_set)
        }else if(number != nil){
            arry.append("Number")
            arry.append(NSDecimalNumber(string:number!))
        }
        return arry
    }
    //convert the jsonArray to attributeValue
    func toAttributeValue(arry:[AnyObject])->AWSDynamoDBAttributeValue?{
        var attrValue:AWSDynamoDBAttributeValue = AWSDynamoDBAttributeValue()
        var length = arry.count
        if let str = arry[0] as? String{
            switch(str){
                case "String": attrValue.S = arry[1] as! String
                case "Number": attrValue.N = (arry[1] as! NSNumber).stringValue
                case "Boolean": var bool:NSNumber = NSNumber(bool: arry[1] as! Bool)
                attrValue.BOOLEAN = bool
                case "List":
                    var new_arry:[AWSDynamoDBAttributeValue] = [AWSDynamoDBAttributeValue]()
                    for(var i = 1;i<length;i++){
                        new_arry.append(toAttributeValue(arry[i] as! [AnyObject])!)
                    }
                    attrValue.L = new_arry
            case "Map":
                var dict_buff = arry[1] as! [String:AnyObject]
                var map:[String:AWSDynamoDBAttributeValue] = [String:AWSDynamoDBAttributeValue]()
                for (key,object) in dict_buff{
                    map[key] = toAttributeValue(object as! [AnyObject])!
                }
                attrValue.M = map
            case "StringSet": attrValue.SS = arry[1] as! [String]
            case "NumberSet":
                var ns_set:[NSNumber] = arry[1] as! [NSNumber]
                var returned_ns_set:[String] = [String]()
                for ns in ns_set{
                    returned_ns_set.append(ns.stringValue)
                }
                attrValue.NS = returned_ns_set
            default: return nil
            }
            return attrValue
        }else{
            return nil
        }
    }
}