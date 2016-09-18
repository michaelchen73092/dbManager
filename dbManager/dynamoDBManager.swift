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
import Bolts


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
    class func updateItem(tabName:String,key:[String:AWSDynamoDBAttributeValue],upExp:String,condExp:String,inout dictName:[String : String],inout dictValue:[String : AWSDynamoDBAttributeValue])->AWSDynamoDBUpdateItemInput{
        let return_obj = AWSDynamoDBUpdateItemInput()
        return_obj.conditionExpression = condExp
        return_obj.tableName = tabName
        return_obj.key = key
        return_obj.updateExpression = upExp
        return_obj.expressionAttributeNames = dictName
        return_obj.expressionAttributeValues = dictValue
        return return_obj
        
    }
    //updateItem
    class func Update(request:AWSDynamoDBUpdateItemInput)->BFTask{
        var taskcompletion = BFTaskCompletionSource()
        dynamoDB.updateItem(request).continueWithBlock({(task:AWSTask)->AnyObject? in
            if(task.error != nil){
                taskcompletion.setError(task.error!)
            }else{
                taskcompletion.setResult(task.result)
            }
            return nil
        })
        return taskcompletion.task
    }
    class func timeFromDate(date:NSDate)->(hour:Int32,min:Int32){
        let index = date.description.startIndex.advancedBy(11) //swift 2.0+
        let index2 = date.description.startIndex.advancedBy(13)
        let index3 = date.description.startIndex.advancedBy(14) //swift 2.0+
        let index4 = date.description.startIndex.advancedBy(16)
        var range1 = Range<String.Index>(start: index,end: index2)
        var range2 = Range<String.Index>(start: index3,end: index4)
        var s3 = Int32(date.description.substringWithRange(range1))
        var s4 = Int32(date.description.substringWithRange(range2))
        return (s3!,s4!)
    }
    //Scan the table
    //BFTask<[ItemV2]>
    class func Scan(tabName:String)->BFTask{
        var request = AWSDynamoDBScanInput()
        request.tableName = tabName
        request.consistentRead = NSNumber(bool:true)
        var scan_task = dynamoDB.scan(request)
        var taskcompletion = BFTaskCompletionSource()
        scan_task.continueWithBlock({(task:AWSTask!)->AnyObject? in
            if(task.error != nil){
                taskcompletion.setError(task.error!)
            }else{
               var output = task.result as! AWSDynamoDBScanOutput
                var new_arry = [ItemV2]()
                for item in output.items!{
                    new_arry.append(ItemV2(dictionary: item))
                }
                taskcompletion.setResult(new_arry)
            }
            return nil
        })
        return taskcompletion.task
    }
    //BFTask<[ItemV2]>
    class func Query(tabName:String,keyVal:[AnyObject],keyTyp:[String],op:Op?)->BFTask{
        var dictName:[String : String]? = [String : String]()
        var dictValue:[String : AWSDynamoDBAttributeValue]? = [String : AWSDynamoDBAttributeValue]()
        var keys = Constans.hashDict(tabName)
        var count = 0
        var exps = [String]()
        assert(keys != nil)
        for key in keys!{
            if(count<1){
                exps.append(operationBi(key, op: Op.eq, right: keyVal[count], type: keyTyp[count], dictName: &dictName , dictValue: &dictValue ))
                count++
            }else{
                exps.append(operationBi(key, op: op, right: keyVal[count], type: keyTyp[count], dictName: &dictName , dictValue: &dictValue ))
                count++
            }
        }
        var taskcompletion = BFTaskCompletionSource()
        let result_str = conCat(" and ", strs: exps)
        print("result_str is \(result_str)")
        var query_task = dynamoDB.query(queryItem(tabName, keyExp: result_str, dictName: &dictName, dictValue: &dictValue))
        query_task.continueWithBlock({(task:AWSTask)->AnyObject? in
            if(task.error != nil){
                taskcompletion.setError(task.error!)
            }else{
                var arry = task.result as! [[String:AWSDynamoDBAttributeValue]]
                var new_arry:[ItemV2] = [ItemV2]()
                for item in arry{
                    new_arry.append(ItemV2(dictionary:item))
                }
                taskcompletion.setResult(new_arry)
            }
            
            return nil
        })
        return taskcompletion.task
    }
    //create a AWSDynamoDBQueryInput from input
    class func queryItem(tabName:String,keyExp:String,inout dictName:[String : String]?,inout dictValue:[String : AWSDynamoDBAttributeValue]?)->AWSDynamoDBQueryInput {
        let return_obj = AWSDynamoDBQueryInput()
        //var n1:NSNumber = 1
        return_obj.consistentRead = true
        return_obj.tableName = tabName
        return_obj.keyConditionExpression = keyExp
        return_obj.expressionAttributeNames = dictName!
        return_obj.expressionAttributeValues = dictValue!
        return return_obj
    }
    class func query(input:AWSDynamoDBQueryInput)->AWSTask{
        return dynamoDB.query(input)
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
    //the previous function's polymorphism
    class func conCat(delit:String,strs:[String] )->String{
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
    //example:SET list[0] = :val1 REMOVE #m.nestedField1, #m.nestedField2 ADD aNumber :val2, anotherNumber :val3 DELETE aSet :val4
    class func operationBi(left:String,op:Op?,right:AnyObject,type:String,inout dictName:[String : String]?,inout dictValue:[String : AWSDynamoDBAttributeValue]?)->String{
        if(dictValue==nil || dictName==nil){
            print("Function: \(#function), line: \(#line)")
            return ""
        }
        let attrValue = toAttrValue(right)
        let l_name = "#"+left
        var temp_str:String = ":"
        var ind:String = ""
        switch(type){
        case "Number": ind = "N"
        case "String": ind = "S"
        case "Boolean": ind = "B"
        case "List": ind = "L"
        case "StringSet": ind = "Ss"
        case "NuberSet": ind = "Ns"
        case "Map": ind = "M"
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
            return_str = l_name+" "+temp_str+" "
        }
        else if(op!==Op.append || op!==Op.not_exit){
            return_str = op!.rawValue+"("+l_name+", "+temp_str+") "
        }else{
            return_str = l_name+" "+op!.rawValue+" "+temp_str+" "
        }
        return return_str
        
    }
    //convert the object to AWSDynamoDBAttributeVlaue
    class func toAttrValue(object:AnyObject)->AWSDynamoDBAttributeValue{
        var attrValue:AWSDynamoDBAttributeValue = AWSDynamoDBAttributeValue()
        //tranform object to AWSDynamoDBAttributeValue
        var arry:[AnyObject] = [AnyObject]()
        if let str = object as? String{
            attrValue.S = str
        }else if let num = object as? NSNumber{
            attrValue.N = num.stringValue
        }else if let flag = object as? Bool{
            attrValue.BOOLEAN = NSNumber(bool: flag.boolValue)
        }else if var arry = object as? [AnyObject]{
            var list:[AWSDynamoDBAttributeValue] = [AWSDynamoDBAttributeValue]()
            for element in arry{
                list.append(toAttrValue(element))
            }
        }else if let str_set = object as? Set<String>{
            attrValue.SS = [String](str_set)
        }else if let num_set = object as? Set<NSNumber>{
            var list:[String] = [String]()
            for element in num_set{
                list.append(element.stringValue)
            }
            attrValue.NS = list
        }else if var dict = object as? [String:AnyObject]{
            var new_dict:[String:AWSDynamoDBAttributeValue] = [String:AWSDynamoDBAttributeValue]()
            for (key,buffer) in dict{
                new_dict[key] = toAttrValue(buffer)
            }
            attrValue.M = new_dict
        }else if let item = object as? ItemV2{
            attrValue.M = item.toAttirbuteValue()
        }else{
            print("Error!!'")
        }
        return attrValue
    }
    //create the AWSDynamoDBBatchWriteItemInput for deleteRequest
    class func transTodelete(objects:[String:[NSManagedObject]])->AWSDynamoDBBatchWriteItemInput{
        let keys = Array(objects.keys)
        let returnObject = AWSDynamoDBBatchWriteItemInput()
        returnObject.requestItems = [String : [AWSDynamoDBWriteRequest]]()
        //each key indicate a entity name
        for key in keys{
            let buff = objects[key]
            var writes = [AWSDynamoDBWriteRequest]()
            let key_set:[String]? = Constans.hashDict(key)
            assert(key_set != nil,"Function: \(#function), line: \(#line)\n undefined identity:\(key)")
            if let buff2 = buff{
                //each object indicate a NSManagedObject
                for object in buff2 {
                    let dict = object.entity.attributesByName
                    let wbuff = AWSDynamoDBWriteRequest()
                    wbuff.deleteRequest = AWSDynamoDBDeleteRequest()
                    wbuff.deleteRequest!.key = [String:AWSDynamoDBAttributeValue]()
                    for keyName in key_set!{
                        let attribValue = toAttrValue(object.valueForKey(keyName)!)
                        wbuff.deleteRequest!.key![keyName] = attribValue
                        
                    }
                    writes.append(wbuff)
                }
            }else{
                print("Function: \(#function), line: \(#line)\nerror! buff is nil")
            }
            returnObject.requestItems![key] = writes
        }
        return returnObject
        
    }
    //put item
    //BFTask<void>
    class func Put(tabName:String,item:ItemV2)->BFTask{
        var request = AWSDynamoDBPutItemInput()
        request.tableName = tabName
        request.item = item.toAttirbuteValue()
        var taskcompletion = BFTaskCompletionSource()
        var put_task = dynamoDB.putItem(request)
        put_task.continueWithBlock({(task:AWSTask!)->AnyObject? in
            if(task.error != nil){
                taskcompletion.setError(task.error!)
            }else{
                taskcompletion.setResult(nil)
            }
            return nil
            })
        return taskcompletion.task
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
            let ignored_set = Constans.igonredDict(key)
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
                        if(ignored_set != nil && ignored_set!.contains(attName)){
                            continue
                        }
                        let attribValue = toAttrValue(object.valueForKey(attName)!)
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
    /*class func batchWriteItem(items:[AWSDynamoDBBatchWriteItemInput])->AWSTask{
        
    }*/
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

