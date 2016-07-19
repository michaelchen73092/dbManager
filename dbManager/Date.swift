//
//  Date.swift
//  dbManager
//
//  Created by guest on 7/17/16.
//  Copyright © 2016 guest. All rights reserved.
//

import Foundation

class Date:NSObject{
    private var month:Int32
    private var day:Int32
    private var hour:Int32
    private var min:Int32
    static let Month = 0
    static let Day = 1
    static let Hour = 2
    static let Min = 3
    static let Hour_and_Min = 4
    override init() {
        self.month = 0
        self.day = 1;
        self.hour = 0
        self.min = 0
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
    func add(type:Int,num:Int32){
        switch type{
        case 0 : month = month+num
                if(month>12) {
                    month = month-12
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
    func get(type:Int)->String{
        var return_var:String = ""
        if(type<4){
            var value:Int32 = 0
            switch type{
                case 0 : value = month
                case 1 : value = day
                case 2 : value = hour
                case 3 : value = min
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
            case 4 :
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