//
//  dynamoDBManager.swift
//  dbManager
//
//  Created by guest on 6/14/16.
//  Copyright © 2016 guest. All rights reserved.
//

import Foundation
import AWSDynamoDB
import CoreData

let AWSSampleDynamoDBTableName = "DynamoDB-OM-SwiftSample"
enum Op:String{
    case eq = "="
    case le = "<="
    case ls = "<"
    case ge = ">="
    case gt = ">"
    case ne = "<>"
}
class dynamoDBManger : NSObject {
    static let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    static let dynamoDB = AWSDynamoDB.defaultDynamoDB()
    static let dynamoDBObjectMapper=AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
    
    class func testWrite()->NSManagedObject{
        let doctor = NSEntityDescription.insertNewObjectForEntityForName("Doctors", inManagedObjectContext: self.moc) as! Doctors
        doctor.setValue("zero064@gmail.com", forKey: "email")
        //doctor.setValue("NTU", forKey: "graduate")
        return doctor
    }
    class func update(){
        
    }
    class func testDict(inout dict:[String:String]?){
        dict!["1"] = "test1"
        dict!["2"] = "test2"
    }
    class func operationBi(left:String,op:Op,right:AnyObject,type:NSAttributeType,inout dictName:[String : String]?,inout dictValue:[String : AWSDynamoDBAttributeValue]?)->String{
        //create string for binary operator, add new map to dictName and dictValue
        if(dictValue==nil || dictName==nil){
            print("Function: \(#function), line: \(#line)")
            return ""
        }
        let attrValue = AWSDynamoDBAttributeValue()
        toAttrValue(attrValue, type: type, object: right)
        let l_name = "#"+left
        var temp_str:String = ":"
        var ind:String = ""
        switch(type){
            case .Integer32AttributeType: ind = "I"
            case .DoubleAttributeType: ind = "D"
            case .StringAttributeType: ind = "S"
            case .BooleanAttributeType: ind = "B"
            case .TransformableAttributeType: ind = "T"
            default: print("Function: \(#function), line: \(#line)\ntypeError in batchwrite")
        }
        temp_str += ind
        while(dictValue!.keys.contains(temp_str)){
            temp_str += ind
        }
        dictValue![temp_str] = attrValue
        dictName![l_name] = left
        return l_name+" "+op.rawValue+" "+temp_str
        
    }
    class func query(){
        
    }
    class func toAttrValue(attrValue:AWSDynamoDBAttributeValue,type:NSAttributeType,object:AnyObject){
        //tranform object to AWSDynamoDBAttributeValue
        switch(type){
        case .Integer32AttributeType: attrValue.N = String(object as! Int)
        case .DoubleAttributeType: attrValue.N = String(object as! Double)
        case .StringAttributeType: attrValue.S = object as! String
        case .BooleanAttributeType: attrValue.BOOLEAN = object as! Bool ? 1:0
        case .TransformableAttributeType: attrValue.SS = object as! [String]
        default: print("Function: \(#function), line: \(#line)\ntypeError in batchwrite")
        }
        return
    }
    class func transTowrite(objects:[String:[NSManagedObject]])->AWSDynamoDBBatchWriteItemInput{
        let keys = Array(objects.keys)
        let returnObject = AWSDynamoDBBatchWriteItemInput()
        returnObject.requestItems = [String : [AWSDynamoDBWriteRequest]]()
        //each key indicate a entity name
        for key in keys{
            let buff = objects[key]
            var writes = [AWSDynamoDBWriteRequest]()
            if let buff2 = buff{
                //each object indicate a NSManagedObject
                for object in buff2 {
                    var dict = object.entity.attributesByName
                    let attNames = Array(dict.keys)
                    let wbuff = AWSDynamoDBWriteRequest()
                    wbuff.putRequest = AWSDynamoDBPutRequest()
                    wbuff.putRequest!.item = [String:AWSDynamoDBAttributeValue]()
                    //tranform attribute value from NSManagedObject to attribute value in dynamoDB
                    for attName in attNames{
                        let attribValue = AWSDynamoDBAttributeValue()
                        toAttrValue(attribValue, type: dict[attName]!.attributeType, object: object.valueForKey(attName)!)
                        wbuff.putRequest?.item![attName] = attribValue
                    }
                    writes.append(wbuff)
                }
            }else{
                print("error! buff is nil")
            }
                returnObject.requestItems![key] = writes
        }
        return returnObject
    }
    class func describeTable(tableName:String) -> AWSTask {
        // See if the test table exists.
        let describeTableInput = AWSDynamoDBDescribeTableInput()
        describeTableInput.tableName = tableName
        return dynamoDB.describeTable(describeTableInput)
    }
    class func save(models: [AWSDynamoDBObjectModel])-> AWSTask{
        var tasks = [AWSTask]()
        for model in models{
            tasks.append(dynamoDBObjectMapper.save(model))
        }
        return AWSTask(forCompletionOfAllTasks: tasks)
        
        
    }

