//
//  AppDelegate.swift
//  dbManager
//
//  Created by guest on 6/13/16.
//  Copyright © 2016 guest. All rights reserved.
//

import UIKit
import CoreData
import AWSCore
import testKit
import AWSS3
import AWSDynamoDB
import AWSCognitoIdentityProvider


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    // MARK: Managers for accessing AWS service
    var cred_Manager:credentialManager? = nil
    

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        registerForPushNotification(application)
        
        //self.pool!.currentUser()?.signOut()
        let mainStoryboard: UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
        self.cred_Manager = credentialManager.init(delegate_window:mainStoryboard.instantiateViewControllerWithIdentifier("loginView") as! loginView)
        //self.cred_Manager?.signUp("zero064@hotmail.com", password_str: "Ss0101221")
        //self.cred_Manager?.verifyEmail("zero064@hotmail.com", confirm_code: "653048")
        self.cred_Manager?.pool?.currentUser()?.signOut()
        self.cred_Manager?.authentication().continueWithSuccessBlock { (BFTask) -> AnyObject? in
            print("finally it works")
            return nil
        }


        //var user = pool.getUser("chienlcuciedu").confirmSignUp("932226")
        //testPost()
        //testBolts.testPost()
        //s3Manager.listObjects()
        //UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        return true
    }
    /*// MARK: Credential
    var user:AWSCognitoIdentityUser? = nil
    var user_detail:AWSCognitoIdentityProviderGetUserResponse? = nil
    var pool:AWSCognitoIdentityUserPool? = nil
    func startPasswordAuthentication()->AWSCognitoIdentityPasswordAuthentication{
        print("start Authentication process!!")
        let mainStoryboard: UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
        let loginViewC = mainStoryboard.instantiateViewControllerWithIdentifier("loginView") as? loginView
        /*dispatch_async(dispatch_get_main_queue(), {
            self.window?.rootViewController = loginViewC
        })*/
        var rootView = self.window?.rootViewController as! UISplitViewController
        print("\(rootView.viewControllers.count) controllers in split view ")
        if(rootView.viewControllers.count==2){
            var detailView = rootView.viewControllers[1] as! UINavigationController
            detailView.pushViewController(loginViewC!, animated: true)
            
        }
        return loginViewC!
    }*/
    // MARK: Background fetch
    // Support for background fetch
    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
        /*
         Store the completion handler.
         */
        AWSS3TransferUtility.interceptApplication(application, handleEventsForBackgroundURLSession: identifier, completionHandler: completionHandler)
    }
    /*func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        print("background fetch begins")
        var startDate = NSDate()
        print(startDate.description)
        dynamoDBManger.testQuery("Test2", keyVal: ["zero064@gmail.com",2],keyTyp: [NSAttributeType.StringAttributeType,NSAttributeType.Integer32AttributeType], op: Op.eq).continueWithBlock{(task: AWSTask!) -> AnyObject! in
            if task.error != nil {
                print("Can't fetch data")
                print("Error: \(task.error)")
                let tess = task.error!.description
                print("description:\(tess)")
            } else {
                // the object was saved successfully.
                var object = task.result as! AWSDynamoDBQueryOutput
                var dict = object.items![0]
                print("\(dict["queue"])")
            }
            print("startDate "+startDate.description)
            print("endDate "+NSDate().description)
            print("Finally!!! background fetch ends")
            return nil

        }
        completionHandler(.NewData)

       
    }*/

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    // MARK: NSURL
    func testPost(){
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
        var task = session.dataTaskWithRequest(request,completionHandler:  { (data, response, error) in
            if(error == nil){
                print("Response: \(response)")
                var strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
                 print("Body: \(strData)")
            }else{
                print("Error: \(error)")
            }
            
        })
        task.resume()
    }
    // MARK: - Push Notification
    var token:String?
    func registerForPushNotification(application: UIApplication){
        print("Function: \(#function), line: \(#line)")
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Badge,.Sound,.Alert],categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
    }
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        print("Function: \(#function), line: \(#line)")
        if notificationSettings.types != .None {
            print("get permission for remoteNotifications")
            application.registerForRemoteNotifications()
        }
    }
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        print("Function: \(#function), line: \(#line)")
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        for i in 0..<deviceToken.length {
            tokenString +=  String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        token = tokenString
        print("Device Token:",tokenString)
        
        
        //update token
        /*let token2 = NSEntityDescription.insertNewObjectForEntityForName("APNs", inManagedObjectContext: managedObjectContext)
        var token_arry = [NSManagedObject]()
        token2.setValue("Chien-Lin", forKey: "firstname")
        token2.setValue("zero064@gmail.com", forKey: "email")
        token2.setValue("Chen", forKey: "lastname")
        token2.setValue(token, forKey: "token")
        token_arry.append(token2)
        
        let  obj_pari = ["APNs":token_arry]
        dynamoDBManger.dynamoDB.batchWriteItem(dynamoDBManger.transTowrite(obj_pari))*/
        
    }
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Function: \(#function), line: \(#line)")
        print("Failed to register:",error)
    }
    func application(application: UIApplication,didReceiveRemoteNotification userInfo: [NSObject : AnyObject],fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void){
        print("Function: \(#function), line: \(#line)")
        let aps = userInfo["aps"] as! [String:AnyObject]
        handleNotification(aps)
        completionHandler(.NewData)
        
        
    }
    func handleNotification(aps:[String:AnyObject]){
        let message = aps["alert"] as! String
        print(message)
    }
    
    
    
    // MARK: - Split view
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
        if topAsDetailController.detailItem == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }
    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "healthcare.dbManager" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let PersonsBundle = NSBundle(identifier:"BoBiHealth.testKit")
        let modelURL = PersonsBundle!.URLForResource("PersonsModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

