//
//  PostViewController.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/15/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

import UIKit

class PostViewController: UIViewController, VLBCameraViewDelegate {

    // MARK: IBOutlets
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var cameraView: VLBCameraView!
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Post Button
        self.postButton.backgroundColor = UIColor(red:0.24, green:0.78, blue:0.29, alpha:1)
        
        // Add Post Button Top Border
        var buttonBorder = UIView(frame: CGRectMake(0, 0, self.postButton.frame.size.width, 3))
        buttonBorder.backgroundColor = UIColor(white: 0, alpha: 0.08)
        self.postButton.addSubview(buttonBorder)
    }
    
    // MARK: IBActions
    @IBAction func cancelPost(sender: UIBarButtonItem) {
        self.navigationController.popViewControllerAnimated(false)
    }
    
    @IBAction func postDown(sender: UIButton) {
        sender.backgroundColor = UIColor(red:0.2, green:0.64, blue:0.22, alpha:1)
    }
    
    @IBAction func postTouchInside(sender: UIButton) {
        sender.backgroundColor = UIColor(red:0.24, green:0.78, blue:0.29, alpha:1)
    }
    
    @IBAction func toggleCamera(sender: UIBarButtonItem) {
        self.cameraView.toggleCamera()
    }
    
    // MARK: VLBCameraView Methods
    func cameraView(cameraView: VLBCameraView!, didCreateCaptureConnection captureConnection: AVCaptureConnection!) {
    }
    
    func cameraView(cameraView: VLBCameraView!, didFinishTakingPicture image: UIImage!, withInfo info: [NSObject : AnyObject]!, meta: [NSObject : AnyObject]!) {

    }
    
    func cameraView(cameraView: VLBCameraView!, willRriteToCameraRollWithMetadata metadata: [NSObject : AnyObject]!) {

    }
    
    func cameraView(cameraView: VLBCameraView!, didErrorOnTakePicture error: NSError!) {
    
    }
}
