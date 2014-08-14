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
    
    // MARK: Class Enums
    enum Status {
        case None, Liked, Nope, Shared
    }
    
    private enum CardViewLocation {
        case TopLeft, TopRight, BottomLeft, BottomRight
    }
    
    // MARK: Default Settings
    private struct Defaults {
        let swipeDistance: CGFloat = 80
        let border: CGFloat = 4
        let radius: CGFloat = 4
        let rotation: CGFloat = 10
        let duration: NSTimeInterval = 0.2
        let delay: NSTimeInterval = 0
        let likeColor = UIColor(red:0.43, green:0.69, blue:0.21, alpha: 0.4).CGColor
        let nopeColor = UIColor(red:0.93, green:0.19, blue:0.25, alpha: 0.4).CGColor
    }
    
    // MARK: Instance Views
    private var background: UIImageView!
    private var darkener: UIView!
    private var darkenerColor: UIColor!
    private var darkenerBorder: UIColor!
    private var content: UILabel!
    
    // MARK: Public Attributes
    var post: Post!
    var delegate: CardViewDelegate!
    var status: Status!
    
    // MARK: Instance Attributes
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
        self.layer.cornerRadius = self.defaults.radius
        self.layer.shouldRasterize = true
        self.clipsToBounds = true
        
        // Add Background SubView
        self.background = UIImageView(frame: self.bounds)
        self.background.contentMode = UIViewContentMode.ScaleAspectFill
        self.addSubview(self.background)
        
        // Load Background Image
        self.post.getImage({ (image) -> Void in
            self.background.image = image
        })
        
        // Add Darkener
        self.darkener = UIView(frame: self.bounds)
        self.darkener.layer.borderWidth = self.defaults.border
        self.darkener.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha:0.5)
        self.insertSubview(self.darkener, aboveSubview: self.background)
        
        if self.post.juicy == true {
            self.darkenerBorder = UIColor(red:0.99, green:0.4, blue:0.13, alpha:0.7)
        } else {
            self.darkenerBorder = UIColor(red:1, green:1, blue:1, alpha:0.4)
        }
        
        self.darkenerColor = self.darkener.backgroundColor
        self.darkener.layer.borderColor = self.darkenerBorder.CGColor
        
        // Add Content
        self.content = UILabel(frame: CGRectMake(10, 10, self.bounds.width - 20, self.bounds.height - 20))
        self.content.text = self.post.content
        self.content.textAlignment = NSTextAlignment.Center
        self.content.textColor = UIColor.whiteColor()
        self.content.shadowColor = UIColor(white: 0, alpha: 0.4)
        self.content.shadowOffset = CGSize(width: 0, height: 2)
        self.content.font = UIFont(name: "Balcony Angels", size: 36)
        self.content.numberOfLines = 3
        self.content.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.insertSubview(self.content, aboveSubview: self.darkener)
        
        // TODO: Coloring Content
        let content: [Any] = [ "Wow!! That is crazy", User(PFUser.currentUser(), withRelations: false) ]
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
            
            let delta = self.startPointInSuperview.x - newLocation.x;
            var percentage = abs(delta/self.neededSwipeDistance)
            percentage = (percentage > 1 ? 1 : percentage)
            var newColor: CGColor!
            var newColorBorder = self.darkenerBorder.colorWithAlphaComponent((1 - percentage)).CGColor
        
            if delta < 0 {
                newColor = self.defaults.likeColor
                self.status = .Liked
            } else {
                newColor = self.defaults.nopeColor
                self.status = .None
            }

            self.darkener.backgroundColor = self.mixColors(self.darkenerColor.CGColor, colorTwo: newColor, delta: percentage)
            self.darkener.layer.borderColor = self.mixColors(self.darkenerBorder.CGColor, colorTwo: newColorBorder, delta: percentage).CGColor
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
    
    func returnCardViewToStartPointAnimated(animated: Bool) {
        if animated {
            UIView.animateWithDuration(self.defaults.duration, delay: self.defaults.delay, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.transform = CGAffineTransformIdentity
                self.layer.position = self.startPointInSuperview
                self.darkener.backgroundColor = self.darkenerColor
                self.darkener.layer.borderColor = self.darkenerBorder.CGColor
            }, completion: { _ in self.delegate?.cardDidReturnToCenter?(self); return () })
        } else {
            self.transform = CGAffineTransformIdentity
            self.layer.position = self.startPointInSuperview
            self.darkener.backgroundColor = self.darkenerColor
            self.darkener.layer.borderColor = self.darkenerBorder.CGColor
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
