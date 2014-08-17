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
    private var textEditor: CHTTextView!
    private var previewImageView: UIImageView!
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Preview Image
        self.previewImageView = UIImageView(frame: self.view.frame)
        self.previewImageView.image = RBResizeImage(self.capturedImage, self.view.frame.size)
        self.previewImageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.view.addSubview(self.previewImageView)
        
        // Add Darkener
        var darkener = UIView(frame: self.view.frame)
        darkener.backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.view.insertSubview(darkener, aboveSubview: self.previewImageView)
        
        // Add Text Editor
        self.textEditor = CHTTextView(frame: self.view.frame)
        self.textEditor.delegate = self
        self.textEditor.frame.size.width -= 40
        self.textEditor.frame.origin.x += 20
        self.textEditor.frame.origin.y += 120
        self.textEditor.scrollEnabled = false
        self.textEditor.font = UIFont(name: "HelveticaNeue-Bold", size: 24)
        self.textEditor.textColor = UIColor.whiteColor()
        self.textEditor.textAlignment = NSTextAlignment.Center
        self.textEditor.backgroundColor = UIColor.clearColor()
        self.textEditor.placeholder = "Tell us what's juicy!"
        self.textEditor.becomeFirstResponder()
        self.view.insertSubview(self.textEditor, aboveSubview: darkener)
    }
    
    // MARK: IBActions
    @IBAction func canelPost(sender: UIBarButtonItem) {
        self.navigationController.popViewControllerAnimated(false)
    }
    
    // MARK: UITextView Methods
    func textViewDidChange(textView: UITextView!) {
        println(textView.text)
    }
    
}
