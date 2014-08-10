//
//  CardView.m
//
//  Created by Tim Woo on 9/22/13.
//  Modified by Brian Vallelunga on 8/9/14.
//  Copyright (c) 2013 Tim Woo. All rights reserved.
//

#import "CardView.h"

#define DEGREE_TO_RADIAN(x) x*M_PI/180

// Defaults
#define DEFAULT_SWIPE_DISTANCE 80
#define DEFAULT_BORDER_WIDTH 5
#define DEFAULT_ROTATION_ANGLE 10

@interface CardView ()
@property (nonatomic) CGPoint startPointInSuperview;
@property (assign, nonatomic) BOOL isOffScreen;     // privately can assign, public readonly
@property (assign, nonatomic) BOOL isShowingFront;  // privately can assign, public readonly

@property (strong, nonatomic) UIPanGestureRecognizer *panGesture;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
@end

@implementation CardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
        [self setupAttributes];
        [self setupGestures];
    }
    return self;
}

- (void)setupViews {
    // Add front card
    self.front = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.front.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    self.front.layer.shouldRasterize = YES;
    
    // Add white background to front card
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(DEFAULT_BORDER_WIDTH,
                                                                  DEFAULT_BORDER_WIDTH,
                                                                  self.frame.size.width-2*DEFAULT_BORDER_WIDTH,
                                                                  self.frame.size.height-2*DEFAULT_BORDER_WIDTH)];
    background.layer.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.7].CGColor;
    [self.front addSubview:background];
    
    // Add "Yep" "Nope" labels
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    self.label.alpha = 0;
    self.label.textAlignment = NSTextAlignmentCenter;
    
    [self.front addSubview:self.label];
    [self addSubview:self.front];
}

- (void)setupAttributes {
    self.isOffScreen = NO;
    self.isShowingFront = YES;
    self.neededSwipeDistance = DEFAULT_SWIPE_DISTANCE;
    self.userInteractionEnabled = YES;
    self.rotationAngle = DEFAULT_ROTATION_ANGLE;
}

- (void)setupGestures {
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandle:)];
    [self addGestureRecognizer:self.panGesture];
}

#pragma mark - Gesture Handlers

