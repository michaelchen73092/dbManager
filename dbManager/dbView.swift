//
//  dbView.swift
//  dbManager
//
//  Created by guest on 6/17/16.
//  Copyright © 2016 guest. All rights reserved.
//

import UIKit
import AWSDynamoDB

class dbView: UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.setupTable()
        print("*****load successful")
        
        /*let doctor = dynamoDBManger.testWrite()
        print("\(doctor.valueForKey("email")!)")*/
        //print("\(doctor.valueForKey("graduate")!)")
        let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let test = NSEntityDescription.insertNewObjectForEntityForName("Test1", inManagedObjectContext: moc)
        test.setValue("zero064@gmail.com", forKey: "email")
        test.setValue("NTU", forKey: "graduate")
        test.setValue(20, forKey: "id")
        test.setValue("WeiChi", forKey: "name")
        print("\(test.valueForKey("email")!)")
        print("\(test.valueForKey("graduate")!)")
        print("\(test.entity.name!)")
        //let dict = ["fuck":"1","fuck2":"2"]
        /*let arry = Array(test.entity.attributesByName.keys)
        print(arry)
        let input = dynamoDBManger.transTowrite(["Test1":[test]])
        dynamoDBManger.dynamoDB.batchWriteItem(input)*/
        /*if let t4 = t3 as?  {
            printf("\(t4)")
        }*/
        print("Function: \(#function), line: \(#line)")
        var dict: [String:String]? = [String:String]();
        var dict2: [Int:String] = [Int:String]();
        dynamoDBManger.testDict(&dict)
        print(dict)
        var dictName:[String:String]? = [String:String]()
        var dictValue:[String:AWSDynamoDBAttributeValue]? = [String:AWSDynamoDBAttributeValue]()
        print(dynamoDBManger.operationBi("name", op: Op., right: test.valueForKey("name")!, type: NSAttributeType.StringAttributeType,dictName:&dictName , dictValue: &dictValue ))
        print(dynamoDBManger.operationBi("graduate", op: Op.ls, right: test.valueForKey("graduate")!, type: NSAttributeType.StringAttributeType,dictName:&dictName , dictValue: &dictValue ))
        print(dictName)
        print(dictValue)
        
    }
    func setupTable() {
        //See if the test table exists.
        let tableName = "Test1"
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

                return dynamoDBManger.createTable(tableName,key: key,tableType: false,readCap: 50,writeCap: 50).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
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
            }
            
            return nil
        })
    }
    

}
