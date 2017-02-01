//
//  BRSunTrackerViewController.m
//  Sun Tracker
//
//  Created by Julien Ducret on 03/02/2014.
//  Copyright (c) 2014 Julien Ducret. All rights reserved.
//

#import "BRSunTrackerViewController.h"
#import "BRSunTrackerView.h"

@interface BRSunTrackerViewController () <BRSunTrackerViewDelegate>

@property (weak, nonatomic) IBOutlet BRSunTrackerView    *sunTrackerView;

@end


@implementation BRSunTrackerViewController

#pragma mark - UIViewController life cycle

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    [self.sunTrackerView configureWithViewController:self];
    [_sunTrackerView setDisplayCameraPreview:YES];
    [_sunTrackerView setDelegate:self];
}

#pragma mark - BRSunTrackerViewDelegate methods

- (void)sunTrackerViewGotFocus:(BRSunTrackerView *)sunTrackerView{
    NSLog(@"The sun is aligned with the device.");
}

- (void)sunTrackerViewLostFocus:(BRSunTrackerView *)sunTrackerView{
    NSLog(@"The sun is not aligned with the device anymore.");
}

@end
