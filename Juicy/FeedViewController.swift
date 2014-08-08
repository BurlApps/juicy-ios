//
//  FeedViewController.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/4/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

class FeedViewController: UIViewController, MDCSwipeToChooseDelegate {
    
    // MARK: IBOutlets
    @IBOutlet weak var createButton: UIButton!
    
    // MARK: Class Variables
    var frontCardView: MDCSwipeToChooseView!
    var backCardView: MDCSwipeToChooseView!
    var currentCard: MDCSwipeToChooseView!
    var cards = [1, 2, 3]
    
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
            NSFontAttributeName: UIFont(name: "Balcony Angels", size: 38),
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
        
        // Add Front Card
        self.frontCardView = self.popPersonViewWithFrame(self.frontCardViewFrame())
        self.view.addSubview(self.frontCardView)
        
        // Add Back Card
        self.backCardView = self.popPersonViewWithFrame(self.backCardViewFrame())
        self.view.insertSubview(self.backCardView, belowSubview:self.frontCardView)
    }
    
    // MARK: MDCSwipeToChooseDelegate Protocol Methods
    func viewDidCancelSwipe(view: UIView!) {
        print("Card: \(self.currentCard) was cancelled")
    }
    
    func view(view: UIView!, wasChosenWithDirection direction: MDCSwipeDirection) {
        // MDCSwipeToChooseView shows "NOPE" on swipes to the left,
        // and "LIKED" on swipes to the right.
        if (direction == MDCSwipeDirection.Left) {
            print("You noped \(self.currentCard)")
        } else {
            print("You liked \(self.currentCard)")
        }
        
        // MDCSwipeToChooseView removes the view from the view hierarchy
        // after it is swiped (this behavior can be customized via the
        // MDCSwipeOptions class). Since the front card view is gone, we
        // move the back card to the front, and create a new back card.
//        self.frontCardView = self.backCardView;
//        if self.backCardView == self.popPersonViewWithFrame(self.backCardViewFrame()) {
//            self.backCardView.alpha = 0
//            
//        }
//        
//        
//        if ((self.backCardView = [self popPersonViewWithFrame:[self backCardViewFrame]])) {
//            // Fade the back card into view.
//            self.backCardView.alpha = 0.f;
//            [self.view insertSubview:self.backCardView belowSubview:self.frontCardView];
//            [UIView animateWithDuration:0.5
//                delay:0.0
//                options:UIViewAnimationOptionCurveEaseInOut
//                animations:^{
//                self.backCardView.alpha = 1.f;
//                } completion:nil];
//        }
    }
    
    // MARK: Internal Methods
    func setFrontCardView(frontCardView: MDCSwipeToChooseView!) {
        self.currentCard = frontCardView
    }
    
    func popPersonViewWithFrame(frame: CGRect) -> MDCSwipeToChooseView {
        // UIView+MDCSwipeToChoose and MDCSwipeToChooseView are heavily customizable.
        // Each take an "options" argument. Here, we specify the view controller as
        // a delegate, and provide a custom callback that moves the back card view
        // based on how far the user has panned the front card view.
        var options = MDCSwipeToChooseViewOptions()
        options.delegate = self
        options.threshold = 160
        options.onPan = { (state: MDCPanState!) in
            var frame: CGRect = self.backCardViewFrame()
            self.backCardView.frame = CGRectMake(frame.origin.x,
                                                 frame.origin.y - (state.thresholdRatio * 10),
                                                 CGRectGetWidth(frame),
                                                 CGRectGetHeight(frame));
        }
        
        let card = MDCSwipeToChooseView(frame: frame, options: options)
        self.cards.removeAtIndex(0)
        return card
    }
    
    // MARK: View Construction
    func frontCardViewFrame() -> CGRect {
        let horizontalPadding: CGFloat = 20.0
        let topPadding: CGFloat = 60.0
        let bottomPadding: CGFloat = 200.0
        return CGRectMake(horizontalPadding,
            topPadding,
            CGRectGetWidth(self.view.frame) - (horizontalPadding * 2),
            CGRectGetHeight(self.view.frame) - bottomPadding);
    }
    
    func backCardViewFrame() -> CGRect {
        let frontFrame: CGRect = self.frontCardViewFrame()
        return CGRectMake(frontFrame.origin.x,
            frontFrame.origin.y + 10.0 as CGFloat,
            CGRectGetWidth(frontFrame),
            CGRectGetHeight(frontFrame));
    }
    
    // MARK: Control Events
//    func nopeFrontCardView() {
//        self.frontCardView(mdc_swipe: MDCSwipeDirection.Left)
//    }
//    
//    func likeFrontCardView() {
//        self.frontCardView(mdc_swipe: MDCSwipeDirection.Right)
//    }
    
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
}
