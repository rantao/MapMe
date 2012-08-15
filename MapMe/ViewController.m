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
#import "ResultAnnotation.h"  //we need to make this class still in order to use the MKAnnotation protocol


@interface ViewController () <RKRequestDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (weak, nonatomic) CLLocationManager* locationManager;
@property (nonatomic) CLLocationCoordinate2D userCoords;
@property (strong, nonatomic) NSMutableArray* allResultAnnotations;
@end

@implementation ViewController



- (void)mapView:(MKMapView *)mapView
didUpdateUserLocation:(MKUserLocation *)userLocation
{
    self.userCoords = [userLocation coordinate];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.userCoords, 5000, 5000);
    
    //region.center = loc;
    [self.map setRegion:region animated:YES];
    [self.map regionThatFits:region];
    //[self setView:mapView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.allResultAnnotations = [NSMutableArray new];
    
    
	// Do any additional setup after loading the view, typically from a nib.
    [self.map setShowsUserLocation:YES];
    [self.map setDelegate:self];
    
    NSString* BASE_URL = @"https://maps.googleapis.com/maps/api";
    [RKClient clientWithBaseURLString:BASE_URL];
    
   // ResultAnnotation* annotation = [ResultAnnotation new];
    //annotation.coordinate = CLLocationCoordinate2DMake(0, 0);
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
    
    [self.map removeAnnotations:self.map.annotations];
 
    //use RestKit to query for icecream places
    RKClient* client = [RKClient sharedClient];
    
    //places api parameters are: key, location, radius, sensor (false), keyword (ie:ice cream), rank_by
    
    // @"37.7750,-122.4183"
    NSString *userCoordsString = [NSString stringWithFormat:@"%f,%f", self.userCoords.latitude, self.userCoords.longitude];
    
    NSDictionary* params = [NSDictionary dictionaryWithKeysAndObjects:
                            @"key",@"AIzaSyCeksVyBzd3BBO3NycqSc4UomaZ8lURruI",
                            @"location", userCoordsString,
                            @"radius", @"5000",
                            @"sensor", @"false",
                            @"keyword", @"puppies",
                            @"rank_by", @"distance", nil
                            ];
    
    NSLog(@"%@", userCoordsString);
    
    [client get:@"/place/search/json" queryParameters:params delegate:self];
}

-(void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response {
    // Here we want to parse the response and stuff them into ResultAnnotation objects
    
    NSDictionary* resultDictionary = [request.response parsedBody:nil];
    //NSLog(@"%@", [pointerToObject class]);
    
//    results
//        geometry
//            location
//                (lat, lng)
//        name
    NSArray* resultLat =[[[[resultDictionary valueForKey:@"results"] valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lat"];
    //NSLog(@"%@", resultLat);
    NSArray* resultLng =[[[[resultDictionary valueForKey:@"results"] valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lng"];
    //NSLog(@"%@", resultLng);
    NSArray* resultName = [[resultDictionary valueForKey:@"results"] valueForKey:@"name"];
    //NSLog(@"%@", resultName);
    for (int i=0; i<[resultLat count]; i++) {
        
        ResultAnnotation* currentResult = [ResultAnnotation new];
        currentResult.coordinate = CLLocationCoordinate2DMake([[resultLat objectAtIndex:i] doubleValue], [[resultLng objectAtIndex:i] doubleValue]);
        currentResult.title = [resultName objectAtIndex:i];
        [self.allResultAnnotations addObject:currentResult];
        [self.map addAnnotation:currentResult];
        
        
    }

}

-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isMemberOfClass:[ResultAnnotation class]]) {
        // only display this kind of annotation view for SimpleAnnotations
        
        // ignore reuseIdentifier for now; I'll talk about it tomorrow
        MKPinAnnotationView* annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
        
        // bring up the gray box when clicked:
        annotationView.canShowCallout = YES;
        annotationView.animatesDrop = YES;
        
        
        // show a blue button in the callout:
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        return annotationView;
    } else {
        // returning nil displays the default annotation view for other annotation types
        return nil;
    }
}

- (IBAction)searchButtonPressed {
    [self queryGooglePlaces];
}


@end
