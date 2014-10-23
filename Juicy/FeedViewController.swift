//
//  FeedViewController.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/4/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

class FeedViewController: UIViewController, CardViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate {
    
    // MARK: IBOutlets
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var sharesLabel: UILabel!
    
    // MARK: Default Settings
    private struct Defaults {
        let cardsShown: Int = 4
        let rotation: Double = 6
        let duration: NSTimeInterval = 0.2
        let delay: NSTimeInterval = 0
        let createButton: UIColor = UIColor(red:0.27, green:0.62, blue:0.7, alpha:0.95)
        let createButtonDown: UIColor = UIColor(red:0.15, green:0.53, blue:0.62, alpha:0.95)
        let createButtonShare: UIColor = UIColor(red:0.27, green:0.64, blue:0.85, alpha: 0.95)
        let createButtonLike: UIColor = UIColor(red:0.43, green:0.69, blue:0.21, alpha: 0.95)
        let createButtonNope: UIColor = UIColor(red:0.93, green:0.19, blue:0.25, alpha: 0.95)
        let createButtonFlag: UIColor = UIColor(red:0.59, green:0.05, blue:0.04, alpha: 0.95)
    }
    
    // MARK: Instance Variables
    private let defaults = Defaults()
    private var settings: Settings!
    private var user = User.current()
    private var posts: [Post] = []
    private var cards: [CardView] = []
    private var sharePost: Post!
    private var flagPost: Post!
    private var downloading: Bool = false
    private var usedPosts: [String] = []
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Track Event
        Track.event("Feed Controller: Viewed")
        
        // Setup View
        self.view.backgroundColor = UIColor(red: 0.99, green: 0.99, blue: 1, alpha: 1)
        
        // Setup Create Button
        self.createButton.backgroundColor = self.defaults.createButton
        
        // Add Create Button Top Border
        var buttonBorder = UIView(frame: CGRectMake(0, 0, self.createButton.frame.size.width, 3))
        buttonBorder.backgroundColor = UIColor(white: 0, alpha: 0.05)
        self.createButton.addSubview(buttonBorder)
        
        // Set Card Info
        self.resetCardInfo()
        
        // Get Settings
        Settings.sharedInstance { (settings) -> Void in
            self.settings = settings
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Configure Status Bar
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        
        // Create Text Shadow
        var shadow = NSShadow()
        shadow.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.1)
        shadow.shadowOffset = CGSizeMake(0, 2);
        
