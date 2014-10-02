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
    optional func cardDidReturnToCenter(card: CardView)
    optional func cardMovingAroundScreen(card: CardView, delta: CGFloat)
}

class CardView: UIView {
    
    // MARK: Class Enums
    enum Status {
        case None, Liked, Noped, Shared
    }
    
    private enum CardViewLocation {
        case TopLeft, TopRight, BottomLeft, BottomRight
    }
    
    // MARK: Default Settings
    struct Defaults {
        let swipeDistance: CGFloat = 80
        let border: CGFloat = 4
        let radius: CGFloat = 4
        let rotation: CGFloat = 10
        let duration: NSTimeInterval = 0.2
        let delay: NSTimeInterval = 0
        let regualColor = UIColor(red:1, green:1, blue:1, alpha:0.4)
        let juicyColor = UIColor(red:0.99, green:0.4, blue:0.13, alpha:0.8)
        let shareColor = UIColor(red:0.34, green:0.9, blue:0.99, alpha: 0.8).CGColor
        let likeColor = UIColor(red:0.43, green:0.69, blue:0.21, alpha: 0.8).CGColor
        let nopeColor = UIColor(red:0.93, green:0.19, blue:0.25, alpha: 0.8).CGColor
        let personColor = UIColor(red:0.31, green:0.95, blue:1, alpha:1)
    }
    
    // MARK: Instance Views
    private var background: UIImageView!
    private var choice: UIImageView!
    private var darkener: UIView!
    private var darkenerColor: UIColor!
    private var darkenerBorder: UIColor!
    private var content: UILabel!
    
    // MARK: Public Attributes
    var post: Post!
    var delegate: CardViewDelegate!
    var status: Status = .None
    var locked = true
    var startPointInSuperview: CGPoint!
    
    // MARK: Instance Attributes
    private let defaults = Defaults()
    private var neededSwipeDistance: CGFloat!
    private var hideContent: Bool!
    private var isOffScreen: Bool!
    
    // MARK: Instance Gestures
    private var tapGesture: UITapGestureRecognizer!
    private var panGesture: UIPanGestureRecognizer!
    
    // MARK: Convenience Init Method
    convenience init(frame: CGRect, post: Post!, transform: CGFloat) {
        self.init(frame: frame)
        
        // Track Event
        Track.event("Card View: Created")
        
        // Instance Variables
        self.post = post
        self.transform = CGAffineTransformMakeRotation(transform)
        
        // Setup Methods
        if self.post != nil {
            self.setupViews()
            self.setupAttributes()
            self.setupGestures()
        }
    }
    
