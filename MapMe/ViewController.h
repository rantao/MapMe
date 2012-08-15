//
//  ViewController.h
//  MapMe
//
//  Created by Ran Tao on 8.14.12.
//  Copyright (c) 2012 Ran Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface ViewController : UIViewController {
    CLLocationManager *locationManager;

}

-(void) queryGooglePlaces;
- (IBAction)searchButtonPressed;

@end
