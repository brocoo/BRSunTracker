//
//  BRSunTracker.m
//  Sun Tracker
//
//  Created by Julien Ducret on 01/02/2014.
//  Copyright (c) 2014 Julien Ducret. All rights reserved.
//

#import "BRSunTracker.h"
#import <CoreMotion/CoreMotion.h>       // Gyroscope access
#import <CoreLocation/CoreLocation.h>   // GPS Location access

@interface BRSunTracker () <CLLocationManagerDelegate> {
    vec4f_t _sunPositionVector;
    mat4f_t _projectionTransform;
}

@property (strong, nonatomic)   CLLocationManager   *locationManager;
@property (strong, nonatomic)   CMMotionManager     *motionManager;
@property (assign, nonatomic)   BOOL                sunPositionVectorAvailable;
@property (assign, nonatomic)   BOOL                deviceOrientationVectorAvailable;

@end

@implementation BRSunTracker

#pragma mark - Initialization and life cycle

- (instancetype)init{
    self = [super init];
    if (self) [self initialize];
    return self;
}

- (instancetype)initWithViewSize:(CGSize)viewSize{
    self = [self init];
    if (self) [self setViewSize:viewSize];
    return self;
}

- (void)initialize{
    
    _sunPositionVectorAvailable = NO;
    _deviceOrientationVectorAvailable = NO;
    
    // Set up the location manager
    // (Used for sun tracking)
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [_locationManager setDelegate:self];
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusDenied: {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                           message:@"Location disallowed. Please update in Settings"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                  }];
            UIAlertAction* settingsAction = [UIAlertAction actionWithTitle:@"Settings"
                                                                    style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction * action) {
                                                                       [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
                                                                   }];
            [alert addAction:defaultAction];
            [alert addAction:settingsAction];
            [self.delegate.viewController presentViewController:alert animated:YES completion:nil];
            break;
        }

        case kCLAuthorizationStatusRestricted: {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                           message:@"Location is restricted. Parental Controls?"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                  }];
            [alert addAction:defaultAction];
            [self.delegate.viewController presentViewController:alert animated:YES completion:nil];
            break;
        }
            
        case kCLAuthorizationStatusNotDetermined:
            [self.locationManager requestWhenInUseAuthorization];
            break;
            
        default:
            break;
    }
}

- (void) setupGyroscope {
    // Set up the motion manager (Gyroscope) and its callback
    _motionManager = [[CMMotionManager alloc] init];
    if ([_motionManager isGyroAvailable]) {
        [_motionManager setShowsDeviceMovementDisplay:YES];
        [_motionManager setDeviceMotionUpdateInterval:MOTION_UPDATE_INTERVAL];

        __weak typeof(self) weakSelf = self;
        [_motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXTrueNorthZVertical toQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
            if (!error && weakSelf) [weakSelf deviceMotionUpdated:motion];
        }];

    } else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:@"The gyroscope is not available on this device."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self.delegate.viewController presentViewController:alert animated:YES completion:nil];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [_locationManager startUpdatingLocation];
        [self setupGyroscope];
    }
}

- (void)dealloc{
    [self stopServices];
}

- (void)stopServices{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.locationManager stopUpdatingLocation];
    [self.locationManager setDelegate:nil];
    [self.motionManager stopDeviceMotionUpdates];
}

- (void)restartServices{
    [self initialize];
}

#pragma mark - Custom setters

- (void)setDelegate:(id<BRSunTrackerDelegate>)delegate{
    if (!delegate) {
        [self stopServices];
        _delegate = nil;
    }else if(delegate != _delegate){
        _delegate = delegate;
        [self initialize];
    }
}

- (void)setViewSize:(CGSize)viewSize{
    _viewSize = viewSize;
    
    // Update the projection matrix
    createProjectionMatrix(_projectionTransform, DEGREES_TO_RADIANS(60.0), viewSize.width/viewSize.height, 0.25f, 1000.0f);
}

#pragma mark - Tracking vector update

