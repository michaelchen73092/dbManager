//
//  Date.swift
//  dbManager
//
//  Created by guest on 7/17/16.
//  Copyright © 2016 guest. All rights reserved.
//

import Foundation

class Date:NSObject{
    private var month:Int
    private var year:Int
    private var day:Int
    private var hour:Int
    private var min:Int
    static let Month = 0
    static let Day = 1
    static let Hour = 2
    static let Min = 3
    static let Year = 4
    static let Hour_and_Min = 5
    override init() {
        self.day = 1;
        self.hour = 0
        self.min = 0
        var formatter = NSDateFormatter();
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        var date:NSDate = NSDate()
        let date_str = formatter.stringFromDate(date)
        var yRange:Range<String.Index> = Range<String.Index>(start:date_str.startIndex,end:date_str.startIndex.advancedBy(4))
        var mRange:Range<String.Index> = Range<String.Index>(start:date_str.startIndex.advancedBy(5),end:date_str.startIndex.advancedBy(7))
        self.month = Int.init(date_str.substringWithRange(mRange))!
        self.year = Int.init(date_str.substringWithRange(yRange))!
    }
    func overflow(){
        if(min >= 60){
            min = min-60
            hour = hour+1
        }
        if(hour >= 24){
            hour = hour-24
            day = day+1
        }
        
        
    }
    func add(type:Int,num:Int){
        switch type{
        case 0 : month = month+num
                if(month>12) {
                    month = month-12
                    year = year+1
            }
        case 1 : day = day+num
        case 2 : hour = hour + num
                overflow()
        case 3 : min = min+num
                overflow()
        default :
            print("eroor modifier")
        }
    }
    func getNum(type:Int)->Int{
        var value:Int = 0
        switch type{
        case 0 : value = month
        case 1 : value = day
        case 2 : value = hour
        case 3 : value = min
        case 4 : value = year
        default :
            print("eroor modifier")
        }
        return value
    }
    func get(type:Int)->String{
        var return_var:String = ""
        if(type<5){
            var value:Int = 0
            switch type{
                case 0 : value = month
                case 1 : value = day
                case 2 : value = hour
                case 3 : value = min
                case 4 : value = year
                default :
                print("eroor modifier")
            }
            return_var = String(value)
            if(value<10){
                return_var = "0"+return_var
            }
            return return_var
        }else{
            switch type {
            case 5 :
                var hs = String(hour)
                var ms = String(min)
                if(hour<10){ hs = "0"+hs }
                if(min<10){ ms = "0"+ms }
                return_var = hs+":"+ms
            default: print("not support yet!")
            }
            return return_var
        }
    }
}