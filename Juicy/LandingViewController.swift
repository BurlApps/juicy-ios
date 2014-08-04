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
}
