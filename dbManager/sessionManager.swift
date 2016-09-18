//
//  sessionManager.swift
//  dbManager
//
//  Created by guest on 9/13/16.
//  Copyright © 2016 guest. All rights reserved.
//

import Foundation
class sessionManager{
    static let instance = sessionManager()
    var sharedsession:NSURLSession
    init(){
        var configuration =
            NSURLSessionConfiguration.defaultSessionConfiguration()
        self.sharedsession =  NSURLSession(configuration: configuration, delegate: DelegateCollect.instance, delegateQueue:NSOperationQueue.mainQueue())    }
    
    
}