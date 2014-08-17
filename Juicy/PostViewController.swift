//
//  PostViewController.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/16/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

import UIKit

class PostViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var previewImageView: UIImageView!
    
    // MARK: Instance Variables
    var capturedImage: UIImage!
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Preview Image
        self.previewImageView.image = self.capturedImage
        self.previewImageView.contentMode = UIViewContentMode.ScaleAspectFill
        
        // Set Post Button Color
        self.postButton.backgroundColor = UIColor(red:0, green:0.6, blue:1, alpha:1)
        
        // Add Border To Post Button
        var buttonBorder = UIView(frame: CGRectMake(0, 0, self.postButton.frame.size.width, 3))
        buttonBorder.backgroundColor = UIColor(white: 0, alpha: 0.08)
        self.postButton.addSubview(buttonBorder)
    }
    
    // MARK: IBActions
    @IBAction func canelPost(sender: UIBarButtonItem) {
        self.navigationController.popViewControllerAnimated(false)
    }
    
    @IBAction func captureDown(sender: UIButton) {
        self.postButton.backgroundColor = UIColor(red:0.13, green:0.47, blue:0.81, alpha:1)
    }
    
    @IBAction func captureTouchInside(sender: UIButton) {
        self.postButton.backgroundColor = UIColor(red:0, green:0.6, blue:1, alpha:1)
    }
}
