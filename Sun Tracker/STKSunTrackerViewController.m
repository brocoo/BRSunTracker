//
//  STKSunTrackerViewController.m
//  Sun Tracker
//
//  Created by Julien Ducret on 03/02/2014.
//  Copyright (c) 2014 Julien Ducret. All rights reserved.
//

#import "STKSunTrackerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "STKSunTrackerView.h"

@interface STKSunTrackerViewController ()

@property (weak, nonatomic) IBOutlet STKSunTrackerView    *sunTrackerView;
@property (strong, nonatomic) AVCaptureSession                  *captureSession;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer        *captureVideoPreviewLayer;
@property (strong, nonatomic) UIView                            *videoImagePreview;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self startCameraPreview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Camera capture

- (void)startCameraPreview{
	
    _videoImagePreview = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view insertSubview:_videoImagePreview atIndex:0];
    
	AVCaptureSession *session = [[AVCaptureSession alloc] init];
	session.sessionPreset = AVCaptureSessionPresetMedium;
	AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
	captureVideoPreviewLayer.frame = _videoImagePreview.bounds;
	[_videoImagePreview.layer addSublayer:captureVideoPreviewLayer];
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	NSError *error = nil;
	AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
	if (!input) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
	}else{
        [session addInput:input];
        [session startRunning];
    }
}

- (void)stopCameraPreview{
	[_captureSession stopRunning];
	[_captureVideoPreviewLayer removeFromSuperlayer];
}

@end
