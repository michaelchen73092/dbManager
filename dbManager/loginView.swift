//
//  loginView.swift
//  dbManager
//
//  Created by guest on 7/31/16.
//  Copyright © 2016 guest. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class loginView: UIViewController,AWSCognitoIdentityPasswordAuthentication{
    @IBOutlet weak var userName: UITextField!

    @IBOutlet weak var passWord: UITextField!
    var passwordAuthCom = AWSTaskCompletionSource()
    func getPasswordAuthenticationDetails(authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource) {
        print("Function: \(#function), line: \(#line)")
        self.passwordAuthCom = passwordAuthenticationCompletionSource
    }
    func didCompletePasswordAuthenticationStepWithError(error: NSError?) {
        print("Function: \(#function), line: \(#line)")
        /*dispatch_async(dispatch_get_main_queue(),{
            let mainStoryboard: UIStoryboard = UIStoryboard(name:"Main",bundle:nil)
            
        })*/
        if(error != nil){
            dispatch_async(dispatch_get_main_queue()) {
                self.dismissViewControllerAnimated(false, completion: {
                    let alertController = UIAlertController(title: "Wrong user name or password", message: error!.userInfo["message"] as? String, preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
                    })
                    alertController.addAction(okAction)
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
            }
            print("wrong authentication process!!!")
        }else{
            dispatch_async(dispatch_get_main_queue(), {
                self.dismissViewControllerAnimated(true, completion: { })
            })
        }
    }
    
    @IBAction func buttonPress(sender: UIButton) {
        self.passwordAuthCom.setResult(AWSCognitoIdentityPasswordAuthenticationDetails(username: self.userName.text!,password: self.passWord.text!))
        self.performSegueWithIdentifier("waiting", sender: self)
    }
}