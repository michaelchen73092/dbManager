//
//  dbView.swift
//  dbManager
//
//  Created by guest on 6/17/16.
//  Copyright © 2016 guest. All rights reserved.
//

import UIKit
import AWSDynamoDB
//import PersonsKit

class dbView: UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.setupTable()
        //self.listTable()
        print("*****load successful")
        let tt1 = NSDate()
        print(tt1.description)
        let test1 = dynamoDBManger.timeFromDate(tt1)
        print("\(test1.hour):\(test1.min)")
        let testObj = NSDate.init(timeIntervalSinceNow: 20)
        print("testobj's time is \(testObj.description)")
        //let timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateCounter"), userInfo: nil, repeats: true)
        //let timer2 = NSTimer.init(fireDate: testObj,interval:1, target: self, selector: Selector("updateCounter"), userInfo: nil, repeats: true)
        //print("firstDate: \(timer2.fireDate.description)")
        //NSRunLoop.currentRunLoop().addTimer(timer2, forMode: NSRunLoopCommonModes)        //timer.s(fireDate: testObj,interval: 15.0,target: self,selector: Selector("updateCounter"),userInfo: nil,repeats: true)

        /*let doctor = dynamoDBManger.testWrite()
         print("\(doctor.valueForKey("email")!)")*/
        //print("\(doctor.valueForKey("graduate")!)")
        let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let tokenString =  (UIApplication.sharedApplication().delegate as! AppDelegate).token
        /*let test = NSEntityDescription.insertNewObjectForEntityForName("Test2", inManagedObjectContext: moc)
        test.setValue(queue_buff, forKey: "queue")
        test.setValue("zero064@gmail.com", forKey: "email")
        test.setValue("NTU", forKey: "graduate")
        test.setValue(20, forKey: "id")
        test.setValue("WeiChi", forKey: "name")
        print("\(test.valueForKey("email")!)")
        print("\(test.valueForKey("graduate")!)")
        print("\(test.valueForKey("queue")!)")*/

        var queue_buff = ["wei chi","a-yo","chien-lin","julian","hsiao-cho","lee"]
        var test_arry = [NSManagedObject]()
        var  obj_pari = ["zero064gmail.com":test_arry]
        /*for count in 1...31 {
            var time:Date = Date()
            while(time.get(Date.Day) != "02"){
                let test = NSEntityDescription.insertNewObjectForEntityForName("TimeSlot", inManagedObjectContext: moc)
                test.setValue(queue_buff, forKey: "queue")
                test.setValue(count, forKey: "day")
                test.setValue(time.get(Date.Hour_and_Min), forKey: "time")
                test.setValue(10, forKey: "open")
                test.setValue(6, forKey: "reservation")
                obj_pari["zero064gmail.com"]!.append(test)
                time.add(Date.Min, num: 30)
                //print("array count:",obj_pari["zero064gmail.com"]!.count)
                if(obj_pari["zero064gmail.com"]!.count==25){
                    //print("count==25")
                    //dynamoDBManger.dynamoDB.batchWriteItem(dynamoDBManger.transTowrite(obj_pari)).waitUntilFinished()
                    obj_pari["zero064gmail.com"] = [NSManagedObject]()
                }
            }
            if(obj_pari["zero064gmail.com"]!.count>0){
                //print("count>0:",obj_pari["zero064gmail.com"]!.count)
                //dynamoDBManger.dynamoDB.batchWriteItem(dynamoDBManger.transTowrite(obj_pari)).waitUntilFinished()
                obj_pari["zero064gmail.com"] = [NSManagedObject]()
            }
            //dynamoDBManger.dynamoDB.batchWriteItem(dynamoDBManger.transTowrite(obj_pari))


        }*/
        /*print(NSDate().description)
        dynamoDBManger.testQuery("Test2", keyVal: ["zero064@gmail.com",2],keyTyp: [NSAttributeType.StringAttributeType,NSAttributeType.Integer32AttributeType], op: Op.eq).continueWithBlock{(task: AWSTask!) -> AnyObject! in
            if task.error != nil {
                print("Can't fetch data")
                print("Error: \(task.error)")
                var tess = task.error!.description
                print("description:\(tess)")
            } else {
                // the object was saved successfully.
                var object = task.result as! AWSDynamoDBQueryOutput
                var dict = object.items![0]
                print("\(dict["queue"])")
            }
            print(NSDate().description)

            return nil
        }*/
        //let  obj_pari = ["Test2":test_arry]
        //dynamoDBManger.dynamoDB.batchWriteItem(dynamoDBManger.transTowrite(obj_pari))
        //dynamoDBManger.dynamoDB.batchWriteItem(dynamoDBManger.transTodelete(obj_pari))
        //dynamoDBManger.dynamoDB.batchWriteItem(dynamoDBManger.update)
        //assert(false, "test assertion")
        //print("\(test.entity.name!)")
        //let dict = ["fuck":"1","fuck2":"2"]
        //let arry = Array(test.entity.attributesByName.keys)
         //print(arry)
         /*let input = dynamoDBManger.transTowrite(["Test1":[test]])
         dynamoDBManger.dynamoDB.batchWriteItem(input)*/
        /*if let t4 = t3 as?  {
         printf("\(t4)")
         }*/
        print("Function: \(#function), line: \(#line)")
        /*var dict: [String:String]? = [String:String]();
        var dict2: [Int:String] = [Int:String]();
        dynamoDBManger.testDict(&dict)
        print(dict)
        var dictName:[String:String]? = [String:String]()
        var dictValue:[String:AWSDynamoDBAttributeValue]? = [String:AWSDynamoDBAttributeValue]()
        print(dynamoDBManger.operationBi("name", op: Op.append, right: test.valueForKey("name")!, type: NSAttributeType.StringAttributeType,dictName:&dictName , dictValue: &dictValue ))
        print(dynamoDBManger.operationBi("graduate", op: Op.not_exit, right: test.valueForKey("graduate")!, type: NSAttributeType.StringAttributeType,dictName:&dictName , dictValue: &dictValue ))
        print(dictName)
        print(dictValue)
        print(dynamoDBManger.conCat(" ",strs: "test1","test2","test3","test4",Op.eq.rawValue))*/
        //print("token:",tokenString)
    }
    func updateCounter(){
        let t = NSDate()
        print("\(t.description)")
    }
    func deleteTable(){
        let tabInput = AWSDynamoDBListTablesInput()
        dynamoDBManger.dynamoDB.listTables(tabInput).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask) -> AnyObject? in
            let tabNames = task.result as? AWSDynamoDBListTablesOutput
            if let tabNames_t = tabNames{
                print("\(tabNames_t.tableNames!.count) tables")
                for tabName in tabNames_t.tableNames!{
                    print(tabName)
                }
            }else{
                if(tabNames == nil){
                    print("tabNames is nil")
                    return nil
                }
            }
            return nil
        })
    }
    func listTable(){
        let tabInput = AWSDynamoDBListTablesInput()
        dynamoDBManger.dynamoDB.listTables(tabInput).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask) -> AnyObject? in
            let tabNames = task.result as? AWSDynamoDBListTablesOutput
            if let tabNames_t = tabNames{
                print("\(tabNames_t.tableNames!.count) tables")
                for tabName in tabNames_t.tableNames!{
                    print(tabName)
                }
            }else{
                if(tabNames == nil){
                    print("tabNames is nil")
                    return nil
                }
            }
            return nil
        })
    }
    func setupTable() {
        //See if the test table exists.
        let tableName = "Test2"
        dynamoDBManger.describeTable(tableName).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
            
            // If the test table doesn't exist, create one.
            if (task.error != nil && task.error!.domain == AWSDynamoDBErrorDomain)
                && (task.error!.code == AWSDynamoDBErrorType.ResourceNotFound.rawValue) {
                
                self.performSegueWithIdentifier("DDBLoadingViewSegue", sender: self)
                var key = [AWSDynamoDBAttributeDefinition]()
                key.append(AWSDynamoDBAttributeDefinition())
                key.append(AWSDynamoDBAttributeDefinition())
                key[0].attributeName = "email"
                key[0].attributeType = AWSDynamoDBScalarAttributeType.S
                key[1].attributeName = "id"
                key[1].attributeType = AWSDynamoDBScalarAttributeType.N
                
                return dynamoDBManger.createTable(tableName,key: key,tableType: false,readCap: 5,writeCap: 5).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
                    //Handle erros.
                    if ((task.error) != nil) {
                        print("Error: \(task.error)")
                        
                        let alertController = UIAlertController(title: "Failed to setup a test table.", message: task.error!.description, preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
                        })
                        alertController.addAction(okAction)
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                    } else {
                        self.dismissViewControllerAnimated(false, completion: nil)
                    }
                    return nil
                    
                })
            } else {
                //load table contents
                //self.refreshList(true)
                print("table already exit")
            }
            
            return nil
        })
    }
    
    
}