- (void)updateTrackingVector{
    
    CMRotationMatrix rotationMatrix = _motionManager.deviceMotion.attitude.rotationMatrix;
    
    if (!_sunPositionVectorAvailable || !_deviceOrientationVectorAvailable) return;
    
    // Transform the device rotation matrix to a 4D matrix
    mat4f_t cameraTransform;
    transformFromCMRotationMatrix(cameraTransform, &rotationMatrix);
    
    // Project the rotation matrix to the camera
    mat4f_t projectionCameraTransform;
    multiplyMatrixAndMatrix(projectionCameraTransform, _projectionTransform, cameraTransform);
    
    // Multiply the projected rotation matrix with the sun coordinates vector
    vec4f_t projectedSunCoordinates;
    multiplyMatrixAndVector(projectedSunCoordinates, projectionCameraTransform, _sunPositionVector);
    
    // Project the rotated sun coordinates on the screen
    // (z value indicates weither the sun is in front or behind)
    BRSunTrackingVector sunTrackingVector;
    sunTrackingVector.x = ((projectedSunCoordinates[0] / projectedSunCoordinates[3] + 1.0f) * 0.5f) * _viewSize.width;
    sunTrackingVector.y = _viewSize.height - _viewSize.height*((projectedSunCoordinates[1] / projectedSunCoordinates[3] + 1.0f) * 0.5f);
    sunTrackingVector.z = projectedSunCoordinates[2];
    
    if (_delegate && [_delegate respondsToSelector:@selector(sunTrackerVectorUpdated:)]) {
        [_delegate sunTrackerVectorUpdated:sunTrackingVector];
    }
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    [self sunPositionVectorForCoordinates:manager.location];
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager{
    if(!manager.heading) return YES;
    else if( manager.heading.headingAccuracy < 0 ) return YES;
    else if( manager.heading.headingAccuracy > 5 ) return YES;
    else return NO;
}

#pragma mark - CMMotionManager callback

- (void)deviceMotionUpdated:(CMDeviceMotion *)motion{
    _deviceOrientationVectorAvailable = YES;
    [self updateTrackingVector];
}

#pragma mark - Sun tracking methods

- (void)sunPositionVectorForCoordinates:(CLLocation *)location{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    CLLocationCoordinate2D coordinates = location.coordinate;
    
    // Compute spherical coordinates (azimuth & elevation angle) of the sun from location, time zone, date and current time
    BRSunSphericalPosition sunPosition = [self sunPositionForCoordinate:coordinates];
    
    // Translate the elevation angle from 'sun - Z axis(up)' to 'sun - XY axis(ground)'
    sunPosition.elevation = 90 - sunPosition.elevation;
    
    // Distance Earth-Sun (radius in Spherical coordinates)
    double radius = 1.0;
    
    // Extract cartesian coordinates from azimuth and elevation angle
    // http://computitos.files.wordpress.com/2008/03/cartesian_spherical_transformation.pdf
    _sunPositionVector[0] = radius * cos(DEGREES_TO_RADIANS(sunPosition.elevation))*cos(DEGREES_TO_RADIANS(sunPosition.azimuth));
    _sunPositionVector[1] = radius * cos(DEGREES_TO_RADIANS(sunPosition.elevation))*sin(DEGREES_TO_RADIANS(sunPosition.azimuth));
    _sunPositionVector[2] = radius * sin(DEGREES_TO_RADIANS(sunPosition.elevation));
    _sunPositionVector[3] = 1.0;
    
    // The compass/gyroscope Y axis is inverted
    _sunPositionVector[1] = -_sunPositionVector[1];
    
    _sunPositionVectorAvailable = YES;
    [self updateTrackingVector];
    
    [self performSelector:@selector(sunPositionVectorForCoordinates:) withObject:location afterDelay:60];
}

- (BRSunSphericalPosition)sunPositionForCoordinate:(CLLocationCoordinate2D)coordinate{
    
    // The algorithm below is based on the PSA algorithm
    // From http://www.psa.es/sdg/sunpos.htm
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:[NSDate date]];
    
    // Main variables
	double dElapsedJulianDays;
	double dDecimalHours;
	double dEclipticLongitude;
	double dEclipticObliquity;
	double dRightAscension;
	double dDeclination;
    
	// Auxiliary variables
	double dY;
	double dX;
    
	// Calculate difference in days between the current Julian Day
	// and JD 2451545.0, which is noon 1 January 2000 Universal Time
    double dJulianDate;
    long int liAux1;
    long int liAux2;
    
    // Calculate time of the day in UT decimal hours
    dDecimalHours = [components hour] + ([components minute] + [components second] / 60.0 ) / 60.0;
    
    // Calculate current Julian Day
    liAux1 =([components month]-14)/12;
    liAux2=(1461*([components year] + 4800 + liAux1))/4 + (367*([components month] - 2-12*liAux1))/12- (3*(([components year] + 4900 + liAux1)/100))/4+[components day]-32075;
    dJulianDate=(double)(liAux2)-0.5+dDecimalHours/24.0;
    
    // Calculate difference between current Julian Day and JD 2451545.0
    dElapsedJulianDays = dJulianDate-2451545.0;
    
	// Calculate ecliptic coordinates (ecliptic longitude and obliquity of the
	// ecliptic in radians but without limiting the angle to be less than 2*Pi
	// (i.e., the result may be greater than 2*Pi)
    double dMeanLongitude;
    double dMeanAnomaly;
    double dOmega;
    dOmega=2.1429-0.0010394594*dElapsedJulianDays;
    dMeanLongitude = 4.8950630+ 0.017202791698*dElapsedJulianDays; // Radians
    dMeanAnomaly = 6.2400600+ 0.0172019699*dElapsedJulianDays;
    dEclipticLongitude = dMeanLongitude + 0.03341607*sin(dMeanAnomaly) + 0.00034894*sin(2*dMeanAnomaly)-0.0001134 -0.0000203*sin(dOmega);
    dEclipticObliquity = 0.4090928 - 6.2140e-9*dElapsedJulianDays + 0.0000396*cos(dOmega);
    
	// Calculate celestial coordinates ( right ascension and declination ) in radians
	// but without limiting the angle to be less than 2*Pi (i.e., the result may be
	// greater than 2*Pi)
    double dSin_EclipticLongitude;
    dSin_EclipticLongitude= sin( dEclipticLongitude );
    dY = cos( dEclipticObliquity ) * dSin_EclipticLongitude;
    dX = cos( dEclipticLongitude );
    dRightAscension = atan2( dY,dX );
    if( dRightAscension < 0.0 ) dRightAscension = dRightAscension + (M_PI*2);
    dDeclination = asin( sin( dEclipticObliquity )*dSin_EclipticLongitude );
    
	// Calculate local coordinates (azimuth and elevation angle) in degrees
    double dGreenwichMeanSiderealTime;
    double dLocalMeanSiderealTime;
    double dLatitudeInRadians;
    double dHourAngle;
    double dCos_Latitude;
    double dSin_Latitude;
    double dCos_HourAngle;
    double dParallax;
    dGreenwichMeanSiderealTime = 6.6974243242 + 0.0657098283*dElapsedJulianDays + dDecimalHours;
    dLocalMeanSiderealTime = (dGreenwichMeanSiderealTime*15 + coordinate.longitude)*(M_PI/180);
    dHourAngle = dLocalMeanSiderealTime - dRightAscension;
    dLatitudeInRadians = coordinate.latitude*(M_PI/180);
    dCos_Latitude = cos(dLatitudeInRadians);
    dSin_Latitude = sin(dLatitudeInRadians);
    dCos_HourAngle= cos(dHourAngle);
    
    BRSunSphericalPosition sunCoordinates;
    sunCoordinates.elevation = (acos( dCos_Latitude*dCos_HourAngle*cos(dDeclination) + sin( dDeclination )*dSin_Latitude));
    dY = -sin(dHourAngle);
    dX = tan(dDeclination)*dCos_Latitude - dSin_Latitude*dCos_HourAngle;
    sunCoordinates.azimuth = atan2( dY, dX );
    if ( sunCoordinates.azimuth < 0.0 ) sunCoordinates.azimuth = sunCoordinates.azimuth + (M_PI*2);
    sunCoordinates.azimuth = sunCoordinates.azimuth/(M_PI/180);
    // Parallax Correction
    dParallax=(6371.01/149597890)*sin(sunCoordinates.elevation);
    sunCoordinates.elevation = (sunCoordinates.elevation + dParallax)/(M_PI/180);
    
    return sunCoordinates;
}

@end
