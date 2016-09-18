//
//  AWSdb.swift
//  
//
//  Created by guest on 6/29/16.
//This class include the required API for UIViewcontroller
//Server side information:
// /enroll:accept patient's interview request

import Foundation
import AWSDynamoDB
import CoreData
import Bolts
import AWSS3
import AWSCognitoIdentityProvider

class AWSdb: NSObject{
    // MARK:  Authorization
    /*class func createApp()->AWSTask{
        var startime = 0
        dynamoDBManger.
    }*/
    static let instance:AWSdb = AWSdb()
    var prefix = "https://s3.amazonaws.com"
    var domain = "https://192.168.1.2:8443/BerBiHealth"
    var doctor:ItemV2?
    var person:ItemV2?
    var hearbeat_timer:NSTimer?
    static var secondsFromGMT: Int { return NSTimeZone.localTimeZone().secondsFromGMT }
    static var timezone_name: String { return NSTimeZone.localTimeZone().abbreviation!
        
    }
    var cred_Manager = (UIApplication.sharedApplication().delegate as! AppDelegate).cred_Manager
    //Sent the confirmation code to Cognito
    func confirmUser(email:String,confirm_code:String)->BFTask{
        return (self.cred_Manager?.verifyEmail(email, confirm_code:confirm_code))!
        
    }
    //ask the Cognito server to resend confirmation code to email
    func resendConfirm(email:String)->BFTask{
        return (self.cred_Manager?.resendConfirmCode(email))!
    }
    //if the user login as doctor, check whether he is doctor
    //BFTask<Bool>
    func isDoctor(email:String)->BFTask{
        let taskCompletionSource = BFTaskCompletionSource()
        var return_task = dynamoDBManger.Query("Doctors", keyVal: [(self.cred_Manager?.email)!], keyTyp: ["String"], op: nil)
        var tascompletion:BFTaskCompletionSource = BFTaskCompletionSource()
        return_task.continueWithBlock{(task: BFTask!) -> AnyObject? in
            if task.error != nil {
                tascompletion.setError(task.error!)
            } else {
                // set the flag as true
                var flag:Bool
                var objects = task.result as! [ItemV2]
                var object = objects[0]
                //store the this doctor information to self.doctor
                self.doctor = object
                var certificated = object.get("doctorCertificated")
                if let bool = certificated as? Bool{
                    flag = bool
                }else{
                    flag = false
                }
                taskCompletionSource.setResult(flag)
                
            }
            
            print(NSDate().description)
            
            return nil
        }
        return taskCompletionSource.task
    }
    
