//
//  DetailViewController.swift
//  dbManager
//
//  Created by guest on 6/13/16.
//  Copyright © 2016 guest. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {



    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.valueForKey("timeStamp")!.description
            }
        }
    }

    @IBOutlet weak var confirm_code: UITextField!
    @IBAction func enterConfirm(sender: UIButton) {
        let user = (UIApplication.sharedApplication().delegate as! AppDelegate).cred_Manager?.pool?.currentUser()
        
        
        if let user_t = user{
            user_t.confirmSignUp(self.confirm_code.text!)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

