//
//  PostViewController.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/16/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

import UIKit

class PostViewController: UIViewController, UITextViewDelegate {
    
    // MARK: Instance Variables
    var capturedImage: UIImage!
    private var textEditor: UITextView!
    private var previewImageView: UIImageView!
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blueColor()
        
        // Set Preview Image
        var frame = UIScreen.mainScreen().bounds
        let navFrame = self.navigationController.navigationBar.frame
        frame.origin.y += navFrame.origin.y + navFrame.size.height
        frame.size.height -= navFrame.origin.y + navFrame.size.height - 2
        
        self.previewImageView = UIImageView(frame: frame)
        self.previewImageView.image = RBResizeImage(self.capturedImage, frame.size)
        self.previewImageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.view.addSubview(self.previewImageView)
        
        // Add Darkener
        var darkener = UIView(frame: self.view.frame)
        darkener.backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.view.insertSubview(darkener, aboveSubview: self.previewImageView)
        
        // Add Text Editor
        self.textEditor = UITextView(frame: frame)
        self.textEditor.frame.size.width -= 40
        self.textEditor.frame.origin.x += 20
        self.textEditor.frame.origin.y += 60
        self.textEditor.delegate = self
        self.textEditor.scrollEnabled = false
        self.textEditor.font = UIFont(name: "HelveticaNeue-Bold", size: 24)
        self.textEditor.textColor = UIColor.whiteColor()
        self.textEditor.textAlignment = NSTextAlignment.Center
        self.textEditor.backgroundColor = UIColor(white: 0, alpha: 0)
        self.textEditor.becomeFirstResponder()
        self.view.insertSubview(self.textEditor, aboveSubview: darkener)
    }
    
    // MARK: IBActions
    @IBAction func canelPost(sender: UIBarButtonItem) {
        self.navigationController.popViewControllerAnimated(false)
    }
    
}
