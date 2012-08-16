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
#import "ResultAnnotation.h" 
#import "ResultsViewController.h"


@interface ViewController () <RKRequestDelegate,  CLLocationManagerDelegate, UITextFieldDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (weak, nonatomic) CLLocationManager* locationManager;
@property (nonatomic) CLLocationCoordinate2D userCoords;
@property (strong, nonatomic) NSMutableArray* allResultAnnotations;
@property (nonatomic, strong) MKAnnotationView* selectedAnnotationView;
@property (nonatomic) bool hasSearched;
@end

@implementation ViewController
@synthesize searchField = _searchField;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.allResultAnnotations = [NSMutableArray new];
    [RKClient clientWithBaseURLString:@"https://maps.googleapis.com/maps/api"];
    [self.map setShowsUserLocation:YES];
    [self.map setDelegate:self];
    [self.searchField setDelegate:self];
//    if (!self.hasSearched){
//        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.map.userLocation.location.coordinate, 5000, 5000);
//        [self.map setRegion:region animated:YES];
//    }

}

- (void)viewDidUnload
{
    [self setMap:nil];
    [self setSearchField:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField setUserInteractionEnabled:YES];
    [textField resignFirstResponder];
    [self searchButtonPressed];
    return YES;
}

- (void)mapView:(MKMapView *)mapView
didUpdateUserLocation:(MKUserLocation *)userLocation
{
    self.userCoords = [userLocation coordinate];
}

-(void) queryGooglePlaces{
    
    [self.map removeAnnotations:self.map.annotations];
 
    RKClient* client = [RKClient sharedClient];
    NSString *userCoordsString = [NSString stringWithFormat:@"%f,%f", self.userCoords.latitude, self.userCoords.longitude];
    
    NSDictionary* params = [NSDictionary dictionaryWithKeysAndObjects:
                            @"key",@"AIzaSyCeksVyBzd3BBO3NycqSc4UomaZ8lURruI",
                            @"location", userCoordsString,
                            @"radius", @"5000",
                            @"sensor", @"false",
                            @"keyword", self.searchField.text,
                            @"rank_by", @"distance", nil
                            ];
    
    NSLog(@"%@", userCoordsString);
    
    [client get:@"/place/search/json" queryParameters:params delegate:self];
}

-(void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response {
    // Here we want to parse the response and stuff them into ResultAnnotation objects
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.userCoords, 5000, 5000);
    
    [self.map setRegion:region animated:YES];
    
    NSDictionary* resultDictionary = [request.response parsedBody:nil];
    NSArray* resultLat =[[[[resultDictionary valueForKey:@"results"] valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lat"];
    NSArray* resultLng =[[[[resultDictionary valueForKey:@"results"] valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lng"];
    NSArray* resultName = [[resultDictionary valueForKey:@"results"] valueForKey:@"name"];
    NSArray* resultAddr = [[resultDictionary valueForKey:@"results"] valueForKey:@"vicinity"];
    for (int i=0; i<[resultLat count]; i++) {
        ResultAnnotation* currentResult = [ResultAnnotation new];
        currentResult.coordinate = CLLocationCoordinate2DMake([[resultLat objectAtIndex:i] doubleValue], [[resultLng objectAtIndex:i] doubleValue]);
        currentResult.title = [resultName objectAtIndex:i];
        currentResult.address = [resultAddr objectAtIndex:i];
        [self.allResultAnnotations addObject:currentResult];
        [self.map addAnnotation:currentResult];
        
        
    }

}

-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isMemberOfClass:[ResultAnnotation class]]) {
        MKPinAnnotationView* annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
        annotationView.canShowCallout = YES;
        annotationView.animatesDrop = YES;
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return annotationView;
    } else {
        return nil;
    }
}

- (IBAction)searchButtonPressed {
    self.hasSearched = YES;
    if (!self.searchField.text) {
        return;
    }
    [self queryGooglePlaces];
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    self.selectedAnnotationView = view;
    [self performSegueWithIdentifier:@"resultsSegue" sender:self];
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ResultsViewController* rvc = segue.destinationViewController;
    ResultAnnotation* annotation = self.selectedAnnotationView.annotation;
    rvc.nameOfPlace = annotation.title;
    rvc.addressOfPlace = annotation.address;
    rvc.userCoords = self.userCoords;
}

@end
