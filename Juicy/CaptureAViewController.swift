//
//  PostViewController.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/15/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

import UIKit

class CaptureAViewController: UIViewController, VLBCameraViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: IBOutlets
    @IBOutlet weak var captureButton: UIButton!
    
    // MARK: Instance Variables
    private var cameraView: VLBCameraView!
    private var capturedImage: UIImage!
    private var imagePicker: UIImagePickerController!
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Track Event
        Track.event("Camera A Controller: Viewed")
        
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
        
        // Setup Image Picker
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            self.imagePicker = UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(UIImagePickerControllerSourceType.PhotoLibrary)!
            self.presentViewController(imagePicker, animated: false, completion: nil)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.cameraView != nil && !self.cameraView.session.running {
            self.cameraView.awakeFromNib()
        }
        
        // Configure Navigation Bar
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        let viewController = segue.destinationViewController as PostAViewController
        viewController.capturedImage = self.capturedImage
    }
    
    // MARK: IBActions
    @IBAction func cancelCapture(sender: UIBarButtonItem) {
        // Track Event
        Track.event("Capture A Controller: Canceled")
        
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
                Track.event("Camera A Controller: Picture Taken")
            })
        }
    }
    
    @IBAction func toggleCamera(sender: UIBarButtonItem) {
        self.cameraView.toggleCamera()
    }
    
    // MARK: ImagePicker Methods
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {        
        self.dismissViewControllerAnimated(false, completion: { () -> Void in
            self.capturedImage = image
            self.performSegueWithIdentifier("postSegue", sender: self)
        })
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        self.dismissViewControllerAnimated(false, completion: { () -> Void in
            self.navigationController?.popViewControllerAnimated(false)
            return ()
        })
    }
    
    // MARK: VLBCameraView Methods
    func cameraView(cameraView: VLBCameraView!, didFinishTakingPicture image: UIImage!, withInfo info: [NSObject : AnyObject]!, meta: [NSObject : AnyObject]!) {
        self.capturedImage = image
        self.performSegueWithIdentifier("postSegue", sender: self)
    }
    
    func cameraView(cameraView: VLBCameraView!, didErrorOnTakePicture error: NSError!) {
        UIAlertView(title: "Capture Image", message: "Sorry! We failed to your image.", delegate: nil, cancelButtonTitle: "Ok").show()
        self.cameraView.retakePicture()
    }
}
