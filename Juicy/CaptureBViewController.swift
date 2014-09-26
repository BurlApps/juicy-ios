//
//  CaptureBViewController.swift
//  Juicy
//
//  Created by Brian Vallelunga on 9/23/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

import UIKit

class CaptureBViewController: UIViewController, VLBCameraViewDelegate {
    
    // MARK: IBOutlets
    @IBOutlet weak var captureButton: UIButton!
    
    // Mark: Instance Variables
    var postController: PostBViewController!
    
    // MARK: Private Instance Variables
    private var cameraView: VLBCameraView!
    private var imagePicker: UIImagePickerController!
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Track Event
        Track.event("Camera B Controller: Viewed")
        
        // Configure Background
        self.view.backgroundColor = UIColor.blackColor()
        
        // VLBCameraView Set Delegate
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.cameraView = VLBCameraView(frame: self.view.frame)
            self.cameraView.delegate = self
            self.cameraView.awakeFromNib()
            self.view.insertSubview(self.cameraView, belowSubview: self.captureButton)
        })
        
        // Setup Post Button
        self.captureButton.backgroundColor = UIColor(red:0.24, green:0.78, blue:0.29, alpha:0.75)
        
        // Add Post Button Top Border
        var buttonBorder = UIView(frame: CGRectMake(0, 0, self.captureButton.frame.size.width, 3))
        buttonBorder.backgroundColor = UIColor(white: 0, alpha: 0.08)
        self.captureButton.addSubview(buttonBorder)
        
    }
    
    // MARK: IBActions
    @IBAction func cancelCapture(sender: UIBarButtonItem) {
        // Track Event
        Track.event("Capture B Controller: Canceled")
        
        // Pop to Parent View Controller
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    @IBAction func captureDown(sender: UIButton) {
        sender.backgroundColor = UIColor(red:0.2, green:0.64, blue:0.22, alpha:0.75)
    }
    
    @IBAction func captureExit(sender: UIButton) {
        sender.backgroundColor = UIColor(red:0.24, green:0.78, blue:0.29, alpha:0.75)
    }
    
    @IBAction func captureTouchInside(sender: UIButton) {
        sender.backgroundColor = UIColor(red:0.24, green:0.78, blue:0.29, alpha:0.75)
        
        if self.cameraView.session != nil && self.cameraView.session.running {
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.cameraView.takePicture()
                
                // Track Event
                Track.event("Camera B Controller: Picture Taken")
            })
        }
    }
    
    @IBAction func toggleCamera(sender: UIBarButtonItem) {
        self.cameraView.toggleCamera()
    }
    
    // MARK: VLBCameraView Methods
    func cameraView(cameraView: VLBCameraView!, didFinishTakingPicture image: UIImage!, withInfo info: [NSObject : AnyObject]!, meta: [NSObject : AnyObject]!) {
        self.postController.capturedImage = image
        self.postController.updateStyle()
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    func cameraView(cameraView: VLBCameraView!, didErrorOnTakePicture error: NSError!) {
        UIAlertView(title: "Capture Image", message: "Sorry! We failed to your image.", delegate: nil, cancelButtonTitle: "Ok").show()
        self.cameraView.retakePicture()
    }
}
