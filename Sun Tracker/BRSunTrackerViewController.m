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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [_sunTrackerView setDisplayCameraPreview:YES];
    [_sunTrackerView setDelegate:self];
    
//    [_sunTrackerView setSunView:({
//        UIView *sunView = [[UIView alloc] init];
//        [sunView setBounds:CGRectMake(0, 0, 100, 100)];
//        [sunView.layer setCornerRadius:50];
//        [sunView.layer setBackgroundColor:[[UIColor greenColor] CGColor]];
//        sunView;
//    })];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BRSunTrackerViewDelegate methods

- (void)sunTrackerViewGotFocus:(BRSunTrackerView *)sunTrackerView{
    NSLog(@"The sun is aligned with the device.");
}

- (void)sunTrackerViewLostFocus:(BRSunTrackerView *)sunTrackerView{
    NSLog(@"The sun is not aligned with the device anymore.");
}

@end
