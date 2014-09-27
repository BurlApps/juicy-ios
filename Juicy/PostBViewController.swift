//
//  PostBViewController.swift
//  Juicy
//
//  Created by Brian Vallelunga on 9/23/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

import UIKit

class PostBViewController: UIViewController, UITextViewDelegate, UIActionSheetDelegate, LocationDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Class Enum
    enum SourceType {
        case Library, Camera
    }
    
    // MARK: Instance Variables
    var capturedImage: UIImage!
    var sourceType: SourceType = .Camera
    
    // MARK: Private Instance Variables
    private var darkener: UIView!
    private var cityLocation: String!
    private var textEditor: CHTTextView!
    private var previewImageView: UIImageView!
    private var user: User = User.current()
    private var location: Location!
    private var friends: Friends!
    private var background: Int!
    private var backgrounds: [UIColor]!
    private let duration: NSTimeInterval = 0.2
    private let delay: NSTimeInterval = 0
    
    // MARK: Instance IBOutlets
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Track Event
        Track.event("Post B Controller: Viewed")
        
        // Set Toolbar
        self.toolbar.alpha = 0
        self.toolbar.setShadowImage(UIImage(), forToolbarPosition: UIBarPosition.Any)
        self.toolbar.setBackgroundImage(UIImage(), forToolbarPosition: UIBarPosition.Any, barMetrics: UIBarMetrics.Default)
        self.toolbar.backgroundColor = UIColor.clearColor()
        
        // Set Preview Image
        self.previewImageView = UIImageView(frame: self.view.frame)
        self.previewImageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.previewImageView.alpha = 0
        self.view.insertSubview(self.previewImageView, belowSubview: self.toolbar)
        
        // Add Darkener
        self.darkener = UIView(frame: self.view.frame)
        self.darkener.backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.view.insertSubview(self.darkener, aboveSubview: self.previewImageView)
        
        // Set Background
        self.view.backgroundColor = UIColor.blackColor()
        
        // Get Backgrounds
        Settings.sharedInstance { (settings) -> Void in
            self.background = Int(arc4random_uniform(UInt32(settings.backgrounds.count)))
            self.backgrounds = settings.backgrounds
            self.updateStyle()
        }
        
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
        self.view.insertSubview(self.textEditor, aboveSubview: darkener)
        
        // Create Location Manager
        self.location = Location()
        self.location.delegate = self
        
        // Create Friends Manager
        self.friends = Friends()
        
        // Left Swipe Gesture
        var leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("leftSwipe:"))
        leftSwipe.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(leftSwipe)
        
        // Right Swipe Gesture
        var rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("rightSwipe:"))
        rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(rightSwipe)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Get Current Location
        self.location.startUpdating()
        
        // Get Friends List
        self.user.getFriendsList { (users) -> Void in
            self.friends.friends = users
        }
        
        // Get Contact List
        var contacts = Contacts()
        contacts.getContacts { (contacts) -> Void in
            for contact in contacts {
                self.friends.contacts.append(contact.name)
            }
        }
        
        // Activate Keyboard
        self.textEditor.becomeFirstResponder()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Configure Status Bar
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        
        // Register for keyboard notifications
        var notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector("keyboardDidShow:"), name:UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector("keyboardDidHide:"), name:UIKeyboardDidHideNotification, object: nil)
        
        // Configure Navigation Bar
        self.navigationItem.title = "0/75"
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 22)
        ]
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([
            NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 20)
            ], forState: UIControlState.Normal)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Unregister for keyboard notifications
        var notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name:UIKeyboardDidShowNotification, object: nil)
        notificationCenter.removeObserver(self, name:UIKeyboardDidHideNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Stop Getting Current Location
        self.location.stopUpdating()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let viewController = segue.destinationViewController as CaptureBViewController
        viewController.postController = self
    }
    
    // MARK: IBActions
    @IBAction func takePicture(sender: UIBarButtonItem) {
        var actionSheet: UIActionSheet!
        
        if self.capturedImage == nil {
            actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil,
                destructiveButtonTitle: nil, otherButtonTitles: "Take Photo", "Camera Library", "Cancel")
            
            actionSheet.cancelButtonIndex = 2
        } else {
            actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil,
                destructiveButtonTitle: nil, otherButtonTitles: "Clear Photo", "Take Photo", "Camera Library", "Cancel")
            
            actionSheet.destructiveButtonIndex = 0
            actionSheet.cancelButtonIndex = 3
        }
        
        actionSheet.actionSheetStyle = UIActionSheetStyle.Automatic
        actionSheet.showInView(self.view)
    }
    
    @IBAction func leftSwipe(gesture: UISwipeGestureRecognizer) {
        if self.capturedImage == nil {
            // Track Event
            Track.event("Post B Controller: Color Swipe")
            
            // Change Background
            self.background = self.background - 1
            
            if self.background < 0 {
                self.background = self.backgrounds.count - 1
            }
            
            self.updateStyle()
        }
    }
    
    @IBAction func rightSwipe(gesture: UISwipeGestureRecognizer) {
        if self.capturedImage == nil {
            // Track Event
            Track.event("Post B Controller: Color Swipe")
            
            // Change Background
            self.background = self.background + 1
            
            if self.background == self.backgrounds.count {
                self.background = 0
            }
            
            self.updateStyle()
        }
    }
    
    @IBAction func canelPost(sender: UIBarButtonItem) {
        // Track Event
        Track.event("Post B Controller: Canceled")
        
        // Pop to Parent View Controller
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    @IBAction func createPost(sender: UIBarButtonItem) {
        let editorText: NSString = self.textEditor.text
        
        if editorText.length != 0 {
            let response = self.friends.friendsMessage(editorText)
            var background: UIColor!
            var imageResized: UIImage!
            
            if self.capturedImage != nil {
                let imageSize = CGSize(width: self.capturedImage.size.width/2, height: self.capturedImage.size.width/2)
                imageResized = RBResizeImage(self.capturedImage, imageSize)
            } else if self.background != nil {
                background = self.backgrounds[self.background]
            }
            
            self.navigationController?.popViewControllerAnimated(false)
            Post.create(response.content, aboutUsers: response.aboutUsers,
                image: imageResized, background: background, creator: self.user, location: self.cityLocation)
            
            // Track Event
            Track.event("Post B Controller: Post Created", data: [
                "people": response.friends.count.description,
                "users": response.aboutUsers.count.description,
                "location": (self.cityLocation != nil).description
            ])
        }
    }
    
    // MARK: Instance Methods
    func updateStyle() {
        UIView.animateWithDuration(self.duration, delay: self.delay, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            if self.capturedImage != nil {
                self.previewImageView.image = self.capturedImage
                self.previewImageView.alpha = 1
            } else if self.background != nil {
                self.view.backgroundColor = self.backgrounds[self.background]
                self.previewImageView.alpha = 0
                self.previewImageView.image = nil
            }
        }, completion: nil)
    }
    
    // MARK: UIActionSheetDelegate Methods
    func actionSheet(actionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int) {
        var index = buttonIndex
        
        if self.capturedImage == nil {
            index = index + 1
        }
        
        switch index {
        case 0:
            self.capturedImage = nil
            self.updateStyle()
        
        case 1:
            self.sourceType = .Camera
            self.performSegueWithIdentifier("captureSegue", sender: self)
       
        case 2:
            var imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imagePicker.mediaTypes = ["public.image"]
            self.presentViewController(imagePicker, animated: false, completion: nil)
        default:
            break
        }
    }
    
    // MARK: NSNotificationCenter
    func keyboardDidShow(notification: NSNotification) {
        let userInfo = NSDictionary(dictionary: notification.userInfo!)
        let rect = (userInfo.objectForKey(UIKeyboardFrameEndUserInfoKey) as NSValue).CGRectValue()
        let height = self.toolbar.frame.height
        let toolbarY = self.view.frame.size.height - rect.size.height - height - 10
        
        UIView.animateWithDuration(self.duration, delay: self.delay, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.toolbar.alpha = 1
            self.toolbar.frame = CGRectMake(0, toolbarY, self.view.frame.width, height)
        }, completion: nil)
    }
    
    func keyboardDidHide() {
        let height = self.toolbar.frame.height
        let toolbarY = self.view.frame.height - height
        
        UIView.animateWithDuration(self.duration, delay: self.delay, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.toolbar.alpha = 1
            self.toolbar.frame = CGRectMake(0, toolbarY, self.view.frame.width, height)
        }, completion: nil)
    }
    
    // MARK: LocationDelegate Methods
    func locationFound(location: CLPlacemark) {
        self.cityLocation = location.locality
    }
    
    // MARK: ImagePicker Methods
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(false, completion: { () -> Void in
            self.capturedImage = image
            self.updateStyle()
        })
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    // MARK: UITextView Methods
    func textView(textView: UITextView!, shouldChangeTextInRange range: NSRange, replacementText text: String!) -> Bool {
        return textView.text.utf16Count + (text.utf16Count - range.length) <= 75;
    }
    
    func textViewDidChange(textView: UITextView!) {
        var textColor = UIColor.whiteColor()
        var mutalableText = NSMutableAttributedString(attributedString: textView.attributedText)
        let friends = self.friends.friendsInMessage(textView.text)
        
        mutalableText.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSMakeRange(0, mutalableText.length))
        
        for friend in friends {
            mutalableText.addAttribute(NSForegroundColorAttributeName, value: UIColor(red:0.31, green:0.95, blue:1, alpha:1), range: friend.range)
        }
        
        if mutalableText.length >= 65 {
            textColor = UIColor(red:0.95, green:0.24, blue:0.31, alpha:1)
        } else if mutalableText.length >= 55 {
            textColor = UIColor(red:1, green:0.6, blue:0, alpha:1)
        }
        
        textView.attributedText = mutalableText
        self.navigationItem.title = "\(mutalableText.length)/75"
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: textColor,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 22)
        ]
    }
}
