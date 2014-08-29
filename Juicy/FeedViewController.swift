//
//  FeedViewController.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/4/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

class FeedViewController: UIViewController, CardViewDelegate {
    
    // MARK: IBOutlets
    @IBOutlet weak var createButton: UIButton!
    
    // MARK: Default Settings
    private struct Defaults {
        let cardsShown: Int = 4
        let rotation: Double = 6
        let duration: NSTimeInterval = 0.2
        let delay: NSTimeInterval = 0
        let createButton: UIColor = UIColor(red:0.96, green:0.31, blue:0.16, alpha:0.95)
        let createButtonDown: UIColor = UIColor(red:0.85, green:0.27, blue:0.14, alpha:0.95)
        let createButtonShare: UIColor = UIColor(red:0.27, green:0.64, blue:0.85, alpha: 0.95)
        let createButtonLike: UIColor = UIColor(red:0.43, green:0.69, blue:0.21, alpha: 0.95)
        let createButtonNope: UIColor = UIColor(red:0.93, green:0.19, blue:0.25, alpha: 0.95)
    }
    
    // MARK: Instance Variables
    private let defaults = Defaults()
    private var currentUser = User.current()
    private var posts: [Post] = []
    private var cards: [CardView!] = []
    private var sharePost: Post!
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup View
        self.view.backgroundColor = UIColor(red: 0.99, green: 0.99, blue: 1, alpha: 1)
        
        // Setup Create Button
        self.createButton.backgroundColor = self.defaults.createButton
        
