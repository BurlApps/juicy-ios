//
//  LandingViewController.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/4/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

class LandingViewController: UIViewController {
    
    var spinner: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure Status Bar
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: false)
        
        // Add Spinner to Connect Button
        self.spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        self.spinner.frame = CGRectMake(0.0, 0.0, 40.0, 40.0)
        self.spinner.center = CGPointMake(self.loginButton.frame.size.width/2.0, self.loginButton.frame.size.height/2)
        self.loginButton.addSubview(spinner)
        
        // Move to Feed View if Logged In
        if PFUser.currentUser() {
            self.performSegueWithIdentifier("loggedInSegue", sender: self)
        }
        
        // Setup Login Button
        self.loginButton.backgroundColor = UIColor(red: 0.25, green: 0.37, blue: 0.58, alpha: 1)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Setup Navigation Bar
        self.navigationController.navigationBarHidden = true
    }
    
    @IBAction func loginButtonDown(sender: UIButton) {
        sender.backgroundColor = UIColor(red: 0.14, green: 0.22, blue: 0.36, alpha: 1)
    }
    
    @IBAction func loginButtonReleased(sender: UIButton) {
        sender.backgroundColor = UIColor(red: 0.25, green: 0.37, blue: 0.58, alpha: 1)
        sender.setTitleColor(UIColor.clearColor(), forState: UIControlState.Normal)
        self.spinner.startAnimating()
        
        PFFacebookUtils.logInWithPermissions(nil, { (user: PFUser!, error: NSError!) -> Void in
            self.loginButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            self.spinner.stopAnimating()
            
            if user {
                if user.isNew {
                    User(user, withRelations: false).getFacebookInfo()
                }
                
                self.performSegueWithIdentifier("loggedInSegue", sender: self)
            } else {
                self.loginButton.setTitle("Failed To Log In", forState: UIControlState.Normal)
            }
        })
    }
}