    //enroll as user
    func enrollAsUser(object:NSManagedObject)->BFTask{
        var item = ItemV2(object: object)
        var taskcompletion = BFTaskCompletionSource()
        var email = item.get("email") as! String
        var passwd = item.get("password") as! String
        var signup_task = cred_Manager?.signUp(email, password_str: passwd)
        signup_task?.continueWithBlock({(task:BFTask)->AnyObject? in
            
            if(task.error != nil){
                taskcompletion.setError(task.error!)
            }else{
                self.uploadImage(email, object: object, contentype: "image/jpeg")
                var put_task = dynamoDBManger.Put("Persons", item: item)
                put_task.continueWithBlock({(in_task:BFTask)->AnyObject? in
                    if(in_task.error != nil){
                        taskcompletion.setError(in_task.error!)
                    }else{
                        taskcompletion.setResult(nil)
                    }
                    return nil
                })
                
            }
            return nil
        })
        return taskcompletion.task
    }
    //upload image, used in closure
    private func uploadImage(email:String,object:NSManagedObject,contentype:String)
    {
        var isDoctor = object.valueForKey("isdoctor") as? NSNumber
        uploadImage(email, attrName: "imageLocal", object: object, contentype: contentype)
        if(isDoctor?.boolValue == true){
            uploadImage(email, attrName: "doctorImageDiploma", object: object, contentype: contentype)
            uploadImage(email, attrName: "doctorImageID", object: object, contentype: contentype)
            uploadImage(email, attrName: "doctorImageMedicalLicense", object: object, contentype: contentype)
            uploadImage(email, attrName: "doctorImageSpecialistLicense", object: object, contentype: contentype)
        }
        
        
        
    }
    //upload image
    func uploadImage(email:String,attrName:String,object:NSManagedObject,contentype:String)->BFTask{
        var data = object.valueForKey(attrName) as? NSData
        var taskcompletion = BFTaskCompletionSource()
        if(data == nil){
            taskcompletion.setResult(nil)
            return taskcompletion.task
        }
        switch attrName {
        case "imageLocal":
            return s3Manager.upload("photo", filename: email, data: data!, contenType: contentype)
        case "doctorImageDiploma":
            return s3Manager.upload("doctorDploma", filename: email, data: data!, contenType: contentype)
        case "doctorImageID":
            return s3Manager.upload("doctorID", filename: email, data: data!, contenType: contentype)
        case "doctorImageMedicalLicense":
            return s3Manager.upload("doctorMedicalLicense", filename: email, data: data!, contenType: contentype)
        case "doctorImageSpecialistLicense":
            return s3Manager.upload("doctorSpecialistLicense", filename: email, data: data!, contenType: contentype)
        default:
            taskcompletion.setResult(nil)
            return taskcompletion.task
        }
    }
    //enroll as doctor
    func enrollAsDoctor(object:NSManagedObject)->BFTask{
        var item = ItemV2(object:object)
        var email:String = item.get("email") as! String
        item.put("doctorImageRemoteURL", object: prefix+"/doctorID"+"/"+email)
        return dynamoDBManger.Put("Doctors", item: item)
    }
    //enroll the PersonsPublic information
    func enrollPersonsPublic(object:NSManagedObject)->BFTask{
        var item = ItemV2(object:object)
        var email = item.get("email") as! String
        item.put("imageRemoteUrl", object: prefix+"/photo"+"/"+email)
        return dynamoDBManger.Put("PersonsPublic", item: item)
    }
    // MARK: Online interview(Patient Side)
    //fetch the entire onlineDoctors table
    func onlineDoctors()->BFTask{
        return dynamoDBManger.Scan("onlineDoctors")
    }
    //fetch specific doctor's comment table
    func doctorComments(email:String)->BFTask{
        return dynamoDBManger.Query("Comments", keyVal: [email], keyTyp: ["String"], op: nil)
    }
    //enroll online doctor's interview
    //send request to java server
    //item-ItemV2 doctor
    //    -ItemV2 patient
    func enrollOnlineInterview(doctor_email:String)->BFTask{
        var item = ItemV2()
        item.put("doctor", object:["email":doctor_email])
        item.put("patient", object: self.person!)
        return postRequest(item, path: "/enroll/online")
       }
    //MARK: Communication
    //getRequest, the response is in BFTask
    //BFTask<the response from server>
    private func getRequest(parameter:String,path:String)->BFTask{
        var request = NSMutableURLRequest(URL: NSURL(string: domain + path+"?"+parameter)!)
        
        //var session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        var taskcompletion = BFTaskCompletionSource()
        var task = sessionManager.instance.sharedsession.dataTaskWithRequest(request,completionHandler:  { (data, response, error) in
            if(error == nil){
                self.convertHttpResponse(data, response: response, taskcompletion: taskcompletion)
                
            }else{
                print("Error: \(error)")
                taskcompletion.setError(error!)
            }
            
        })
        task.resume()
        
        return taskcompletion.task
    }

