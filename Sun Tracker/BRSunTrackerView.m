//
//  BRSunTrackerView.m
//  Sun Tracker
//
//  Created by Julien Ducret on 03/02/2014.
//  Copyright (c) 2014 Julien Ducret. All rights reserved.
//

#import "BRSunTrackerView.h"
#import <AVFoundation/AVFoundation.h>
#import "BRSunTracker.h"

@interface BRSunTrackerView () <BRSunTrackerDelegate>

@property (strong, nonatomic)   UIView                          *sunContainerView;
@property (strong, nonatomic)   UIView                          *defaultSunView;
@property (strong, nonatomic)   BRSunTracker                   *sunTracker;
@property (strong, nonatomic)   AVCaptureSession                *captureSession;
@property (strong, nonatomic)   AVCaptureVideoPreviewLayer      *captureVideoPreviewLayer;
@property (strong, nonatomic)   UIView                          *videoImagePreview;

@end

@implementation BRSunTrackerView

#pragma mark - UIView life cycle

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self initialize];
        [self setDisplayCameraPreview:YES];
        [self setShowDefaultSunView:YES];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self initialize];
    [self setDisplayCameraPreview:YES];
    [self setShowDefaultSunView:YES];
}

#pragma mark - Custom setter

- (void)setDisplayCameraPreview:(BOOL)displayCameraPreview{
    if (_displayCameraPreview && !displayCameraPreview) {
        [self stopCameraPreview];
    }else if (!_displayCameraPreview && displayCameraPreview){
        [self startCameraPreview];
    }
    _displayCameraPreview = displayCameraPreview;
}

- (void)setShowDefaultSunView:(BOOL)showDefaultSunView{
    [_defaultSunView setAlpha:showDefaultSunView?1.0:0.0];
    [_sunView setAlpha:showDefaultSunView?0.0:1.0];
    _showDefaultSunView = showDefaultSunView;
}

- (void)setSunView:(UIView *)sunView{
    if (sunView) {
        [self setShowDefaultSunView:NO];
        [sunView setCenter:CGPointMake(CGRectGetMidX(_sunContainerView.bounds), CGRectGetMidY(_sunContainerView.bounds))];
        [_sunContainerView addSubview:sunView];
    }
    _sunView = sunView;
}

- (void)setBounds:(CGRect)bounds{
    [super setBounds:bounds];
    if (_sunTracker) [_sunTracker setScreenSize:bounds.size];
}

#pragma mark - Initialization

- (void)initialize{
    
    // Set up the sun container view and default sun view
    // (Hide it until we receive sun positions)
    _sunContainerView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:_sunContainerView];
    
    _defaultSunView = [[UIView alloc] init];
    [_defaultSunView setCenter:CGPointMake(CGRectGetMidX(_sunContainerView.bounds), CGRectGetMidY(_sunContainerView.bounds))];
    [_defaultSunView setBounds:CGRectMake(0, 0, 100, 100)];
    [_defaultSunView.layer setCornerRadius:50];
    [_defaultSunView setAlpha:0.0];
    [_defaultSunView.layer setBackgroundColor:[[UIColor yellowColor] CGColor]];
    [_sunContainerView addSubview:_defaultSunView];
    
    // Initialize the sun tracker
    _sunTracker = [[BRSunTracker alloc] initWithScreenSize:self.bounds.size];
    [_sunTracker setDelegate:self];
    _sunState = BRSunStateUnknown;
}

#pragma mark - BRSunTrackerDelegate method

- (void)sunTrackerVectorUpdated:(BRSunTrackingVector)vector{
    
    CGPoint actualCenter = CGPointMake(vector.x, vector.y);
    
    double distance = CGPointDistance(CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)), actualCenter);
    
    if (_sunState == BRSunStateGotFocus) {
        [_defaultSunView.layer setBackgroundColor:[[UIColor redColor] CGColor]];
        
        // Unlock the sun from the center of the screen
        if (distance > UNLOCKING_DISTANCE){
            _sunState = BRSunStateLostFocus;
            [UIView animateWithDuration:distance/ANIMATION_SPEED animations:^{
                [_sunContainerView setCenter:actualCenter];
                [_defaultSunView.layer setBackgroundColor:[[UIColor yellowColor] CGColor]];
            }];
            if(_delegate && [_delegate respondsToSelector:@selector(sunTrackerViewLostFocus:)]){
                [_delegate sunTrackerViewLostFocus:self];
            }
        }
    }else{
        
        if (vector.z > 0.0 && _showDefaultSunView) [_defaultSunView setAlpha:1.0];
        else [_defaultSunView setAlpha:0.0];
        
        // Lock the sun in the center of the screen
        if (distance < LOCKING_DISTANCE) {
            _sunState = BRSunStateGotFocus;
            [UIView animateWithDuration:distance/ANIMATION_SPEED animations:^{
                [_sunContainerView setCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))];
                [_defaultSunView.layer setBackgroundColor:[[UIColor greenColor] CGColor]];
            }];
            if(_delegate && [_delegate respondsToSelector:@selector(sunTrackerViewGotFocus:)]){
                [_delegate sunTrackerViewGotFocus:self];
            }
        }else{
            [_sunContainerView setCenter:actualCenter];
        }
    }
}

#pragma mark - Camera capture

- (void)startCameraPreview{
	
    _videoImagePreview = [[UIView alloc] initWithFrame:self.bounds];
    [self insertSubview:_videoImagePreview atIndex:0];
    
	_captureSession = [[AVCaptureSession alloc] init];
	_captureSession.sessionPreset = AVCaptureSessionPreset640x480;
	_captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
	_captureVideoPreviewLayer.frame = _videoImagePreview.bounds;
	[_videoImagePreview.layer addSublayer:_captureVideoPreviewLayer];
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	NSError *error = nil;
	AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
	if (!input) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
	}else{
        [_captureSession addInput:input];
        [_captureSession startRunning];
    }
}

- (void)stopCameraPreview{
	[_captureSession stopRunning];
	[_captureVideoPreviewLayer removeFromSuperlayer];
    [_videoImagePreview removeFromSuperview];
}


@end
