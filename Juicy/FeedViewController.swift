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
    
    // MARK: Instance Variables
    var posts = [1,2,3,4,5,6,7,8,9,10]
    var cards: [CardView]! = []
    
    let cardsShown = 3
    let minRotation: Double = -5
    let maxRotation: Double = 5
    
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
        self.view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 1, alpha: 1)
        
        // Setup Create Button
        self.createButton.backgroundColor = UIColor(red:0.96, green:0.31, blue:0.16, alpha:1)
        
        // Setup Cards
        self.setUpCards()
    }
    
    // MARK: Instance Methods
    func degreeToRadian(degree: Double) -> CGFloat {
        let result = degree * M_PI / 180
        return CGFloat(Float(result))
    }
    
    func setUpCards() {
        let posts = self.posts[0...(self.cardsShown-1)]
        
        for (index, post) in enumerate(posts) {
            var card = self.createCard(post, transform: index != 1)
            self.cards.insert(card, atIndex: 0)
            self.view.insertSubview(card, atIndex: 0)
        }
    }
    
    func createCard(post: Int, transform: Bool) -> CardView {
        let degrees = (drand48() * (self.maxRotation - self.minRotation + 1)) + self.minRotation
        let rotation = self.degreeToRadian(degrees)
        let frame = CGRectMake(self.view.center.x-140, self.view.center.y-140, 280, 280)
        
        var card = CardView(frame: frame, post: post)
        var label = UILabel(frame: CGRectMake(20, 20, 280, 150))
        label.text = post.description
        label.textAlignment = NSTextAlignment.Center
        card.addSubview(label)
        
        if transform {
            card.transform = CGAffineTransformMakeRotation(rotation)
        }
        
        return card
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
    
    // MARK: CardViewDelegate Methods
    func cardDidLeaveScreen(card: CardView) {
        print(123)
        
        self.cards.removeAtIndex(0)
        var card = self.createCard(self.posts[0], transform: true)
        card.alpha = 0
        
        self.cards.append(card)
        self.view.addSubview(card)
        UIView.animateWithDuration(0.4, { () -> Void in
            card.alpha = 1
        })
    }
}