    // MARK: CardView Methods
    private func setupViews() {
        // Layer Modifications
        self.layer.backgroundColor = UIColor.whiteColor().CGColor
        self.layer.cornerRadius = self.defaults.radius
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.mainScreen().scale
        self.clipsToBounds = true

        // Add Background SubView
        self.background = UIImageView(frame: self.bounds)
        self.background.contentMode = UIViewContentMode.ScaleAspectFill
        self.addSubview(self.background)
        
        // Load Background Image
        if self.post.image != nil {
            self.post.getImage({ (image) -> Void in
                self.background.image = image
            })
        }
        
        // Add Darkener
        self.darkener = UIView(frame: self.bounds)
        self.darkener.backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.darkener.layer.borderWidth = self.defaults.border
        self.insertSubview(self.darkener, aboveSubview: self.background)
        
        if self.post.juicy as Bool {
            self.darkenerBorder = self.defaults.juicyColor
            self.darkener.layer.borderWidth += 1
        } else {
            self.darkenerBorder = self.defaults.regualColor
        }
        
        // Add Background Color
        if self.post.background != nil {
            self.backgroundColor = self.post.background
        }
        
        self.darkenerColor = self.darkener.backgroundColor
        self.darkener.layer.borderColor = self.darkenerBorder.CGColor

        // Add Choice Image
        self.choice = UIImageView(frame: CGRectMake(75, 75, self.bounds.width - 150, self.bounds.height - 150))
        self.choice.alpha = 0
        self.choice.contentMode = UIViewContentMode.ScaleAspectFill;
        self.insertSubview(self.choice, aboveSubview: self.darkener)
        
        // Add Content
        self.content = UILabel(frame: CGRectMake(10, 10, self.bounds.width - 20, self.bounds.height - 20))
        self.content.textAlignment = NSTextAlignment.Center
        self.content.textColor = UIColor.whiteColor()
        self.content.shadowColor = UIColor(white: 0, alpha: 0.2)
        self.content.shadowOffset = CGSize(width: 0, height: 2)
        self.content.font = UIFont(name: "HelveticaNeue-Bold", size: 22)
        self.content.numberOfLines = 0
        self.content.adjustsFontSizeToFitWidth = true
        self.insertSubview(self.content, aboveSubview: self.choice)
        
        // Coloring Content With Names
        var content = NSMutableAttributedString()
        
        for block in self.post.content {
            if let message = block["message"] as? String {
                var blockAttrString = NSMutableAttributedString(string: message)
                
                if block["color"] as Bool {
                    blockAttrString.addAttribute(NSForegroundColorAttributeName,
                        value: self.defaults.personColor, range: NSMakeRange(0, blockAttrString.length))
                }
                
                content.appendAttributedString(blockAttrString)
            }
        }
        
        self.content.attributedText = content
    }
    
    private func setupAttributes() {
        self.setTranslatesAutoresizingMaskIntoConstraints(true)
        self.locked = true
        self.hideContent = false
        self.isOffScreen = false
        self.neededSwipeDistance = self.defaults.swipeDistance
        self.userInteractionEnabled = true
    }
    
    private func setupGestures() {
        self.tapGesture = UITapGestureRecognizer(target: self, action: Selector("tapHandle:"))
        self.addGestureRecognizer(self.tapGesture)
        
        self.panGesture = UIPanGestureRecognizer(target: self, action: Selector("panHandle:"))
        self.addGestureRecognizer(self.panGesture)
    }
    
    private func removeGestures() {
        self.removeGestureRecognizer(self.tapGesture)
        self.removeGestureRecognizer(self.panGesture)
    }
    
