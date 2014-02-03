//
//  STKSunTrackerView.h
//  Sun Tracker
//
//  Created by Julien Ducret on 03/02/2014.
//  Copyright (c) 2014 Julien Ducret. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, STKSunState){
    STKSunStateUnlocked,
    STKSunStateLocked
};

@interface STKSunTrackerView : UIView

@property (assign, nonatomic)   STKSunState     sunState;

@end