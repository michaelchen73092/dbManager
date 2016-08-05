//
//  testBolt.swift
//  dbManager
//
//  Created by guest on 7/29/16.
//  Copyright © 2016 guest. All rights reserved.
//

import Foundation
import Bolts

class testBolts:NSObject {
   class func testPost(){
        var request = NSMutableURLRequest(URL: NSURL(string: "https://192.168.1.2:8443/hello/home")!)
        var configuration =
            NSURLSessionConfiguration.defaultSessionConfiguration()
        var session =  NSURLSession(configuration: configuration, delegate: DelegateCollect.instance, delegateQueue:NSOperationQueue.mainQueue())
        //var session = NSURLSession.sharedSession()
        request.HTTPMethod = "Post"
        var testjson = ["userName":["jackma","chien-lin"],"ID":3]
        guard let test = TestJson(json: testjson)
            else{
                print("wrong transform")
                return
        }
        do{
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(test.toJSON()!, options: NSJSONWritingOptions(rawValue: 0))
        }catch{
            print(error)
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        /*var task = session.dataTaskWithRequest(request,completionHandler:  { (data, response, error) in
            if(error == nil){
                print("Response: \(response)")
                var strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Body: \(strData)")
            }else{
                print("Error: \(error)")
            }
            
        })
        task.resume()*/
    var btask = fetch(session,request:request)
        //btask.waitUntilCompleted()
        print("test the code sequence",btask.result)
    
    }
    class func fetch(session:NSURLSession,request:NSMutableURLRequest) -> BFTask {
        let taskCompletionSource = BFTaskCompletionSource()

        var task = session.dataTaskWithRequest(request,completionHandler:  { (data, response, error) in
            if(error == nil){
                print("Response: \(response)")
                var strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Body: \(strData)")
                taskCompletionSource.setResult(strData!)

            }else{
                print("Error: \(error)")
                taskCompletionSource.setError(error!)
                
            }
            
        })
        task.resume()
        return taskCompletionSource.task
    }
}