        // Configure Navigation Bar
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.96, green:0.33, blue:0.24, alpha:1)
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
        
        if let font = UIFont(name: "Balcony Angels", size: 36) {
            self.navigationController?.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSFontAttributeName: font,
                NSShadowAttributeName: shadow
            ]
        }
        
        // Setup Cards
        if self.cards.isEmpty || self.posts.isEmpty {
            self.seedCards()
        } else if !self.cards.isEmpty {
            for card in self.cards {
                // Card has moved
                if card.startPointInSuperview != nil {
                    card.returnCardViewToStartPointAnimated(false)
                }
            }
            
            self.cardWillReturnToCenter(self.cards[0])
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "shareSegue" {
            let viewController:ShareViewController = segue.destinationViewController as ShareViewController
            viewController.aboutPost = self.sharePost
        }
    }
    
    // MARK: IBActions
    @IBAction func settingsButton(sender: UIBarButtonItem) {
        var actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil, otherButtonTitles: "My Posts", "Shared Posts", "Logout", "Cancel")
        actionSheet.destructiveButtonIndex = 2
        actionSheet.cancelButtonIndex = 3
        actionSheet.actionSheetStyle = UIActionSheetStyle.Automatic
        actionSheet.showInView(self.view)
    }
    
    @IBAction func createPostDown(sender: UIButton) {
        sender.backgroundColor = self.defaults.createButtonDown
    }
    
    
    @IBAction func createPostExit(sender: UIButton) {
        sender.backgroundColor = self.defaults.createButton
    }
    
    @IBAction func createPost(sender: UIButton) {
        if self.settings != nil {
            let abTester = self.settings.tester(self.user)
            sender.backgroundColor = self.defaults.createButton
            self.performSegueWithIdentifier("captureSegue\(abTester)", sender: self)
        }
    }
    
    // MARK: UIActionSheetDelegate Methods
    func actionSheet(actionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
        case 0:
            self.performSegueWithIdentifier("myPostsSeque", sender: self)
        case 1:
            self.performSegueWithIdentifier("sharedPostsSegue", sender: self)
        case 2:
            self.user.logout()
            self.navigationController?.popToRootViewControllerAnimated(false)
            
            // Track Event
            Track.event("User: Logout")
            Track.event("Camera A Controller: Logout")
        default:
            break
        }
    }
    
    // MARK: Instance Methods
    func degreeToRadian(degree: Double) -> CGFloat {
        let result = degree * M_PI / 180
        return CGFloat(Float(result))
    }
    
    func cardFrame() -> CGRect {
        var frame = UIScreen.mainScreen().bounds
        
        if let navController = self.navigationController {
            let navFrame = navController.navigationBar.frame
            
            frame.size.width -= (CGFloat(self.defaults.rotation) * 4) + 15
            frame.size.height -= navFrame.origin.y + navFrame.height + self.createButton.layer.frame.height + 120
            frame.origin.x = self.view.center.x - (frame.size.width/2)
            frame.origin.y += navFrame.size.height - navFrame.origin.y + 15
            
            if frame.size.height < frame.size.width {
                frame.origin.x += (frame.size.width - frame.size.height - 30)/2
                frame.size.width = frame.size.height + 30
            }
        }
        
        return frame
    }
    
    func seedCards() {
        if self.cards.isEmpty {
            self.resetCardInfo()
        }
        
        if self.downloading == false {
            self.downloading = true
            Post.find(self.user, withRelations: false, skip: self.cards.count, callback: { (posts: [Post]) -> Void in
                self.downloading = false
                
                if !posts.isEmpty && self.isViewLoaded() && self.view.window != nil {
                    var max: Int!
                    self.posts = posts
                    
                    if posts.count < 4 {
                        max = posts.count
                    } else {
                        max = self.defaults.cardsShown - 1
                    }
                    
                    for index in 0...max {
                        self.initCard(!self.cards.isEmpty)
                    }
                }
            })
        }
    }
    
    func initCard(transform: Bool) -> CardView! {
        if self.posts.isEmpty || self.cards.count >= self.defaults.cardsShown {
            return nil
        }

        var post = self.posts[0]
        self.posts.removeAtIndex(0)
        
        if self.usedPosts.contains(post.id) == false {
            self.usedPosts.append(post.id)
        } else {
            return self.initCard(transform)
        }
        
        var card = self.createCard(post, transform: transform)
        
        if self.cards.isEmpty {
            self.view.addSubview(card)
        } else {
            self.view.insertSubview(card, belowSubview: self.cards.last!)
        }
        
        self.cards.append(card)
        self.cardInfo()
        self.cards[0].activate()
        return card
    }
    
    func createCard(post: Post, transform: Bool) -> CardView {
        var card: CardView!
        var rotation: CGFloat = 0
        var frame = self.cardFrame()
        
        if transform {
            if self.cards.count == 1 {
                rotation = self.degreeToRadian(self.defaults.rotation/2)
            } else {
                rotation = self.degreeToRadian(self.defaults.rotation)
            }
        }
        
        card = CardView(frame: frame, post: post, transform: rotation)
        card.delegate = self
        return card
    }
    
    func cardInfo() {
        var post = self.cards[0].post
        self.likesLabel.text = post.likes.abbreviate()
        self.sharesLabel.text = post.shares.abbreviate()
        
        if post.location != nil {
            self.locationLabel.text = post.location
        } else {
            self.locationLabel.text = "Anonymous"
        }
    }
    
    func resetCardInfo() {
        self.likesLabel.text = "....."
        self.sharesLabel.text = "....."
        self.locationLabel.text = "...................."
    }
    
    // MARK: UIAlertViewDelegate Methods
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        self.flagPost.flag(self.user)
        self.flagPost = nil
    }
    
    // MARK: CardViewDelegate Methods
    func cardDidLeaveScreen(card: CardView) {
        self.cards.removeAtIndex(0)
        
        // Seed New Cards
        if self.posts.isEmpty {
            self.seedCards()
        } else {
            self.initCard(true)
        }
        
        // Set Status Of Card
        switch card.status {
        case .Liked:
            // User Like Post
            card.post.like(self.user)
            
            // Track Event
            Track.event("Feed Controller: Card Liked")
        case .Noped:
            // User Nope Post
            card.post.nope(self.user)
            
            // Track Event
            Track.event("Feed Controller: Card Noped")
        case .Shared:
            // User Share Post
            self.sharePost = card.post
            self.performSegueWithIdentifier("shareSegue", sender: self)
            
            // Track Event
            Track.event("Feed Controller: Card Shared")
        case .Flagged:
            // User Flag Post
            self.flagPost = card.post
            UIAlertView(title: "Report as Abusive", message: "Please confirm that this post is abusive and should be immediately removed from Juicy.",
                delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Report").show()
            
            // Track Event
            Track.event("Feed Controller: Card Flagged")
        case .None:
            break
        }
        
        // Reset Create Button
        self.createButton.backgroundColor = self.defaults.createButton
        self.createButton.setTitle("POST", forState: UIControlState.Normal)
    }
    
    func cardWillReturnToCenter(card: CardView) {
        // Reset Create Button
        if card == self.cards.first {
            UIView.animateWithDuration(self.defaults.duration, delay: self.defaults.delay, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                // 2nd Card
                if self.cards.count > 1 {
                    let firstRotation = self.degreeToRadian(self.defaults.rotation)/2
                    self.cards[1].transform = CGAffineTransformMakeRotation(firstRotation)
                }

                // More Cards
                if self.cards.count > 2 {
                    let secondRotation = self.degreeToRadian(self.defaults.rotation)
                    self.cards[2].transform = CGAffineTransformMakeRotation(secondRotation)
                }
            }, completion: nil)
        
            self.createButton.backgroundColor = self.defaults.createButton
            self.createButton.setTitle("POST", forState: UIControlState.Normal)
        }
    }
    
    func cardMovingAroundScreen(card: CardView, delta: CGFloat) {
        // Unlock First Card
        self.cards.first?.locked = false
        
        // Set State For Button
        if card == self.cards.first {
            // 2nd Card -> 1st Card
            if self.cards.count > 1 {
                let firstTransform = self.degreeToRadian(self.defaults.rotation)/2
                let firstRotation = firstTransform + (firstTransform * -1 * abs(delta))
                self.cards[1].transform = CGAffineTransformMakeRotation(firstRotation)
            }
            
            // 3rd Card -> 2nd Card
            if self.cards.count > 2 {
                let secondTransform = self.degreeToRadian(self.defaults.rotation)
                let secondRotation = secondTransform + (secondTransform * -1 * abs(delta))/2
                self.cards[2].transform = CGAffineTransformMakeRotation(secondRotation)
            }
        
            var title: String!
            var color: UIColor!
            
            switch card.status {
            case .Liked:
                title = "LIKE"
                color = self.defaults.createButtonLike
            case .Noped:
                title = "NOPE"
                color = self.defaults.createButtonNope
            case .Shared:
                title = "SHARE"
                color = self.defaults.createButtonShare
            case .Flagged:
                title = "REPORT"
                color = self.defaults.createButtonFlag
            case .None:
                title = "POST"
                color = self.defaults.createButton
            }
            
            self.createButton.backgroundColor = color
            self.createButton.setTitle(title, forState: UIControlState.Normal)
        }
    }
}
