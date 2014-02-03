//
//  STKSunTrackerView.m
//  Sun Tracker
//
//  Created by Julien Ducret on 03/02/2014.
//  Copyright (c) 2014 Julien Ducret. All rights reserved.
//

#import "STKSunTrackerView.h"
#import "STKSunTracker.h"

@interface STKSunTrackerView () <STKSunTrackerDelegate>

@property (strong, nonatomic)   UIView          *sunView;
@property (strong, nonatomic)   STKSunTracker   *sunTracker;

@end

@implementation STKSunTrackerView

#pragma mark - UIView life cycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) [self initialize];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) [self initialize];
    return self;
}

#pragma mark - Initialization

- (void)initialize{
    
    // Set up the sun view
    // (Hide it until we receive sun positions)
    _sunView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [_sunView.layer setCornerRadius:50];
    [_sunView setAlpha:0.0];
    [_sunView.layer setBackgroundColor:[[UIColor yellowColor] CGColor]];
    [self addSubview:_sunView];
    
    // Initialize the sun tracker
    _sunTracker = [[STKSunTracker alloc] initWithScreenSize:self.bounds.size];
    [_sunTracker setDelegate:self];
    _sunState = STKSunStateUnlocked;
}

#pragma mark - STKSunTrackerDelegate method

- (void)sunTrackerVectorUpdated:(STKSunTrackingVector)vector{
    
    CGPoint actualCenter = CGPointMake(vector.x - _sunView.frame.size.width/2, vector.y - _sunView.frame.size.height/2);
    double distance = CGPointDistance(self.center, actualCenter);
    
    if (_sunState == STKSunStateLocked) {
        [_sunView.layer setBackgroundColor:[[UIColor redColor] CGColor]];
        
        // Unlock the sun from the center of the screen
        if (distance > UNLOCKING_DISTANCE){
            _sunState = STKSunStateUnlocked;
            [UIView animateWithDuration:distance/ANIMATION_SPEED animations:^{
                [_sunView setCenter:actualCenter];
                [_sunView.layer setBackgroundColor:[[UIColor yellowColor] CGColor]];
            }];
        }
    }else{
        
        if (vector.z > 0.0) [_sunView setAlpha:1.0];
        else [_sunView setAlpha:0.0];
        
        // Lock the sun in the center of the screen
        if (distance < LOCKING_DISTANCE) {
            _sunState = STKSunStateLocked;
            [UIView animateWithDuration:distance/ANIMATION_SPEED animations:^{
                [_sunView setCenter:self.center];
                [_sunView.layer setBackgroundColor:[[UIColor greenColor] CGColor]];
            }];
        }else{
            [_sunView setCenter:actualCenter];
        }
    }
}

@end
