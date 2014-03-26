//
//  STKSunTrackerViewController.m
//  Sun Tracker
//
//  Created by Julien Ducret on 03/02/2014.
//  Copyright (c) 2014 Julien Ducret. All rights reserved.
//

#import "STKSunTrackerViewController.h"
#import "STKSunTrackerView.h"

@interface STKSunTrackerViewController ()

@property (weak, nonatomic) IBOutlet STKSunTrackerView    *sunTrackerView;

@end

@implementation STKSunTrackerViewController

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

@end
