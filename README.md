# BRSunTracker

BRSunTracker is a set of classes using [Augmented Reality] that allow you to track and display the position of the sun on your device screen, based on your current GPS location, the device gyroscope, the time and the date.

The position of the sun in the sky is computed via the PSA Algorithm, and its position on the screen uses the device rotation matrix provided by the gyroscope (See "How does it work?" section below).
BRSunTracker also works during the night, just aim at your feet to find to find the sun.

The sample app included displays a marker on a camera preview that follows the sun on the screen and snaps to the middle of the view once the phone is oriented towards it.

![http://i.imgur.com/RyTVnY6.png](http://i.imgur.com/RyTVnY6.png)

## Installation

BRSunTracker is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod "BRSunTracker"
    
## Usage

1.  Import the `BRSunTrackerView` class into your view controller:

  ```objective-c
    #import "BRSunTrackerView.h"
  ```
  
2.  Instanciate `BRSunTrackerView` and add it as a subview.
  ```objective-c
BRSunTrackerView *sunTrackerView = [[BRSunTrackerView alloc] initWithFrame:CGRectMake(0, 0, 320, 428)];
[self.view addSubview:sunTrackerView];
  ```
Or you can also add a `BRSunTrackerView` directly via the Interface Builder.

3.  By default, the `BRSunTrackerView` will display a camera preview, and a default marker following the sun. 
You can enable or disable the camera and provide your own UIView as a marker by setting these properties:
  ```objective-c
    // Enable or disable the camera preview
    // (The default value is YES)
    [sunTrackerView setDisplayCameraPreview:YES];

    // Provide your own marker subview 
    // (otherwise will display the default one)
    [sunTrackerView setSunView:myMarkerView];
  ```
4. (Optional) Set your view controller as the delegate of the `BRSunTrackerView` and make it conform to the `BRSunTrackerViewDelegate` protocol. Implement the following methods to detect when the phone is aligned with the sun:

  ```objective-c
    [sunTrackerView setDelegate:self];  
  ```
  
  ```objective-c
    - (void)sunTrackerViewGotFocus:(BRSunTrackerView *)sunTrackerView{
        NSLog(@"The sun is aligned with the device.");
    }
    
    - (void)sunTrackerViewLostFocus:(BRSunTrackerView *)sunTrackerView{
        NSLog(@"The sun is not aligned with the device anymore.");
    }
  ```
5. Grab a pair of sunglasses (and a cold drink).


## How does it work?

A diagram explaining roughly the process of computing the sun 2D screen coordinates in BRSunTracker is shown below.
All of this happens inside the `BRSunTracker` class.
The gyroscope orientation data is currently sampled 60 times per second, the sun spherical coordinates are computed every minute or when the GPS location gets updated.

![http://i.imgur.com/aF1SeW5.png](http://i.imgur.com/aF1SeW5.png)

## Sources and Acknowledgements

[pARk], Apple code sample showing a basic Augmented Reality implementation

[PSA Algorithm], C++ function that computes the spherical coordinates of the sun based on the GPS coordinates, the time and date.

[Stack Overflow], My initial Stack Overflow post about how to compare the device orientation with the sun position.

## Author

Julien Ducret - <brocoo@gmail.com>

Follow me on Twitter [@jbrocoo](https://twitter.com/jbrocoo)

Check out my app: [Spores](https://itunes.apple.com/us/app/spores/id718495353?l=fr&ls=1&mt=8)

## Licence

BRFlabbyTable is under Apache licence, see the LICENCE file for more info.

[Augmented Reality]:http://en.wikipedia.org/wiki/Augmented_reality
[PSA Algorithm]:http://www.psa.es/sdg/sunpos.htm
[pARk]:https://developer.apple.com/library/ios/samplecode/pARk/Introduction/Intro.html
[Stack Overflow]:http://stackoverflow.com/questions/21246745/compare-device-3d-orientation-with-the-sun-position
