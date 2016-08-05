//
//  DelegateCollect.swift
//  dbManager
//
//  Created by guest on 7/25/16.
//  Copyright © 2016 guest. All rights reserved.
//

import Foundation

class DelegateCollect: NSObject,NSURLSessionDelegate {
    static let instance:DelegateCollect = DelegateCollect()
    // Mark: NSURLSession Delegate

    func URLSession(session: NSURLSession,didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition,NSURLCredential?) -> Void){
        
        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!))
    }

}