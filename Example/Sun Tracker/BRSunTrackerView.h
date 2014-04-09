//
//  BRSunTrackerView.h
//  Sun Tracker
//
//  Created by Julien Ducret on 03/02/2014.
//  Copyright (c) 2014 Julien Ducret. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BRSunTrackerView;

@protocol BRSunTrackerViewDelegate <NSObject>

@optional
- (void)sunTrackerViewGotFocus:(BRSunTrackerView *)sunTrackerView;
- (void)sunTrackerViewLostFocus:(BRSunTrackerView *)sunTrackerView;

@end

typedef NS_ENUM(NSUInteger, BRSunState){
    BRSunStateUnknown,
    BRSunStateGotFocus,
    BRSunStateLostFocus
};

@interface BRSunTrackerView : UIView

@property (assign, nonatomic, readonly) BRSunState sunState;
@property (strong, nonatomic) IBOutlet UIView *sunView;
@property (assign, nonatomic) BOOL displayCameraPreview;
@property (assign, nonatomic) BOOL showDefaultSunView;
@property (weak, nonatomic) id<BRSunTrackerViewDelegate> delegate;

@end