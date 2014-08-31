//
//  HomeViewController.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/26/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

class HomeViewController: UIViewController, UIPageViewControllerDataSource {
    
    // MARK: Instance Variables
    private var pageViewController: UIPageViewController!
    private let pages = 5
    private let startPage = 1
    var spinner: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    // MARK: Instance IBoutlets
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Move to Feed View if Logged In
        if PFUser.currentUser() != nil {
            if User.current().terms == true {
                self.performSegueWithIdentifier("loggedInSegue", sender: self)
            } else {
                self.performSegueWithIdentifier("termsSegue", sender: self)
            }
        }
        
        // Configure Status Bar
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: false)
        
        // Create Page View Controller
        self.pageViewController = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: nil)
        self.pageViewController.view.backgroundColor = UIColor.clearColor()
        self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 110)
        self.pageViewController.dataSource = self
        
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
        
        // Setup Button Background
        self.loginButton.backgroundColor = UIColor(red: 0.25, green: 0.37, blue: 0.58, alpha: 1)
        
        // Add Spinner to Connect Button
        self.spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        self.spinner.frame = CGRectMake(0.0, 0.0, 40.0, 40.0)
        self.spinner.center = CGPointMake(self.loginButton.frame.size.width/2.0, self.loginButton.frame.size.height/2)
        self.loginButton.addSubview(spinner)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Setup Navigation Bar
        self.navigationController.navigationBarHidden = true
        
        // Override point for customization after application launch.
        var pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
        pageControl.currentPageIndicatorTintColor = UIColor.darkGrayColor()
        pageControl.backgroundColor = UIColor.clearColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.pageViewController.setViewControllers([self.viewControllerAtIndex(self.startPage)], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Setup Login Button
        self.loginButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.loginButton.setTitle("Log in With Facebook", forState: UIControlState.Normal)
        self.spinner.stopAnimating()
    }
    
    // MARK: IBAction Methods
    @IBAction func loginButtonDown(sender: UIButton) {
        sender.backgroundColor = UIColor(red: 0.14, green: 0.22, blue: 0.36, alpha: 1)
    }
    
    @IBAction func loginButtonExit(sender: UIButton) {
        sender.backgroundColor = UIColor(red: 0.25, green: 0.37, blue: 0.58, alpha: 1)
    }
    
    @IBAction func loginButtonReleased(sender: UIButton) {
        sender.backgroundColor = UIColor(red: 0.25, green: 0.37, blue: 0.58, alpha: 1)
        sender.setTitleColor(UIColor.clearColor(), forState: UIControlState.Normal)
        self.spinner.startAnimating()
        
        PFFacebookUtils.logInWithPermissions(nil, { (user: PFUser!, error: NSError!) -> Void in
            if user != nil {
                var tempUser = User(user)
                
                if user.isNew {
                    tempUser.setExtraInfo({ () -> Void in
                        self.performSegueWithIdentifier("termsSegue", sender: self)
                    })
                } else {
                    if tempUser.terms == true {
                        self.performSegueWithIdentifier("loggedInSegue", sender: self)
                    } else {
                        self.performSegueWithIdentifier("termsSegue", sender: self)
                    }
                }
            } else {
                self.loginButton.setTitle("Failed To Log In", forState: UIControlState.Normal)
                println(error)
            }
        })
    }
    
    // MARK: Instance Methods
    func viewControllerAtIndex(index: Int) -> PageContentViewController! {
        if self.pages == 0 || index >= self.pages {
            return nil
        }
        
        // Create PageViewController
        return PageContentViewController(frame: self.view.frame, index: index)
    }
    
    // MARK: Page View Controller Data Source
    func pageViewController(pageViewController: UIPageViewController!, viewControllerBeforeViewController viewController: UIViewController!) -> UIViewController! {
        var index = (viewController as PageContentViewController).pageIndex
        
        if index == 0 || index == NSNotFound {
            return nil
        }
        
        return self.viewControllerAtIndex(index - 1)
    }
    
    func pageViewController(pageViewController: UIPageViewController!, viewControllerAfterViewController viewController: UIViewController!) -> UIViewController! {
        var index = (viewController as PageContentViewController).pageIndex
        
        if index == NSNotFound || (index + 1) == self.pages {
            return nil
        }
        
        return self.viewControllerAtIndex(index + 1)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController!) -> Int {
        return self.pages
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController!) -> Int {
        return self.startPage
    }
}
