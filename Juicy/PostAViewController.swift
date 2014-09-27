//
//  PostViewController.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/16/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

class PostAViewController: UIViewController, UITextViewDelegate, LocationDelegate {
    
    // MARK: Instance Variables
    var capturedImage: UIImage!
    private var cityLocation: String!
    private var textEditor: CHTTextView!
    private var previewImageView: UIImageView!
    private var user: User = User.current()
    private var location: Location!
    private var friends: Friends!
    
    struct Friend {
        var user: User!
        var range: NSRange!
    }
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Track Event
        Track.event("Post A Controller: Viewed")
        
        // Set Preview Image
        self.previewImageView = UIImageView(frame: self.view.frame)
        self.previewImageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.previewImageView.image = RBResizeImage(self.capturedImage, self.view.frame.size)
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
        
        // Create Location Manager
        self.location = Location()
        self.location.delegate = self
        
        // Create Friends Manager
        self.friends = Friends()
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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Configure Navigation Bar
        self.navigationItem.title = "0/75"
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 22)
        ]
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([
            NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 20)
        ], forState: UIControlState.Normal)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Stop Getting Current Location
        self.location.stopUpdating()
    }
    
    // MARK: IBActions
    @IBAction func canelPost(sender: UIBarButtonItem) {
        // Track Event
        Track.event("Post A Controller: Canceled")
        
        // Pop to Parent View Controller
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    @IBAction func createPost(sender: UIBarButtonItem) {
        let editorText: NSString = self.textEditor.text
        let imageSize = CGSize(width: self.capturedImage.size.width/2, height: self.capturedImage.size.width/2)
        
        if editorText.length != 0 {
            let response = self.friends.friendsMessage(editorText)
            let count = self.navigationController?.viewControllers.count
            let toController = self.navigationController?.viewControllers[count! - 3] as UIViewController
            
            self.navigationController?.popToViewController(toController, animated: false)
            Post.create(response.content, aboutUsers: response.aboutUsers, image: RBResizeImage(self.capturedImage, imageSize),
                background: nil, creator: self.user, location: self.cityLocation)
            
            // Track Event
            Track.event("Post A Controller: Post Created", data: [
                "people": response.friends.count.description,
                "users": response.aboutUsers.count.description,
                "location": (self.cityLocation != nil).description
            ])
        }
    }
    
    // MARK: LocationDelegate Methods
    func locationFound(location: CLPlacemark) {
        self.cityLocation = location.locality
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
