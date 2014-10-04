//
//  OboardingViewController.swift
//  Juicy
//
//  Created by Brian Vallelunga on 10/1/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

import UIKit

class OboardingViewController: UIViewController, CardViewDelegate {
    
    // MARK: Class Struct
    private struct State {
        var status: CardView.Status!
        var color: UIColor!
        var header: String!
        var subheader: String!
    }
    
    // MARK: IBOutlets
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var subheader: UILabel!
    
    // MARK: Instance Variables
    private let duration: NSTimeInterval = 0.5
    private var posts: [Post]!
    private var card: CardView!
    private var user = User.current()
    private var state: Int = 0
    private var states: [State] = [
        State(status: .Liked, color: UIColor(red:0, green:0.59, blue:0.53, alpha: 1), header: "Swipe Right", subheader: "to LIKE the post"),
        State(status: .Noped, color: UIColor(red:0.91, green:0.31, blue:0.25, alpha: 1), header: "Swipe Left", subheader: "to NOPE the post"),
        State(status: .Shared, color: UIColor(red:0.01, green:0.61, blue:0.9, alpha: 1), header: "Swipe Down", subheader: "to SHARE the post")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Track Event
        Track.event("Onboarding Controller: Viewed")
        
        // Move to Feed View if onboarded
        if self.user.onboarded == true {
            self.performSegueWithIdentifier("feedSegue", sender: self)
        }
        
        // Get 3 Posts
        Post.find(self.user, withRelations: false, skip: 0, limit: 3, callback: { (posts: [Post]) -> Void in
            if !posts.isEmpty && self.isViewLoaded() && self.view.window != nil {
                self.posts = posts
                self.createCard()
            }
        })
        
        // Hide Headers
        self.header.alpha = 0
        self.subheader.alpha = 0
        
        // Setup Onboard State
        self.configureState()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Configure Status Bar
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: false)
        
        // Configure Navigation Bar
        self.navigationController?.navigationBarHidden = true
    }
    
    // MARK: Instance Methods
    func configureState() {
        var state = self.states[self.state]
        
        UIView.animateWithDuration(self.duration, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.header.alpha = 0
            self.subheader.alpha = 0
        }, completion: { _ in
            self.header.textColor = state.color
            self.subheader.textColor = state.color
            
            self.header.text = state.header
            self.subheader.text = state.subheader
            
            UIView.animateWithDuration(self.duration, delay: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.header.alpha = 1
                self.subheader.alpha = 1
            }, completion: nil)
        })
    }
    
    func cardFrame() -> CGRect {
        var frame = UIScreen.mainScreen().bounds
        
        if let navController = self.navigationController {
            frame.size.width -= 50
            frame.size.height -= self.subheader.frame.origin.y + self.subheader.frame.height + 100
            frame.origin.x = self.view.center.x - (frame.size.width/2)
            frame.origin.y = self.subheader.frame.origin.y + self.subheader.frame.height + 50
            
            if frame.size.height < frame.size.width {
                frame.origin.x += (frame.size.width - frame.size.height - 30)/2
                frame.size.width = frame.size.height + 30
            }
        }
        
        return frame
    }
    
    func createCard() {
        let frame = self.cardFrame()
        let post = self.posts[self.state]
        
        self.card = CardView(frame: frame, post: post, transform: 0)
        self.card.delegate = self
        self.card.alpha = 0
        
        self.view.addSubview(self.card)
        
        UIView.animateWithDuration(self.duration, delay: 1, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.card.alpha = 1
        }, completion: nil)
    }
    
    func cardMovingAroundScreen(card: CardView, delta: CGFloat) {
        self.card.locked = (self.card.status != self.states[self.state].status)
    }
    
    func cardDidLeaveScreen(card: CardView) {
        self.state += 1
        
        if self.state >= self.states.count {
            self.performSegueWithIdentifier("feedSegue", sender: self)
            self.user.didOnboarding()
        } else {
            self.configureState()
            self.createCard()
        }
    }
}
