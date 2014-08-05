//
//  FeedViewController.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/4/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

class FeedViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Navigation Bar
        self.navigationController.navigationBarHidden = false
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        if PFUser.currentUser() {
            PFUser.logOut()
        }
    }

}
