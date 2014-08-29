//
//  TermsViewController.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/28/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

class TermsViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var webView: UIWebView!
    
    // MARK: Instance Variables
    var currentUser = User.current()
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Seturl WebView Url
        let url = NSURL(string: "http://getjuicyapp.com/terms")
        self.webView.loadRequest(NSURLRequest(URL: url))
    }
    
    override func viewWillAppear(animated: Bool) {
       super.viewWillAppear(animated)
        
        // Configure Navigation Bar
        self.navigationController.navigationBarHidden = false
        self.navigationController.navigationBar.shadowImage = nil
        self.navigationController.navigationBar.translucent = false
        self.navigationController.navigationBar.backgroundColor = UIColor.whiteColor()
        self.navigationController.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
        self.navigationController.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.darkGrayColor(),
            NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 18)
        ]
    }
    
    // MARK: IBActions
    @IBAction func termsCancel(sender: UIBarButtonItem) {
        self.navigationController.popViewControllerAnimated(false)
        User.logout()
    }
    
    @IBAction func termsAccepts(sender: UIBarButtonItem) {
        self.currentUser.acceptedTerms()
        self.performSegueWithIdentifier("loggedInSegue", sender: self)
    }
}