    class func createTable(tableName:String,key:[AWSDynamoDBAttributeDefinition],tableType:Bool,readCap:Int,writeCap:Int) -> AWSTask {
        //Create the table
        //tableType: true: simple primary key, false: composite primary key
        //key: the array contains all key attributes
        //readCap: the provisioned read capacity unit
        //writeCap: the provisioned write capacity unit
        let hashKeyAttributeDefinition = key[0]
        
        let hashKeySchemaElement = AWSDynamoDBKeySchemaElement()
        hashKeySchemaElement.attributeName = key[0].attributeName
        hashKeySchemaElement.keyType = AWSDynamoDBKeyType.Hash
        
        let rangeKeyAttributeDefinition:AWSDynamoDBAttributeDefinition? = tableType ? nil:key[1]
        let rangeKeySchemaElement = AWSDynamoDBKeySchemaElement()
        if(!tableType){
            rangeKeySchemaElement!.attributeName = key[1].attributeName
            rangeKeySchemaElement!.keyType = AWSDynamoDBKeyType.Range
            
        }
        
        let provisionedThroughput = AWSDynamoDBProvisionedThroughput()
        provisionedThroughput.readCapacityUnits = readCap
        provisionedThroughput.writeCapacityUnits = writeCap
        
        //Create TableInput
        let createTableInput = AWSDynamoDBCreateTableInput()
        createTableInput.tableName = tableName;
        createTableInput.attributeDefinitions = tableType ?[hashKeyAttributeDefinition]:[hashKeyAttributeDefinition, rangeKeyAttributeDefinition!]
        createTableInput.keySchema = tableType ? [hashKeySchemaElement]:[hashKeySchemaElement, rangeKeySchemaElement]
        createTableInput.provisionedThroughput = provisionedThroughput
        
        return dynamoDB.createTable(createTableInput).continueWithSuccessBlock({ task -> AnyObject? in
            var localTask = task
            
            if ((localTask.result) != nil) {
                // Wait for up to 4 minutes until the table becomes ACTIVE.
                
                let describeTableInput = AWSDynamoDBDescribeTableInput()
                describeTableInput.tableName = tableName;
                localTask = dynamoDB.describeTable(describeTableInput)
                
                for _ in 0...15 {
                    localTask = localTask.continueWithSuccessBlock({ task -> AnyObject? in
                        let describeTableOutput:AWSDynamoDBDescribeTableOutput = task.result as! AWSDynamoDBDescribeTableOutput
                        let tableStatus = describeTableOutput.table!.tableStatus
                        if tableStatus == AWSDynamoDBTableStatus.Active {
                            return task
                        }
                        
                        sleep(15)
                        return dynamoDB .describeTable(describeTableInput)
                    })
                }
            }
            
            return localTask
        })
        
    }
}

