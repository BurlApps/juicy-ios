//
//  LandingView.swift
//  Juicy
//
//  Created by Brian Vallelunga on 6/16/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

import Foundation

class LandingViewController: UIViewController, VLBCameraViewDelegate {

    // Mark: Outlets
    @IBOutlet var twitterAuthButton : UIButton = nil
    
    
    // Mark: Method Variables
    var cameraView = VLBCameraView()
    
    // Mark: Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if PFUser.currentUser() {
            //self.performSegueWithIdentifier("loggedIn", sender: self)
        }
        
        //Style Status Bar
        var application = UIApplication.sharedApplication()
        application.setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        
        
        //Create Realtime Camera View
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            self.cameraView.frame = self.view.frame
            self.cameraView.delegate = self
            self.view.insertSubview(self.cameraView, atIndex: 0)
        }
        
        
        //Add Basic Gradient
        var gradientView = BKEAnimatedGradientView(frame: self.view.frame)
        gradientView.gradientColors = [
            UIColor(red:0.14, green:0.53, blue:0.86, alpha:0.5),
            UIColor(red:0.14, green:0.53, blue:0.90, alpha:0.5)
        ]
        self.view.insertSubview(gradientView, atIndex: 1)
        
        //Style Twitter Auth Button
        self.twitterAuthButton.layer.cornerRadius = 4
        self.twitterAuthButton.layer.borderWidth = 2.0
        self.twitterAuthButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.2).CGColor
        self.twitterAuthButton.tintColor = UIColor.whiteColor()
        self.twitterAuthButton.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        self.twitterAuthButton.font = UIFont(name: "HelveticaNeue", size: 18);
    }
    
    // Mark: IBActions
    @IBAction func twitterAuthButtonPressed(sender : UIButton) {
        PFTwitterUtils.logInWithBlock {
            (user: PFUser!, error: NSError!) -> Void in
            
            if !user {
                var alert = UIAlertController(title: "Authentication", message: "Failed to Login/Register", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: false, completion: nil)
            } else {
                self.performSegueWithIdentifier("loggedIn", sender: self)
            }
        }
    }
    
    func cameraView(cameraView: VLBCameraView!, didFinishTakingPicture image: UIImage!, withInfo info: NSDictionary!, meta: NSDictionary!) {
    
    }
    
    func cameraView(cameraView: VLBCameraView!, didErrorOnTakePicture error: NSError!) {
    
    }
}