//
//  STKSunTracker.h
//  Sun Tracker
//
//  Created by Julien Ducret on 01/02/2014.
//  Copyright (c) 2014 Julien Ducret. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol STKSunTrackerDelegate <NSObject>

- (void)sunTrackerVectorUpdated:(STKSunTrackingVector)vector;

@end

@interface STKSunTracker : NSObject

@property (assign, nonatomic)   id<STKSunTrackerDelegate>   delegate;
@property (assign, nonatomic)   CGSize                      screenSize;

- (id)initWithScreenSize:(CGSize)screenSize;

@end