        // Add Create Button Top Border
        var buttonBorder = UIView(frame: CGRectMake(0, 0, self.createButton.frame.size.width, 3))
        buttonBorder.backgroundColor = UIColor(white: 0, alpha: 0.05)
        self.createButton.addSubview(buttonBorder)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // Configure Status Bar
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: false)
        
        // Create Text Shadow
        var shadow = NSShadow()
        shadow.shadowColor = UIColor(red:0.94, green:0.94, blue:0.94, alpha:1)
        shadow.shadowOffset = CGSizeMake(0, 2);
        
        // Configure Navigation Bar
        self.navigationController.navigationBarHidden = false
        self.navigationController.navigationBar.shadowImage = nil
        self.navigationController.navigationBar.translucent = false
        self.navigationController.navigationBar.backgroundColor = UIColor.whiteColor()
        self.navigationController.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
        self.navigationController.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor(red:0.96, green:0.33, blue:0.24, alpha:1),
            NSFontAttributeName: UIFont(name: "Balcony Angels", size: 32),
            NSShadowAttributeName: shadow
        ]
        
        // Setup Cards
        if self.cards.isEmpty || self.posts.isEmpty {
            self.seedCards()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "shareSegue" {
            let viewController:ShareViewController = segue.destinationViewController as ShareViewController
            viewController.aboutPost = self.sharePost
        }
    }
    
    // MARK: IBActions
    @IBAction func logoutUser(sender: UIBarButtonItem) {
        User.logout()
        self.navigationController.popToRootViewControllerAnimated(false)
    }
    
    @IBAction func createPostDown(sender: UIButton) {
        sender.backgroundColor = self.defaults.createButtonDown
    }
    
    
    @IBAction func createPostExit(sender: UIButton) {
        sender.backgroundColor = self.defaults.createButton
    }
    
    @IBAction func createPost(sender: UIButton) {
        sender.backgroundColor = self.defaults.createButton
    }
    
    // MARK: Instance Methods
    func degreeToRadian(degree: Double) -> CGFloat {
        let result = degree * M_PI / 180
        return CGFloat(Float(result))
    }
    
    func seedCards() {
        Post.find(self.currentUser, withRelations: false, skip: self.cards.count, callback: { (posts: [Post]) -> Void in
            if !posts.isEmpty && self.isViewLoaded() && self.view.window != nil {
                self.posts = posts
                let max = (posts.count < 4 ? posts.count : (self.defaults.cardsShown - 1))
                
                for index in 0...max {
                    self.initCard(index != 0, seeding: true)
                }
            }
        })
    }
    
    func initCard(transform: Bool, seeding: Bool) -> CardView! {
        if self.posts.isEmpty {
            return nil
        } else if !seeding {
            self.cards.removeAtIndex(0)
        }
        
        var card = self.createCard(self.posts[0], transform: transform)
        self.posts.removeAtIndex(0)
        
        if self.cards.isEmpty {
            self.view.addSubview(card)
        } else {
            self.view.insertSubview(card, belowSubview: self.cards.last!)
        }
        
        self.cards.append(card)
        self.cards.first?.locked = false
        return card
    }
    
    func createCard(post: Post, transform: Bool) -> CardView {
        var rotation: CGFloat = 0
        var frame = UIScreen.mainScreen().bounds
        let navFrame = self.navigationController.navigationBar.frame
        
        frame.size.width -= (CGFloat(self.defaults.rotation) * 4) + 15
        frame.size.height -= navFrame.origin.y + navFrame.size.height + self.createButton.layer.frame.height + 120
        frame.origin.x = self.view.center.x - (frame.size.width/2)
        frame.origin.y += navFrame.size.height - navFrame.origin.y
        
        if transform {
            if self.cards.count == 1 {
                rotation = self.degreeToRadian(self.defaults.rotation/2)
            } else {
                rotation = self.degreeToRadian(self.defaults.rotation)
            }
        }
        
        var card = CardView(frame: frame, post: post, transform: rotation)
        card.delegate = self
        return card
    }
    
    // MARK: CardViewDelegate Methods
    func cardDidLeaveScreen(card: CardView) {
        // Seed New Cards
        if !self.posts.isEmpty {
            self.initCard(true, seeding: false)
        } else {
            self.cards[0] = nil
            self.cards.removeAtIndex(0)
            self.seedCards()
        }
        
        // Set Status Of Card
        switch card.status {
        case .Liked:
            card.post.like(self.currentUser)
        case .Noped:
            card.post.nope(self.currentUser)
        case .Shared:
            self.sharePost = card.post
            self.performSegueWithIdentifier("shareSegue", sender: self)
        case .None:
            break
        }
        
        // Reset Create Button
        self.createButton.backgroundColor = self.defaults.createButton
        self.createButton.setTitle("What's Juicy?", forState: UIControlState.Normal)
    }
    
    func cardWillReturnToCenter(card: CardView) {
        UIView.animateWithDuration(self.defaults.duration, delay: self.defaults.delay, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            // 2nd Card
            if self.cards.count > 1 {
                let firstRotation = self.degreeToRadian(self.defaults.rotation)/2
                self.cards[1].transform = CGAffineTransformMakeRotation(firstRotation)
            }

            // 3rd Card
            if self.cards.count > 2 {
                let secondRotation = self.degreeToRadian(self.defaults.rotation)
                self.cards[2].transform = CGAffineTransformMakeRotation(secondRotation)
            }
        }, completion: nil)
        
        // Reset Create Button
        if card == self.cards.first {
            self.createButton.backgroundColor = self.defaults.createButton
            self.createButton.setTitle("What's Juicy?", forState: UIControlState.Normal)
        }
    }
    
    func cardMovingAroundScreen(card: CardView, delta: CGFloat) {
        // Unlock First Card
        self.cards.first?.locked = false
        
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
        
        // Set State For Button
        if card == self.cards.first {
            var title: String!
            var color: UIColor!
            
            switch card.status {
            case .Liked:
                title = "Like the Drop"
                color = self.defaults.createButtonLike
            case .Noped:
                title = "Nope the Drop"
                color = self.defaults.createButtonNope
            case .Shared:
                title = "Share the Drop"
                color = self.defaults.createButtonShare
            case .None:
                title = "What's Juicy?"
                color = self.defaults.createButton
            }
            
            self.createButton.backgroundColor = color
            self.createButton.setTitle(title, forState: UIControlState.Normal)
        }
    }
}