    //postRequest, the response is in BFTask
    //BFTask<the response from server>
    private func postRequest(item:ItemV2,path:String)->BFTask{
        var request = NSMutableURLRequest(URL: NSURL(string: domain + path)!)
        
        //var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        do{
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(item.dict, options: NSJSONWritingOptions(rawValue: 0))
        }catch{
            print(error)
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        var taskcompletion = BFTaskCompletionSource()
        var task = sessionManager.instance.sharedsession.dataTaskWithRequest(request,completionHandler:  { (data, response, error) in
            if(error == nil){
                self.convertHttpResponse(data, response: response, taskcompletion: taskcompletion)
                
            }else{
                print("Error: \(error)")
                taskcompletion.setError(error!)
            }
            
        })
        task.resume()
        
        return taskcompletion.task
    }
private func convertHttpResponse(data:NSData?,response:NSURLResponse?,taskcompletion:BFTaskCompletionSource){
            var httpresponse = response as! NSHTTPURLResponse
            print("Response: \(response)")
        var strData:AnyObject?
        do {
            strData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions()) as? [String:AnyObject]
        } catch {
            print(error)
            strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
        }
        print("Body: \(strData)")
        if(httpresponse.statusCode == 200){
            if let string = strData as? String{
                taskcompletion.setResult(strData!)
            }else if let buffer = strData as? [String:AnyObject]{
                var emp_item = ItemV2()
                emp_item.dict = buffer
                taskcompletion.setResult(emp_item)
            }else{
                print("Unknow type for response")
            }
        }else{
            var error = NSError(domain: "httpError",code: httpresponse.statusCode,userInfo: ["message":strData!])
            taskcompletion.setError(error)
        }
    }
    // MARK: Interview(Patient Side)
    //write the comment for this interview to the comment table
    func writeComment(doctorEmail:String,object:[String:AnyObject])->BFTask{
        var key = ItemV2()
        key.put("email", object: doctorEmail)
        var date = NSDate()
        var num = NSNumber.init(integer: Int(date.timeIntervalSince1970))
        var buffer = object
        buffer["time"] = num
        return appendList("Comments", key: key, listName: "comments", element: buffer, type: "Map", defaultExp: "", condExp: "", dict_Name: nil, dict_Value: nil)
    }
    //appendList update, but only for list
    func appendList(tabName:String,key:ItemV2,listName:String,element:AnyObject,type:String,defaultExp:String,condExp:String,dict_Name:[String:String]?,dict_Value:[String:AWSDynamoDBAttributeValue]?)->BFTask{
        var dictName:[String:String]? = dict_Name == nil ? [String:String]() : dict_Name
        var dictValue:[String:AWSDynamoDBAttributeValue]? = dict_Value == nil ? [String:AWSDynamoDBAttributeValue]() : dict_Value
        var updateExp:String = UpdateOp.SET.rawValue+" "+"#"+listName+" = "+dynamoDBManger.operationBi(listName, op: Op.append, right: element, type: type, dictName: &dictName , dictValue: &dictValue)
        updateExp += defaultExp
        var request = dynamoDBManger.updateItem(listName,key: key.toAttirbuteValue(), upExp: updateExp, condExp: condExp, dictName: &(dictName!), dictValue: &(dictValue!))
        return dynamoDBManger.Update(request)
    }
    //fetch medical record from patient's table(Records_Patient)
    //medical record:
    //medical record is a list
    func fetchPatientRecord(email:String)->BFTask{
        return dynamoDBManger.Query("Records_Patient", keyVal: [email], keyTyp: ["String"], op: nil)
    }
    
    // MARK: Interview(Doctor Side)
    
    //turn doctor's status online
    //doctor has to set the maximum number for nonappoinmet patient 
    //in his waitlist
    //ItemV2 format:
    //item-ItemV2 doctor
    //    -openings
    func turnOnline(num:NSNumber)->BFTask{
        var item = ItemV2()
        item.put("doctor", object: self.doctor!)
        item.put("openings", object: num)
        return postRequest(item, path: "/online/turnonline")
    }
    //refresh waitlist
    //upon receiving push notification, fetch the entire queue again
    //or when doctor want to pick up next patient
    func fetchWaitlist()->BFTask{
        var param = "doctor="+(self.doctor?.get("email") as! String)
        return getRequest(param, path: "/waitlist")
    }
    //start to talk to current patient
    //inform server this patient is taken
    //sent the hearbeat
    func startToTalk()->BFTask{
        //let timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateCounter"), userInfo: nil, repeats: true)
        var taskcompletion = BFTaskCompletionSource()
        var param = "doctor="+(self.doctor?.get("email") as! String)
        var taken_task = getRequest(param, path: "/taken")
        taken_task.continueWithBlock({(task:BFTask)->AnyObject? in
            if(task.error != nil){
                taskcompletion.setError(task.error!)
            }else{
                self.sendHearbeat()
                taskcompletion.setResult(nil)
            }
            return nil
        })
        return taskcompletion.task
        
    }
    //the function to send heartbeat
    private func sendHearbeat(){
        let timer2 = NSTimer.init(timeInterval:1, target: self, selector: Selector("updateHearBeat"), userInfo: nil, repeats: true)
        self.hearbeat_timer = timer2
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var loop = NSRunLoop.currentRunLoop()
            loop.addTimer(timer2, forMode: NSRunLoopCommonModes)
            loop.run()
        })
    }
    //the function used in NSTimer
    func updateHeartBeat(){
        var current_time = Int(NSDate().timeIntervalSince1970)
        var item = ItemV2()
        var email = self.doctor?.get("email") as! String
        item.put("heartbeat", object: NSNumber.init(long: current_time))
        item.put("email", object: email)
        postRequest(item, path: "heartbeat/").continueWithBlock({(task:BFTask)->AnyObject? in
            if(task.error != nil){
                self.hearbeat_timer?.invalidate()
            }
            return nil
        })
    }
    //end the call and stop heartbeat
    func endCall()->BFTask{
        self.hearbeat_timer?.invalidate()
        var param = "doctor="+(self.doctor?.get("email") as! String)
        return getRequest(param, path: "/endcall")
    }
    //update the medical record to patient and doctor's table
    //in doctor side medical record is also a list
    func updateMedicalRecord(object:NSManagedObject,patientEmail:String)->BFTask{
        var item = ItemV2(object:object)
        
        var doctor_key = ItemV2()
        doctor_key.put("email", object: self.doctor?.get("email") as! String)
        var patient_key = ItemV2()
        patient_key.put("email", object: patientEmail)
        
        var date = NSDate()
        var num = NSNumber.init(integer: Int(date.timeIntervalSince1970))
        item.put("time", object: num)
        
        var doctor_task = appendList("Records_Doctor", key: doctor_key, listName: "MedicalRecords", element: item, type: "Map", defaultExp: "", condExp: "", dict_Name: nil, dict_Value: nil)
        var patient_task = appendList("Records_Patient", key: patient_key, listName: "MedicalRecords", element: item, type: "Map", defaultExp: "", condExp: "", dict_Name: nil, dict_Value: nil)
        
        return BFTask.init(forCompletionOfAllTasksWithResults: [doctor_task,patient_task])
    }
    //modify the nonappointment patient's number of waitlist
    func modifyOpeinings(num:Int)->BFTask{
        var item = ItemV2()
        item.put("email", object: self.doctor?.get("email") as! String)
        item.put("openings", object: NSNumber.init(long: num))
        return postRequest(item, path: "/online/modifyopenings")
    }
    //stop accepting nonappointment patient
    func stopAccepting()->BFTask{
        return modifyOpeinings(0)
    }
    //end  interview
    func endInterview()->BFTask{
        var item = ItemV2()
        item.put("email", object: self.doctor?.get("email") as! String)
        return postRequest(item, path: "/online/endinterview")
    }
    // MARK: Appointment(doctor side)
    
    //fetch subsequent two weeks appointment information
    /*func fetchDoctorAppointment()->BFTask{
        var date = Date()
        
    }*/
    //transform the time information to a specific date
    class func toLocalTime(year:NSNumber,month:NSNumber,day:NSNumber,time:String){
        var calendar = NSCalendar.init(identifier: "gregorian")
        var time_arry = time.componentsSeparatedByString(":")
        var hour = Int.init(time_arry[0])
        var min = Int.init(time_arry[1])
        var year_buff = Int.init(year)
        var month_buff = Int.init(month)
        var day_buff = Int.init(day)
        //* eraValueとは紀元前:0, 紀元後:1
        var date = calendar!.dateWithEra(1, year: year_buff, month: month_buff, day: day_buff, hour: hour!, minute: min!, second: 0, nanosecond: 0)
        
    }
    //fetch specific date's appoinment information
    
    //open appoinment,determining the date, openings for the appointment
    
    //modify specific date's appointment,the openings can not be lower than registration.If the opening goes down to zero,  this appoinment is canceled
    
    //MARK: Appointment(patient side)
    
    //fetch the subsequent two weeks appoinment information from Appointment
    
    //make appointment only if restration is less than opening, atomic increase registration
    
    //????????patient's own appointment table(Appointment:patient)
    //write the appoinment iformation into it
    
    //send local notification to notification center
    
    //fetch patient's appointment information

    //cancel appointment, and erase the appointment information forin patient's table(only allowed thirty minutes bofore the appointment time, done by server side)
    

}