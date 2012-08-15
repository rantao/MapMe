//
//  ViewController.m
//  MapMe
//
//  Created by Ran Tao on 8.14.12.
//  Copyright (c) 2012 Ran Tao. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "ViewController.h"
#import "RestKit.h"


@interface ViewController () <RKRequestDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (weak, nonatomic) CLLocationManager* locationManager;
@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        locationManager = [CLLocationManager new];
        [locationManager setDelegate:self];
        [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [locationManager startUpdatingLocation];
    }
    
    return self;

}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"%@", newLocation);
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"Could not find location: %@", error);
}

- (void)mapView:(MKMapView *)mapView
didUpdateUserLocation:(MKUserLocation *)userLocation
{
    CLLocationCoordinate2D loc = [userLocation coordinate];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 50, 50);
    region.center = loc;
    [self.map setShowsUserLocation:TRUE];
    [self.map setDelegate:self];
    [self.map setRegion:region animated:YES];
    [self.map regionThatFits:region];
    [self setView:mapView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
   // [self.map setShowsUserLocation:YES];
    
    NSString* BASE_URL = @"https://maps.googleapis.com/maps/api";
    [RKClient clientWithBaseURLString:BASE_URL];
}

- (void)viewDidUnload
{
    [self setMap:nil];
    [self setMap:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

-(void) queryGooglePlaces{
 
    //use RestKit to query for icecream places
    RKClient* client = [RKClient sharedClient];
    
    //places api parameters are: key, location, radius, sensor (false), keyword (ie:ice cream), rank_by
    
    NSDictionary* params = [NSDictionary dictionaryWithKeysAndObjects:
                            @"key",@"AIzaSyCeksVyBzd3BBO3NycqSc4UomaZ8lURruI",
                            @"location", @"37.7750,-122.4183",
                            @"radius", @"5000",
                            @"sensor", @"false",
                            @"keyword", @"puppies",
                            @"rank_by", @"distance", nil
                            ];
    [client get:@"/place/search/json" queryParameters:params delegate:self];
}

-(void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response {
    NSLog(@"%@", [request.response parsedBody:nil]);
}

- (IBAction)searchButtonPressed {
    [self queryGooglePlaces];
}


@end
