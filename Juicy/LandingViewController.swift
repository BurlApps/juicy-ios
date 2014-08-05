//
//  LandingViewController.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/4/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

import Foundation

class LandingViewController: UIViewController {
    
    var spinner: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    @IBOutlet weak var connectButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Navigation Bar
        self.navigationController.navigationBarHidden = true
        
        // Add Spinner to Connect Button
        self.spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        self.spinner.frame = CGRectMake(0.0, 0.0, 40.0, 40.0)
        self.spinner.center = CGPointMake(self.connectButton.frame.size.width/2.0, self.connectButton.frame.size.height/2)
        self.connectButton.addSubview(spinner)
        
        // Move to Feed View if Logged In
        if PFUser.currentUser() {
            self.performSegueWithIdentifier("loggedInSegue", sender: self)
        }
    }
    
    @IBAction func connectButtonDown(sender: UIButton) {
        self.connectButton.backgroundColor = UIColor(red: 0.14, green: 0.22, blue: 0.36, alpha: 1)
    }
    
    @IBAction func connectButtonReleased(sender: UIButton) {
        self.connectButton.backgroundColor = UIColor(red: 0.25, green: 0.37, blue: 0.58, alpha: 1)
        self.connectButton.setTitleColor(UIColor.clearColor(), forState: UIControlState.Normal)
        self.spinner.startAnimating()
        
        PFFacebookUtils.logInWithPermissions(nil, { (user: PFUser!, error: NSError!) -> Void in
            self.connectButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            self.spinner.stopAnimating()
            
            if user {
                self.performSegueWithIdentifier("loggedInSegue", sender: self)
            }
        })
    }
}
