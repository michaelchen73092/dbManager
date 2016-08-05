//
//  credentialManager.swift
//  dbManager
//
//  Created by guest on 8/4/16.
//  Copyright © 2016 guest. All rights reserved.
//

import Foundation
import AWSCognitoIdentityProvider
import Bolts

class credentialManager:NSObject,AWSCognitoIdentityInteractiveAuthenticationDelegate{
    // MARK:  Initialization
    init(delegate_window:AWSCognitoIdentityPasswordAuthentication){
        super.init()
        self.delegate_window = delegate_window
        //identity pool and user pool setting for configuration
        let serviceConfiguration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: nil)
        let userPoolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: "2k9gbn2f56pnn0b00tsttcv7fg", clientSecret: "1f276ournmt4c0992br3it2dk4ujbslg26jj6mfsk4uq446hr8b0", poolId: "us-east-1_4aWz4tq2G")
        AWSCognitoIdentityUserPool.registerCognitoIdentityUserPoolWithConfiguration(serviceConfiguration, userPoolConfiguration: userPoolConfiguration, forKey: "dynamoDB")
        let pool = AWSCognitoIdentityUserPool(forKey: "dynamoDB")
        self.pool = pool
        self.pool?.delegate = self
    }
    func authentication()->BFTask{
        let taskcompletion = BFTaskCompletionSource()

        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "us-east-1:84ad56ea-0e25-4a70-9b78-7d45235f75d7", identityProviderManager:self.pool)
        //start to trigger authentication process
            self.pool!.currentUser()?.getDetails().continueWithBlock({ (task) -> AnyObject? in
                if(task.error != nil){
                    taskcompletion.setError(task.error!)
                }else{
                    print("finally succesfully login")
                    dispatch_async(dispatch_get_main_queue(), {
                        self.user_detail = task.result as! AWSCognitoIdentityUserGetDetailsResponse

                        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = AWSServiceConfiguration(region: .USEast1,credentialsProvider: credentialsProvider)
                        /*var user_t = self.pool!.getUser("chienlcuciedu")
                         //user_t.forgotPassword().waitUntilFinished()
                         //user_t.confirmForgotPassword("261834", password: "Ss0101221").waitUntilFinished()*/
                        var id = self.pool!.currentUser()?.deviceId
                        self.pool!.currentUser()?.updateDeviceStatus(id!, remembered: true)
                        taskcompletion.setResult(nil)
                    })
                }
                return nil
                })
                return taskcompletion.task
            }
    
    // MARK: Credential
    //var user:AWSCognitoIdentityUser? = nil
    var user_detail:AWSCognitoIdentityProviderGetUserResponse? = nil
    var user_in_wait:AWSCognitoIdentityUser? = nil
    var pool:AWSCognitoIdentityUserPool? = nil
    var delegate_window:AWSCognitoIdentityPasswordAuthentication?
    func startPasswordAuthentication()->AWSCognitoIdentityPasswordAuthentication{
        let loginViewC = self.delegate_window
        dispatch_async(dispatch_get_main_queue()) {
            print("start Authentication process!!")
            //let mainStoryboard: UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
            //let loginViewC = mainStoryboard.instantiateViewControllerWithIdentifier("loginView") as? loginView
            /*dispatch_async(dispatch_get_main_queue(), {
             self.window?.rootViewController = loginViewC
             })*/
            var rootView = (UIApplication.sharedApplication().delegate!).window!!.rootViewController as! UISplitViewController
            print("\(rootView.viewControllers.count) controllers in split view ")
            if(rootView.viewControllers.count==2){
                var detailView = rootView.viewControllers[1] as! UINavigationController
                detailView.pushViewController(loginViewC! as! UIViewController, animated: true)
                
            }

        }
                return loginViewC!
    }
    //signUp function
    func signUp(email_str:String,password_str:String)->BFTask{
        let taskcompletion = BFTaskCompletionSource()
        var attrs:[AWSCognitoIdentityUserAttributeType] = [AWSCognitoIdentityUserAttributeType]()
         var email = AWSCognitoIdentityUserAttributeType()
         email.name = "email"
         email.value = email_str
         attrs.append(email)
         var task_s = self.pool!.signUp(createUserName(email_str), password: password_str, userAttributes: attrs,validationData: nil).continueWithBlock { (task) -> AnyObject? in
            if(task.error != nil){
                taskcompletion.setError(task.error!)
            }else{
                print("successfully register:",task.result as? AWSCognitoIdentityUserPoolSignUpResponse)
                self.user_in_wait = (task.result as? AWSCognitoIdentityUserPoolSignUpResponse)?.user
                taskcompletion.setResult(task.result)
                //self.user = (task.result as! AWSCognitoIdentityUserPoolSignUpResponse).user
            }
         return nil
         }
        return taskcompletion.task
    }
    func verifyEmail(email:String,confirm_code:String)->BFTask{
        var taskcompletion = BFTaskCompletionSource()
        var unverify_user = self.pool!.getUser(createUserName(email))
        var awstask  = unverify_user.confirmSignUp(confirm_code)
        awstask.continueWithBlock { (task) -> AnyObject? in
            if(task.error != nil){
                taskcompletion.setError(task.error!)
            }else{
                taskcompletion.setResult(task.result)
            }
            return nil
        }
        return taskcompletion.task
    }
    func createUserName(email:String)->String{
        var result_str:String = ""
        for character in email.characters {
            if(character == "@" || character == "."){
                continue
            }else{
                result_str.append(character)
            }
        }
        return result_str
    }
    
    
}