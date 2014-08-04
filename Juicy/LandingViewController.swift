//
//  LandingViewController.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/4/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

import Foundation

class LandingViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if PFUser.currentUser() {
            //self.performSegueWithIdentifier("loggedIn", sender: self)
        }
    }
    
    @IBAction func connectButtonDown(sender: UIButton) {
        sender.backgroundColor = UIColor(red: 0.14, green: 0.22, blue: 0.36, alpha: 1)
    }
    
    @IBAction func connectButtonReleased(sender: UIButton) {
        sender.backgroundColor = UIColor(red: 0.25, green: 0.37, blue: 0.58, alpha: 1)
        
        PFFacebookUtils.logInWithPermissions(nil, {
            (user: PFUser!, error: NSError!) -> Void in
            if !user {
                NSLog("Uh oh. The user cancelled the Facebook login.")
            } else if user.isNew {
                NSLog("User signed up and logged in through Facebook!")
            } else {
                NSLog("User logged in through Facebook!")
            }
        })
    }
}