- (IBAction)panHandle:(UIPanGestureRecognizer *)gesture {
    CGPoint newLocation = [gesture locationInView:self.superview];
    
    if(gesture.state==UIGestureRecognizerStateBegan) {
        self.startPointInSuperview = newLocation;
        CGPoint anchor = [gesture locationInView:gesture.view];

        [self setAnchorPoint:CGPointMake(anchor.x/gesture.view.bounds.size.width,
                                         anchor.y/gesture.view.bounds.size.height)
                     forView:gesture.view];
    }
    else if(gesture.state==UIGestureRecognizerStateChanged) {
        // Move the card
        gesture.view.layer.position = newLocation;
        
        // Calculate rotation
        CGFloat rotation = self.rotationAngle*(-newLocation.x/self.startPointInSuperview.x+1);
        rotation = (rotation > 0 ? MIN(rotation, self.rotationAngle) : MAX(rotation, -self.rotationAngle));
        if (gesture.view.layer.anchorPoint.y < 0.5) {
            rotation = -rotation;
        }
        gesture.view.transform = CGAffineTransformMakeRotation(DEGREE_TO_RADIAN(rotation));
        
        // Show the label
        CGFloat delta = self.startPointInSuperview.x - newLocation.x;
        if (delta < 0) {
            self.label.text = @"YEP";
            self.label.alpha = (-delta/self.neededSwipeDistance > 1 ? 1 : -delta/self.neededSwipeDistance);
        }
        else {
            self.label.text = @"NOPE";
            self.label.alpha = (delta/self.neededSwipeDistance > 1 ? 1 : delta/self.neededSwipeDistance);
        }
    }
    else if (gesture.state == UIGestureRecognizerStateEnded) {
        CardViewLocation cardViewLocation = [self getCardViewLocationInSuperView:newLocation];
        
        CGPoint velocity = [gesture velocityInView:self.superview];
        CGFloat magnitude = sqrtf((velocity.x * velocity.x) + (velocity.y * velocity.y));
        CGFloat slideMult = magnitude / 200;
        
        float slideFactor = 0.0025 * slideMult; // Increase for more of a slide
        CGPoint finalPoint = CGPointMake(gesture.view.layer.position.x + (velocity.x * slideFactor),
                                         gesture.view.layer.position.y + (velocity.y * slideFactor));
        
        [UIView animateWithDuration:slideFactor*2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            gesture.view.layer.position = finalPoint;
        } completion:^(BOOL finished) {
            // Calculate final change in x-position that was made
            CGFloat swipeDistance = self.startPointInSuperview.x - newLocation.x;
            CGFloat absSwipeDistance = labs(swipeDistance);
            
            if (absSwipeDistance < self.neededSwipeDistance) {
                if ([self.delegate respondsToSelector:@selector(cardView:willReturnToCenterFrom:)]) {
                    [self.delegate cardView:self willReturnToCenterFrom:cardViewLocation];
                }
                
                [self returnCardViewToStartPointAnimated:YES];
            }
            else {
                if ([self.delegate respondsToSelector:@selector(cardView:willGoOffscreenFrom:)]) {
                    [self.delegate cardView:self willGoOffscreenFrom:cardViewLocation];
                }
                
                // Animate off screen
                [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    CGFloat offscreenX = (swipeDistance > 0 ? -self.superview.frame.origin.x-self.bounds.size.width : self.superview.frame.size.width+self.bounds.size.width);
                    gesture.view.layer.position = CGPointMake(offscreenX, gesture.view.layer.position.y);
                } completion:^(BOOL finished) {
                    if ([self.delegate respondsToSelector:@selector(cardView:didGoOffscreenFrom:)]) {
                        [self.delegate cardView:self didGoOffscreenFrom:cardViewLocation];
                    }
                }];
            }
        }];
    }
}

#pragma mark - Public Methods
- (void)returnCardViewToStartPointAnimated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.transform = CGAffineTransformIdentity;
            self.layer.position = self.startPointInSuperview;
            self.label.alpha = 0;
        } completion:^(BOOL finished) {
            if ([self.delegate respondsToSelector:@selector(cardView:didReturnToCenterFrom:)]) {
                [self.delegate cardView:self didReturnToCenterFrom:[self getCardViewLocationInSuperView:self.layer.position]];
            }
        }];
    }
    else {
        self.transform = CGAffineTransformIdentity;
        self.layer.position = self.startPointInSuperview;
        self.label.alpha = 0;
        if ([self.delegate respondsToSelector:@selector(cardView:didReturnToCenterFrom:)]) {
            [self.delegate cardView:self didReturnToCenterFrom:[self getCardViewLocationInSuperView:self.layer.position]];
        }
    }
}

#pragma mark - Helper methods

-(void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view
{
    CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x, view.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x, view.bounds.size.height * view.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
    
    CGPoint position = view.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    view.layer.position = position;
    view.layer.anchorPoint = anchorPoint;
}

- (void)applyRotationToView:(UIView*)rotationView byAngle:(CGFloat)angle {
    rotationView.transform = CGAffineTransformRotate(rotationView.transform, angle);
}

- (CardViewLocation)getCardViewLocationInSuperView:(CGPoint)currentLocation {
    CardViewLocation result;
    CGFloat middleX = self.superview.frame.size.width/2;
    CGFloat middleY = self.superview.frame.size.height/2;
    if (currentLocation.x < middleX) {
        if (currentLocation.y < middleY) result = CardViewTopLeft;
        else result = CardViewBottomLeft;
    }
    else {
        if (currentLocation.y < middleY) result = CardViewTopRight;
        else result = CardViewBottomRight;
    }
    
    return result;
}
@end
