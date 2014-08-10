//
//  CardView.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/9/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

import UIKit

@objc protocol CardViewDelegate {
    optional func cardWillLeaveScreen(card: CardView)
    optional func cardDidLeaveScreen(card: CardView)
    optional func cardWillReturnToCenter(card: CardView)
}

class CardView: UIView {
    
    // MARK: Instance Variables
    var delegate: CardViewDelegate?
    private enum cardViewLocation {
        case TopLeft, TopRight, BottomLeft, BottomRight
    }
    
    // MARK: Instance Views
    private var font: UIFont!
    private var choiceLabel: UILabel!
    
    // MARK: Instance Attributes
    var post: Post!
    private var stackIndex: Int!
    private var neededSwipeDistance: CGFloat!
    private var isOffScreen: Bool!
    private var rotationAngle: CGFloat!
    private var startPointInSuperview: CGPoint!
    
    // MARK: Instance Gestures
    private var panGesture: UIPanGestureRecognizer!
    
    // MARK: Default Settings
    private var defaultSwipeDistance: CGFloat = 80
    private var defaultBorderWidth: CGFloat = 5
    private var defaultRotationAngle: CGFloat = 10
    private var defaultDuration: NSTimeInterval = 0.4
    private var defaultDelay: NSTimeInterval = 0
    
    // MARK: Override UIView Methods
    convenience init(frame: CGRect, post: Int) {
        self.init(frame:frame)
        //self.post = post
        self.setupViews()
        self.setupAttributes()
        self.setupGestures()
    }
    
    // MARK: CardView Methods
    private func setupViews() {
        // Layer Modifications
        self.layer.backgroundColor = UIColor.whiteColor().CGColor
        self.layer.shouldRasterize = true
        self.layer.borderColor = UIColor(white: 0, alpha: 0.10).CGColor
        self.layer.borderWidth = self.defaultBorderWidth
        
        // Add Background SubView
//        let backgroundURL =  NSURL(string: self.post.image, relativeToURL: nil)
//        let backgroundData = NSData(contentsOfURL: backgroundURL)
//        let backgroundImage = UIImage(data: backgroundData)
//        self.addSubview(UIImageView(image: backgroundImage))
        
        // Add Label
        self.choiceLabel = UILabel(frame:CGRectMake(0, 0, 200, 200));
        self.choiceLabel.alpha = 0;
        self.choiceLabel.textAlignment = NSTextAlignment.Center;
        self.addSubview(self.choiceLabel)
    }
    
    private func setupAttributes() {
        self.isOffScreen = false
        self.neededSwipeDistance = self.defaultSwipeDistance;
        self.userInteractionEnabled = true;
        self.rotationAngle = self.defaultRotationAngle;
    }
    
    private func setupGestures() {
        self.panGesture = UIPanGestureRecognizer(target: self, action: Selector("panHandle:"))
        self.addGestureRecognizer(self.panGesture)
    }
    
