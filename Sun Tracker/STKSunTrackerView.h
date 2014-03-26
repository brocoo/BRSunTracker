//
//  STKSunTrackerView.h
//  Sun Tracker
//
//  Created by Julien Ducret on 03/02/2014.
//  Copyright (c) 2014 Julien Ducret. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STKSunTracker.h"

@class STKSunTrackerView;

@protocol STKSunTrackerViewDelegate <NSObject>

@optional
- (void)sunTrackerViewGotFocus:(STKSunTrackerView *)sunTrackerView;
- (void)sunTrackerViewLostFocus:(STKSunTrackerView *)sunTrackerView;

@end

typedef NS_ENUM(NSUInteger, STKSunState){
    STKSunStateUnknown,
    STKSunStateGotFocus,
    STKSunStateLostFocus
};

@interface STKSunTrackerView : UIView

@property (assign, nonatomic, readonly)     STKSunState     sunState;
@property (strong, nonatomic)   IBOutlet    UIView          *sunView;
@property (assign, nonatomic)               BOOL            displayCameraPreview;
@property (assign, nonatomic)               BOOL            showDefaultSunView;

@end