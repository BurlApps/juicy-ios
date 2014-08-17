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
        self.textEditor.frame.origin.y += 120
        self.textEditor.scrollEnabled = false
        self.textEditor.placeholder = "Tell us what's juicy!"
        self.textEditor.font = UIFont(name: "HelveticaNeue-Bold", size: 24)
        self.textEditor.textColor = UIColor.whiteColor()
        self.textEditor.textAlignment = NSTextAlignment.Center
        self.textEditor.backgroundColor = UIColor.clearColor()
        self.textEditor.layer.shadowColor = UIColor(white: 0, alpha: 0.2).CGColor
        self.textEditor.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.textEditor.layer.shadowOpacity = 1
        self.textEditor.layer.shadowRadius = 0
        self.textEditor.becomeFirstResponder()
        self.view.insertSubview(self.textEditor, aboveSubview: darkener)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.currentUser.getFriendsList(nil)
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
    func textViewDidChange(textView: UITextView!) {
        var mutalableText = NSMutableAttributedString(attributedString: textView.attributedText)
        let friends = self.detectFriendsInMessage(textView.text)
        
        mutalableText.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSMakeRange(0, mutalableText.length))
        
        for friend in friends {
            mutalableText.addAttribute(NSForegroundColorAttributeName, value: UIColor(red:0.31, green:0.95, blue:1, alpha:1), range: friend)
        }
        
        textView.attributedText = mutalableText
    }
}
