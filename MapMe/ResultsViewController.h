//
//  ResultsViewController.h
//  MapMe
//
//  Created by Ran Tao on 8.15.12.
//  Copyright (c) 2012 Ran Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface ResultsViewController : UIViewController {
    CLLocationManager *locationManager;
}
@property (strong, nonatomic) IBOutlet UILabel *nameOfPlaceLabel;
@property (strong, nonatomic) NSString* nameOfPlace;
@property (weak, nonatomic) IBOutlet UILabel *addressOfPlaceLabel;
@property (strong, nonatomic) NSString* addressOfPlace;
@property (nonatomic) CLLocationCoordinate2D userCoords;
@property (strong, nonatomic) NSString* googleIdOfPlace;
- (IBAction)directionsButtonPressed:(UIBarButtonItem *)sender;

@end