    // MARK: Gesture Handlers
    @IBAction func panHandle(gesture: UIPanGestureRecognizer) {
        let newLocation = gesture.locationInView(self.superview)
        
        if gesture.state == UIGestureRecognizerState.Began {
            self.startPointInSuperview = newLocation;
            let anchor = gesture.locationInView(gesture.view)
            self.setAnchorPoint(CGPointMake(anchor.x/gesture.view.bounds.size.width, anchor.y/gesture.view.bounds.size.height), view: gesture.view)
        } else if gesture.state == UIGestureRecognizerState.Changed {
            // Move the card
            gesture.view.layer.position = newLocation
            
            // Calculate rotation
            var rotation = self.rotationAngle * (-newLocation.x/self.startPointInSuperview.x+1)
            rotation = (rotation > 0 ? min(rotation, self.rotationAngle) : max(rotation, -self.rotationAngle));
            
            if gesture.view.layer.anchorPoint.y < 0.5 {
                rotation = -rotation;
            }
            
            gesture.view.transform = CGAffineTransformMakeRotation(self.degreeToRadian(rotation));
            
            // Show the label
            let delta = self.startPointInSuperview.x - newLocation.x;
            if delta < 0 {
                self.choiceLabel.text = "LIKE";
                self.choiceLabel.alpha = (-delta/self.neededSwipeDistance > 1 ? 1 : -delta/self.neededSwipeDistance);
            } else {
                self.choiceLabel.text = "NOPE";
                self.choiceLabel.alpha = (delta/self.neededSwipeDistance > 1 ? 1 : delta/self.neededSwipeDistance);
            }
        } else if gesture.state == UIGestureRecognizerState.Ended {
            var cardViewLocation = self.getCardViewLocationInSuperView(newLocation)
            
            let velocity: CGPoint = gesture.velocityInView(self.superview)
            let magnitude: CGFloat = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
            let slideMult: CGFloat = magnitude / 200
            let slideFactor: CGFloat = 0.0025 * slideMult; // Increase for more of a slide
            let finalPoint: CGPoint = CGPointMake(gesture.view.layer.position.x + (velocity.x * slideFactor),
                gesture.view.layer.position.y + (velocity.y * slideFactor));
            
            // Calculate final change in x-position that was made
            let swipeDistance: Int = Int(self.startPointInSuperview.x - newLocation.x)
            let absSwipeDistance: CGFloat = CGFloat(labs(swipeDistance))
            
            if absSwipeDistance < self.neededSwipeDistance {
                self.returnCardViewToStartPointAnimated(true)
            } else {
                self.delegate?.cardWillLeaveScreen!(self)
                
                // Animate off screen
                UIView.animateWithDuration(self.defaultDuration, delay: self.defaultDelay, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                    var  offscreenX: CGFloat!
                    let superviewOrigin = self.superview?.frame.origin
                    let superviewOriginX = superviewOrigin?.x
                    let superviewSize = self.superview?.frame.size
                    let superViewWidth = superviewSize?.width
                    
                    if swipeDistance > 0 {
                        offscreenX = -superviewOriginX! - self.bounds.size.width
                    } else {
                        offscreenX = superViewWidth!+self.bounds.size.width
                    }
                    
                    gesture.view.layer.position = CGPointMake(offscreenX, gesture.view.layer.position.y)
                }, completion: { _ in self.delegate?.cardDidLeaveScreen!(self); return () })
            }
        }
    }
    
    // MARK: Public Methods
    func returnCardViewToStartPointAnimated(animated: Bool) {
        if animated {
            UIView.animateWithDuration(self.defaultDuration, delay: self.defaultDelay, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.transform = CGAffineTransformIdentity
                self.layer.position = self.startPointInSuperview
                self.choiceLabel.alpha = 0
            }, completion: { _ in self.delegate?.cardWillReturnToCenter!(self); return () })
        } else {
            self.transform = CGAffineTransformIdentity
            self.layer.position = self.startPointInSuperview
            self.choiceLabel.alpha = 0
        }
    }
    
    // MARK: Helper Methods
    private func setAnchorPoint(anchorPoint: CGPoint, view: UIView) {
        var newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x, view.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x, view.bounds.size.height * view.layer.anchorPoint.y)
        
        newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
        oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
        
        var position = view.layer.position;
        
        position.x -= oldPoint.x;
        position.x += newPoint.x;
        
        position.y -= oldPoint.y;
        position.y += newPoint.y;
        
        view.layer.position = position;
        view.layer.anchorPoint = anchorPoint;
    }
    
    private func degreeToRadian(degree: CGFloat) -> CGFloat {
        return degree * CGFloat(M_PI) / 180
    }
    
    private func applyRotationToView(rotationView: UIView, angle: CGFloat) {
        rotationView.transform = CGAffineTransformRotate(rotationView.transform, angle)
    }
    
    private func getCardViewLocationInSuperView(currentLocation: CGPoint) -> cardViewLocation {
        var result: cardViewLocation!
        let superviewSize = self.superview?.frame.size
        let superViewWidth = superviewSize?.width
        let superViewHeight = superviewSize?.height
        let middleX = superViewWidth!/2
        let middleY = superViewHeight!/2
        
        if currentLocation.x < middleX {
            if currentLocation.y < middleY {
                result = cardViewLocation.TopLeft
            } else {
                result = cardViewLocation.BottomLeft
            }
        } else {
            if currentLocation.y < middleY {
                result = cardViewLocation.TopRight
            } else {
                result = cardViewLocation.BottomRight
            }
        }
        
        return result
    }
}
