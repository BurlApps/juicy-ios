//
//  PostViewController.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/16/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

import UIKit
import Foundation
import QuartzCore

class PostViewController: UIViewController, UITextViewDelegate {
    
    // MARK: Instance Variables
    var capturedImage: UIImage!
    private var textEditor: CHTTextView!
    private var previewImageView: UIImageView!
    private var currentUser: User = User.current(false)
    
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
        self.textEditor.frame.origin.y += 110
        self.textEditor.scrollEnabled = false
        self.textEditor.placeholder = "Tell us what's juicy!"
        self.textEditor.font = UIFont(name: "HelveticaNeue-Bold", size: 24)
        self.textEditor.textColor = UIColor.whiteColor()
        self.textEditor.textAlignment = NSTextAlignment.Center
        self.textEditor.backgroundColor = UIColor.clearColor()
        self.textEditor.layer.shadowColor = UIColor(white: 0, alpha: 0.2).CGColor
        self.textEditor.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.textEditor.layer.shadowOpacity = 1
        self.textEditor.layer.shadowRadius = 0
        self.textEditor.becomeFirstResponder()
        self.view.insertSubview(self.textEditor, aboveSubview: darkener)
    }
    
    override func viewWillAppear(animated: Bool) {
        // Get Friends List
        self.currentUser.getFriendsList(nil)
        
        // Configure Navigation Bar
        self.navigationItem.title = "0/75"
        self.navigationController.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 22)
        ]
        self.navigationItem.rightBarButtonItem.setTitleTextAttributes([
            NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 20)
        ], forState: UIControlState.Normal)
    }
    
    // MARK: IBActions
    @IBAction func canelPost(sender: UIBarButtonItem) {
        self.navigationController.popViewControllerAnimated(false)
    }
    
    // MARK: Instance Methods
    func detectFriendsInMessage(text: String) -> [NSRange] {
        let lowerText = NSString(string: text.lowercaseString)
        var ranges: [NSRange] = []
        
        if self.currentUser.friendsList != nil {
            for friend in self.currentUser.friendsList {
                let range = lowerText.rangeOfString(friend.name.lowercaseString)

                if range.location != Foundation.NSNotFound {
                    ranges.append(range)
                }
            }
        }
        
        return ranges
    }
    
    // MARK: UITextView Methods
    func textView(textView: UITextView!, shouldChangeTextInRange range: NSRange, replacementText text: String!) -> Bool {
        return textView.text.utf16Count + (text.utf16Count - range.length) <= 75;
    }
    
    func textViewDidChange(textView: UITextView!) {
        var textColor = UIColor.whiteColor()
        var mutalableText = NSMutableAttributedString(attributedString: textView.attributedText)
        let friends = self.detectFriendsInMessage(textView.text)
        
        mutalableText.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSMakeRange(0, mutalableText.length))
        
        for friend in friends {
            mutalableText.addAttribute(NSForegroundColorAttributeName, value: UIColor(red:0.31, green:0.95, blue:1, alpha:1), range: friend)
        }
        
        if mutalableText.length >= 65 {
            textColor = UIColor(red:0.95, green:0.24, blue:0.31, alpha:1)
        } else if mutalableText.length >= 55 {
            textColor = UIColor(red:1, green:0.6, blue:0, alpha:1)
        }
        
        textView.attributedText = mutalableText
        self.navigationItem.title = "\(mutalableText.length)/75"
        self.navigationController.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: textColor,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 22)
        ]
    }
}