    // MARK: Gesture Handlers
    @IBAction func tapHandle(gesture: UIPanGestureRecognizer) {
        if self.locked == false && self.post.image != nil {
            // Track Event
            Track.event("Card View: Tab Gesture")
            
            // Toggle Content
            self.hideContent = !self.hideContent
            UIView.animateWithDuration(self.defaults.duration, delay: self.defaults.delay, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.content.alpha = 1 - self.content.alpha
                self.darkener.alpha = 1 - self.darkener.alpha
            }, completion: nil)
        }
    }
    
    @IBAction func panHandle(gesture: UIPanGestureRecognizer) {
        let newLocation = gesture.locationInView(self.superview)
        
        if var view = gesture.view {
            if gesture.state == UIGestureRecognizerState.Began {
                self.startPointInSuperview = newLocation;
                
                let anchor = gesture.locationInView(gesture.view)
                self.setAnchorPoint(CGPointMake(anchor.x/view.bounds.size.width, anchor.y/view.bounds.size.height), view: view)
            } else if gesture.state == UIGestureRecognizerState.Changed {
                // Move the card
                view.layer.position = newLocation
                
                // Calculate rotation
                var rotation = self.defaults.rotation * (-newLocation.x/self.startPointInSuperview.x+1)
                rotation = (rotation > 0 ? min(rotation, self.defaults.rotation) : max(rotation, -self.defaults.rotation));
                
                if view.layer.anchorPoint.y < 0.5 {
                    rotation = -rotation;
                }
                
                view.transform = CGAffineTransformMakeRotation(self.degreeToRadian(rotation));
                
                let deltaX = self.startPointInSuperview.x - newLocation.x;
                let deltaY = self.startPointInSuperview.y - newLocation.y;
                var delta  = abs(deltaX) > abs(deltaY) ? deltaX : deltaY
                var percentage = abs(delta/self.neededSwipeDistance)
                percentage = (percentage > 1 ? 1 : percentage)
                var newColor: CGColor!
                var newColorBorder = self.darkenerBorder.colorWithAlphaComponent((1 - percentage)).CGColor
            
                if delta == deltaX {
                    if delta < 0 {
                        newColor = self.defaults.likeColor
                        self.status = .Liked
                        self.choice.image = UIImage(named: "Like")
                    } else {
                        newColor = self.defaults.nopeColor
                        self.status = .Noped
                        self.choice.image = UIImage(named: "Nope")
                    }
                } else {
                    if delta < 0 {
                        newColor = self.defaults.shareColor
                        self.status = .Shared
                        self.choice.image = UIImage(named: "Share")
                    } else {
                        delta = 0
                        percentage = 0
                        newColor = self.darkenerColor.CGColor
                        self.status = .None
                        self.choice.image = UIImage()
                    }
                }
                
                if self.hideContent == false {
                    self.content.alpha = pow((1 - percentage), 4)
                } else {
                    UIView.animateWithDuration(self.defaults.duration, delay: self.defaults.delay, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                        self.darkener.alpha = 1
                    }, completion: nil)
                }
                
                self.choice.alpha = (percentage * 0.8)
                self.darkener.backgroundColor = self.mixColors(self.darkenerColor.CGColor, colorTwo: newColor, delta: percentage)
                self.darkener.layer.borderColor = self.mixColors(self.darkenerBorder.CGColor, colorTwo: newColorBorder, delta: percentage).CGColor
                self.delegate?.cardMovingAroundScreen?(self, delta: percentage)
            } else if  gesture.state == UIGestureRecognizerState.Ended {
                var cardViewLocation = self.getCardViewLocationInSuperView(newLocation)
                
                let velocity: CGPoint = gesture.velocityInView(self.superview)
                let magnitude: CGFloat = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
                let slideMult: CGFloat = magnitude / 200
                let slideFactor: CGFloat = 0.0025 * slideMult; // Increase for more of a slide
                let finalPoint: CGPoint = CGPointMake(view.layer.position.x + (velocity.x * slideFactor),
                    view.layer.position.y + (velocity.y * slideFactor));
                
                // Calculate final change in x-position that was made
                let swipeDistanceX: Int = Int(self.startPointInSuperview.x - newLocation.x)
                let swipeDistanceY: Int = Int(self.startPointInSuperview.y - newLocation.y)
                let swipeDistance: Int = abs(swipeDistanceX) > abs(swipeDistanceY) ? swipeDistanceX : swipeDistanceY
                let absSwipeDistance: CGFloat = CGFloat(labs(swipeDistance))
                
                if self.locked || absSwipeDistance < self.neededSwipeDistance || (swipeDistance == swipeDistanceY && swipeDistance > 0) {
                    self.delegate?.cardWillReturnToCenter?(self)
                    self.returnCardViewToStartPointAnimated(true)
                } else {
                    self.delegate?.cardWillLeaveScreen?(self)
                    
                    // Animate off screen
                    UIView.animateWithDuration(self.defaults.duration, delay: self.defaults.delay, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                        var offscreenX: CGFloat!
                        var offscreenY: CGFloat!
                        let superviewOrigin = self.superview?.frame.origin
                        let superviewOriginX = superviewOrigin?.x
                        let superviewOriginY = superviewOrigin?.y
                        let superviewSize = self.superview?.frame.size
                        let superViewWidth = superviewSize?.width
                        let superViewHeight = superviewSize?.height
                        
                        if swipeDistance == swipeDistanceX {
                            if swipeDistance > 0 {
                                offscreenX = -superviewOriginX! - self.bounds.size.width
                            } else {
                                offscreenX = superViewWidth! + self.bounds.size.width
                            }
                            
                            view.layer.position = CGPointMake(offscreenX, view.layer.position.y)
                        } else {
                            offscreenY = superViewHeight! + self.bounds.size.height
                            view.layer.position = CGPointMake(view.layer.position.x, offscreenY)
                        }
                    }, completion: { _ in
                        self.delegate?.cardDidLeaveScreen?(self)
                        self.removeGestures()
                        self.removeFromSuperview()
                        self.returnCardViewToStartPointAnimated(false)
                    })
                }
            }
        }
    }
    
    func returnCardViewToStartPointAnimated(animated: Bool) {
        if animated {
            UIView.animateWithDuration(self.defaults.duration, delay: self.defaults.delay, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.transform = CGAffineTransformIdentity
                self.layer.position = self.startPointInSuperview
                self.darkener.backgroundColor = self.darkenerColor
                self.darkener.layer.borderColor = self.darkenerBorder.CGColor
                self.choice.alpha = 0
                self.content.alpha = 1
            }, completion: { _ in self.delegate?.cardDidReturnToCenter?(self); return () })
        } else {
            self.transform = CGAffineTransformIdentity
            self.layer.position = self.startPointInSuperview
            self.darkener.backgroundColor = self.darkenerColor
            self.darkener.layer.borderColor = self.darkenerBorder.CGColor
            self.choice.alpha = 0
            self.content.alpha = 1
        }
        
        self.hideContent = false
    }
    
    func activate() {
        self.locked = false
        
        if self.post.juicy == true {
            self.shakeCard()
        }
    }
    
    func shakeCard() {
        var animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        animation.autoreverses = true
        animation.repeatCount = 2
        animation.duration = 0.07
        animation.values = [self.degreeToRadian(4), self.degreeToRadian(-4)]
        self.layer.addAnimation(animation, forKey: "transform.rotation.z")
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
    
    private func mixColors(colorOne: CGColor!, colorTwo: CGColor!, delta: CGFloat) -> UIColor {
        var colorOneComp = CGColorGetComponents(colorOne)
        var colorOneRed = colorOneComp[0]
        var colorOneGreen = colorOneComp[1]
        var colorOneBlue = colorOneComp[2]
        var colorOneAlpha = colorOneComp[3]
        
        var colorTwoComp = CGColorGetComponents(colorTwo)
        var colorTwoRed = colorTwoComp[0]
        var colorTwoGreen = colorTwoComp[1]
        var colorTwoBlue = colorTwoComp[2]
        var colorTwoAlpha = colorTwoComp[3]
        
        var newRed = (colorOneRed * (1 - delta)) + (colorTwoRed * delta)
        var newGreen = (colorOneGreen * (1 - delta)) + (colorTwoGreen * delta)
        var newBlue = (colorOneBlue * (1 - delta)) + (colorTwoBlue * delta)
        var newAlpha = (colorOneAlpha * (1 - delta)) + (colorTwoAlpha * delta)
        
        return UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: newAlpha)
    }
    
    private func applyRotationToView(rotationView: UIView, angle: CGFloat) {
        rotationView.transform = CGAffineTransformRotate(rotationView.transform, angle)
    }
    
    private func getCardViewLocationInSuperView(currentLocation: CGPoint) -> CardViewLocation {
        var result: CardViewLocation!
        let superviewSize = self.superview?.frame.size
        let superViewWidth = superviewSize?.width
        let superViewHeight = superviewSize?.height
        let middleX = superViewWidth!/2
        let middleY = superViewHeight!/2
        
        if currentLocation.x < middleX {
            if currentLocation.y < middleY {
                result = CardViewLocation.TopLeft
            } else {
                result = CardViewLocation.BottomLeft
            }
        } else {
            if currentLocation.y < middleY {
                result = CardViewLocation.TopRight
            } else {
                result = CardViewLocation.BottomRight
            }
        }
        
        return result
    }
}
