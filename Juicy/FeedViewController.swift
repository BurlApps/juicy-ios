//
//  FeedViewController.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/4/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

class FeedViewController: UIViewController, CardViewDelegate {
    
    // MARK: CardViewDelegate
    var cardViewDelegate: CardViewDelegate!
    
    // MARK: IBOutlets
    @IBOutlet weak var createButton: UIButton!
    
    // MARK: Default Settings
    private struct Defaults {
        let cardsShown: Int = 4
        let rotation: Double = 6
        let duration: NSTimeInterval = 0.2
        let delay: NSTimeInterval = 0
    }
    
    // MARK: Instance Variables
    private let defaults = Defaults()
    private var currentUser = User.current(false)
    private var posts: [Post]!
    private var postsCount = 0
    private var cards: [CardView]! = []
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create Text Shadow
        var shadow = NSShadow()
        shadow.shadowColor = UIColor(red:0.94, green:0.94, blue:0.94, alpha:1)
        shadow.shadowOffset = CGSizeMake(0, 2);
        
        // Setup Navigation Bar
        self.navigationController.navigationBarHidden = false
        self.navigationController.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor(red:0.96, green:0.33, blue:0.24, alpha:1),
            NSFontAttributeName: UIFont(name: "Balcony Angels", size: 42),
            NSShadowAttributeName: shadow
        ]
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        // Add Navigation Bottom Border
        var overlayView = UIView(frame: CGRectMake(0, self.navigationController.navigationBar.frame.height,
                                                    self.view.frame.width, 2))
        overlayView.backgroundColor = UIColor(red:0.92, green:0.89, blue:0.91, alpha:1)
        self.navigationController.navigationBar.addSubview(overlayView)
        
        // Setup View
        self.view.backgroundColor = UIColor(red: 0.99, green: 0.99, blue: 1, alpha: 1)
        
        // Setup Create Button
        self.createButton.backgroundColor = UIColor(red:0.96, green:0.31, blue:0.16, alpha:1)
        
        // Add Create Button Top Border
        var buttonBorder = UIView(frame: CGRectMake(0, 0, self.createButton.frame.size.width, 3))
        buttonBorder.backgroundColor = UIColor(white: 0, alpha: 0.05)
        self.createButton.addSubview(buttonBorder)
        
        // Setup Cards
        self.seedCards()
    }
    
    // MARK: IBActions
    @IBAction func logoutUser(sender: UIBarButtonItem) {
        PFUser.logOut()
        self.navigationController.popToRootViewControllerAnimated(false)
    }
    
    @IBAction func createPostDown(sender: UIButton) {
        sender.backgroundColor = UIColor(red:0.85, green:0.27, blue:0.14, alpha:1)
    }
    
    @IBAction func createPost(sender: UIButton) {
        sender.backgroundColor = UIColor(red:0.96, green:0.31, blue:0.16, alpha:1)
    }
    
    // MARK: Instance Methods
    func degreeToRadian(degree: Double) -> CGFloat {
        let result = degree * M_PI / 180
        return CGFloat(Float(result))
    }
    
    func seedCards() {
        Post.find(self.currentUser, withRelations: false, skip: self.postsCount, callback: { (posts: [Post]) -> Void in
            if !posts.isEmpty {
                self.posts = posts
                self.postsCount += posts.count
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
        return card
    }
    
    func createCard(post: Post, transform: Bool) -> CardView {
        let cardWidth = self.view.frame.width - (CGFloat(self.defaults.rotation) * 4) - 20
        let cardHeight = self.view.frame.height - self.navigationController.navigationBar.frame.height - self.createButton.layer.frame.height - 150
        let cardX = self.view.center.x - cardWidth/2
        let cardY = self.navigationController.navigationBar.frame.height + 45 + CGFloat(self.defaults.rotation)
        let frame = CGRectIntegral(CGRectMake(cardX, cardY, cardWidth, cardHeight))
        var rotation: CGFloat!
        
        if transform {
            if self.cards.count == 1 {
                rotation = self.degreeToRadian(self.defaults.rotation/2)
            } else {
                rotation = self.degreeToRadian(self.defaults.rotation)
            }
        } else {
            rotation = 0
        }
        
        var card = CardView(frame: frame, post: post, transform: rotation)
        card.delegate = self
        return card
    }
    
    // MARK: CardViewDelegate Methods
    func cardDidLeaveScreen(card: CardView) {        
        if !self.posts.isEmpty {
            self.initCard(true, seeding: false)
        } else {
            self.cards.removeAtIndex(0)
            self.seedCards()
        }
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
    }
    
    func cardMovingAroundScreen(card: CardView, delta: CGFloat) {
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
    }
}
