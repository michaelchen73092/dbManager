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
    case not_exit = "if_not_exists"
    case append = "list_append"
}
enum UpdateOp:String{
    case SET = "SET"
    case REMOVE = "REMOVE"
    case ADD = "ADD"
    case DELETE = "DELETE"
}
enum LogicOp:String{
    case AND = "AND"
    case OR = "OR"
}
class dynamoDBManger : NSObject {
    static let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    static let dynamoDB = AWSDynamoDB.defaultDynamoDB()
    static let dynamoDBObjectMapper=AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
    
    /*class func testWrite()->NSManagedObject{
        let doctor = NSEntityDescription.insertNewObjectForEntityForName("Doctors", inManagedObjectContext: self.moc) as! Doctors
        doctor.setValue("zero064@gmail.com", forKey: "email")
        //doctor.setValue("NTU", forKey: "graduate")
        return doctor
    }*/
    //assemble all the required information into a AWSDynamoDBUpdateItemInput object
    class func update(tabName:String,upExp:String,condExp:String,inout dictName:[String : String],inout dictValue:[String : AWSDynamoDBAttributeValue])->AWSDynamoDBUpdateItemInput{
        let return_obj = AWSDynamoDBUpdateItemInput()
        return_obj.conditionExpression = condExp
        return_obj.tableName = tabName
        return_obj.updateExpression = upExp
        return_obj.expressionAttributeNames = dictName
        return_obj.expressionAttributeValues = dictValue
        return return_obj
        
    }
    class func query(tabName:String,keyExp:String,inout dictName:[String : String],inout dictValue:[String : AWSDynamoDBAttributeValue])->AWSDynamoDBQueryInput {
        let return_obj = AWSDynamoDBQueryInput()
        return_obj.consistentRead = 1
        return_obj.keyConditionExpression = keyExp
        return_obj.expressionAttributeNames = dictName
        return_obj.expressionAttributeValues = dictValue
        return return_obj
    }
    class func testDict(inout dict:[String:String]?){
        dict!["1"] = "test1"
        dict!["2"] = "test2"
    }
    //concatenate multiple string with specified delimiter
    class func conCat(delit:String,strs:String... )->String{
        var count:Int = 0
        var return_str = ""
        for str in strs{
            if(count==0){
                return_str += str
            }else{
                return_str +=   delit+str
            }
            count = count+1
        }
        return return_str
    }
    class func updateOpExp(op:String,exp:String)->String{
        return op+" "+exp
    }
    //create string for binary operator, add new map to dictName and dictValue
    class func operationBi(left:String,op:Op?,right:AnyObject,type:NSAttributeType,inout dictName:[String : String]?,inout dictValue:[String : AWSDynamoDBAttributeValue]?)->String{
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
        var return_str = ""
        if(op==nil){
            return_str = l_name+" "+temp_str
        }
        else if(op!==Op.append || op!==Op.not_exit){
            return_str = op!.rawValue+"("+l_name+", "+temp_str+")"
        }else{
            return_str = l_name+" "+op!.rawValue+" "+temp_str
        }
        return return_str
        
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
    class func transTodelete(objects:[String:[NSManagedObject]])->AWSDynamoDBBatchWriteItemInput{
        let keys = Array(objects.keys)
        let returnObject = AWSDynamoDBBatchWriteItemInput()
        returnObject.requestItems = [String : [AWSDynamoDBWriteRequest]]()
        //each key indicate a entity name
        for key in keys{
            let buff = objects[key]
            var writes = [AWSDynamoDBWriteRequest]()
            let key_set:[String]? = Constans.hashDict[key]
            var hashkey_name:String?
            var sortkey_name:String?
            assert(key_set != nil,"Function: \(#function), line: \(#line)\n undefined identity:\(key)")
            hashkey_name = key_set![0]
            if(key_set!.count==2){
                sortkey_name = key_set![1]
            }
            if let buff2 = buff{
                //each object indicate a NSManagedObject
                for object in buff2 {
                    var dict = object.entity.attributesByName
                    let attNames = Array(dict.keys)
                    let wbuff = AWSDynamoDBWriteRequest()
                    wbuff.deleteRequest = AWSDynamoDBDeleteRequest()
                    //wbuff.deleteRequest!.key[]
      
                    writes.append(wbuff)
                }
            }else{
                print("error! buff is nil")
            }
            returnObject.requestItems![key] = writes
        }
        return returnObject
        
    }
    //create AWSDynamoDBBatchWriteItemIput from objects
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

