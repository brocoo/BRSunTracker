//
//  BRSunTracker.h
//  Sun Tracker
//
//  Created by Julien Ducret on 01/02/2014.
//  Copyright (c) 2014 Julien Ducret. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BRSunTrackerDelegate <NSObject>

- (void)sunTrackerVectorUpdated:(BRSunTrackingVector)vector;

@end

@interface BRSunTracker : NSObject

@property (assign, nonatomic)   id<BRSunTrackerDelegate>   delegate;
@property (assign, nonatomic)   CGSize                      screenSize;

- (id)initWithScreenSize:(CGSize)screenSize;

@end