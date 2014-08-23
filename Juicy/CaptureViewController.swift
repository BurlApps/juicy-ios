//
//  PostViewController.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/15/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

import UIKit

class CaptureViewController: UIViewController, VLBCameraViewDelegate {

    // MARK: IBOutlets
    @IBOutlet weak var cameraView: VLBCameraView!
    @IBOutlet weak var captureButton: UIButton!
    
    // MARK: Instance Variables
    private var capturedImage: UIImage!
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // VLBCameraView Set Delegate
        self.cameraView.delegate = self
        
        // Setup Post Button
        self.captureButton.backgroundColor = UIColor(red:0.24, green:0.78, blue:0.29, alpha:0.8)
        
        // Add Post Button Top Border
        var buttonBorder = UIView(frame: CGRectMake(0, 0, self.captureButton.frame.size.width, 3))
        buttonBorder.backgroundColor = UIColor(white: 0, alpha: 0.08)
        self.captureButton.addSubview(buttonBorder)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !self.cameraView.session.running {
            self.cameraView.awakeFromNib()
        }
        
        // Configure Status Bar
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        
        // Configure Navigation Bar
        self.navigationController.navigationBar.translucent = true
        self.navigationController.navigationBar.backgroundColor = UIColor.clearColor()
        self.navigationController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController.navigationBar.shadowImage = UIImage()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        let viewController:PostViewController = segue.destinationViewController as PostViewController
        viewController.capturedImage = self.capturedImage
    }
    
    // MARK: IBActions
    @IBAction func cancelCapture(sender: UIBarButtonItem) {
        self.navigationController.popViewControllerAnimated(false)
    }
    
    @IBAction func captureDown(sender: UIButton) {
        sender.backgroundColor = UIColor(red:0.2, green:0.64, blue:0.22, alpha:0.8)
    }
    
    @IBAction func captureTouchInside(sender: UIButton) {
        sender.backgroundColor = UIColor(red:0.24, green:0.78, blue:0.29, alpha:0.8)
        self.cameraView.takePicture()
    }
    
    @IBAction func toggleCamera(sender: UIBarButtonItem) {
        self.cameraView.toggleCamera()
    }
    
    // MARK: VLBCameraView Methods
    func cameraView(cameraView: VLBCameraView!, didFinishTakingPicture image: UIImage!, withInfo info: [NSObject : AnyObject]!, meta: [NSObject : AnyObject]!) {
        self.capturedImage = image;
        self.performSegueWithIdentifier("postSegue", sender: self)
    }
    
    func cameraView(cameraView: VLBCameraView!, didErrorOnTakePicture error: NSError!) {
        UIAlertView(title: "Capture Image", message: "Sorry! We failed to your image.", delegate: nil, cancelButtonTitle: "Ok").show()
        self.cameraView.retakePicture()
    }
}
