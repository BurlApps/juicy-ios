//
//  CardView.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/9/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

import UIKit

@objc protocol CardViewDelegate : class {
    optional func cardWillLeaveScreen(card: CardView)
    optional func cardDidLeaveScreen(card: CardView)
    optional func cardWillReturnToCenter(card: CardView)
    optional func cardDidReturnToCenter(card: CardView)
    optional func cardMovingAroundScreen(card: CardView, delta: CGFloat)
}

class CardView: UIView {
    
    // MARK: Instance Variables
    var delegate: CardViewDelegate?
    private enum cardViewLocation {
        case TopLeft, TopRight, BottomLeft, BottomRight
    }
    
    // MARK: Default Settings
    private struct Defaults {
        let swipeDistance: CGFloat = 80
        let border: CGFloat = 3
        let radius: CGFloat = 4
        let rotation: CGFloat = 10
        let duration: NSTimeInterval = 0.2
        let delay: NSTimeInterval = 0
    }
    
    // MARK: Instance Views
    private var container: UIView!
    private var choiceLabel: UILabel!
    
    // MARK: Instance Attributes
    var post: Post!
    private let defaults = Defaults()
    private var neededSwipeDistance: CGFloat!
    private var isOffScreen: Bool!
    private var rotationAngle: CGFloat!
    private var startPointInSuperview: CGPoint!
    
    // MARK: Instance Gestures
    private var panGesture: UIPanGestureRecognizer!
    
    // MARK: Convenience Init Method
    convenience init(frame: CGRect, post: Post, transform: CGFloat) {
        self.init(frame: frame)
        
        // Instance Variables
        self.post = post
        self.transform = CGAffineTransformMakeRotation(transform)
        
        // Setup Methods
        self.setupViews()
        self.setupAttributes()
        self.setupGestures()
    }
    
    // MARK: CardView Methods
    private func setupViews() {
        // Layer Modifications
        self.layer.backgroundColor = UIColor.whiteColor().CGColor
        self.layer.shouldRasterize = true
        self.layer.borderColor = UIColor(white: 0, alpha: 0.125).CGColor
        self.layer.borderWidth = self.defaults.border
        self.layer.cornerRadius = self.defaults.radius
        self.clipsToBounds = true
        
        // Add Container (Everything Goes In The Container)
        self.container = UIView(frame: CGRectMake(self.defaults.border, self.defaults.border,
                                                  self.bounds.width - (self.defaults.border*2),
                                                  self.bounds.height - (self.defaults.border*2)))
        self.container.backgroundColor = UIColor.whiteColor()
        self.layer.cornerRadius = self.defaults.radius
        self.container.clipsToBounds = true
        self.addSubview(self.container)
        
        // Add Label SubView
        self.choiceLabel = UILabel(frame: self.container.frame)
        self.choiceLabel.textAlignment = NSTextAlignment.Center
        self.choiceLabel.alpha = 0
        self.container.addSubview(self.choiceLabel)
    }
    
    private func setupAttributes() {
        self.isOffScreen = false
        self.neededSwipeDistance = self.defaults.swipeDistance;
        self.userInteractionEnabled = true;
        self.rotationAngle = self.defaults.rotation
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
            
            // TODO: Show the label
            let delta = self.startPointInSuperview.x - newLocation.x;
            var percentage = abs(delta/self.neededSwipeDistance)
            percentage = (percentage > 1 ? 1 : percentage)
            
            self.choiceLabel.text = (delta < 0 ? "Like" : "Nope")
            self.choiceLabel.alpha = percentage
            
            self.delegate?.cardMovingAroundScreen!(self, delta: percentage)
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
                self.delegate?.cardWillReturnToCenter?(self)
                self.returnCardViewToStartPointAnimated(true)
            } else {
                self.delegate?.cardWillLeaveScreen?(self)
                
                // Animate off screen
                UIView.animateWithDuration(self.defaults.duration, delay: self.defaults.delay, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                    var  offscreenX: CGFloat!
                    let superviewOrigin = self.superview?.frame.origin
                    let superviewOriginX = superviewOrigin?.x
                    let superviewSize = self.superview?.frame.size
                    let superViewWidth = superviewSize?.width
                    
                    if swipeDistance > 0 {
                        offscreenX = -superviewOriginX! - self.bounds.size.width
                    } else {
                        offscreenX = superViewWidth! + self.bounds.size.width
                    }
                    
                    gesture.view.layer.position = CGPointMake(offscreenX, gesture.view.layer.position.y)
                }, completion: { _ in
                    self.removeFromSuperview()
                    self.delegate?.cardDidLeaveScreen?(self)
                })
            }
        }
    }
    
    // MARK: Public Methods
    func loadBackground() {
        // Add Background SubView
        var background = self.post.getBackground()
        background.frame = self.container.bounds
        background.contentMode = UIViewContentMode.ScaleAspectFill
        self.container.insertSubview(background, atIndex: 0)
    }
    
    func returnCardViewToStartPointAnimated(animated: Bool) {
        if animated {
            UIView.animateWithDuration(self.defaults.duration, delay: self.defaults.delay, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.transform = CGAffineTransformIdentity
                self.layer.position = self.startPointInSuperview
                self.choiceLabel.alpha = 0
            }, completion: { _ in self.delegate?.cardDidReturnToCenter?(self); return () })
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
