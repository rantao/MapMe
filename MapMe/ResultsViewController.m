//
//  ResultsViewController.m
//  MapMe
//
//  Created by Ran Tao on 8.15.12.
//  Copyright (c) 2012 Ran Tao. All rights reserved.
//

#import "ResultsViewController.h"
#import <Parse/Parse.h>

@interface ResultsViewController () <CLLocationManagerDelegate>
- (IBAction)ratingButtonPressed:(UIButton *)sender;
@end

@implementation ResultsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.nameOfPlaceLabel.text = self.nameOfPlace;
    self.addressOfPlaceLabel.text = self.addressOfPlace;
}

- (void)viewDidUnload
{
    [self setNameOfPlaceLabel:nil];
    [self setAddressOfPlaceLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)directionsButtonPressed:(UIBarButtonItem *)sender {

    NSString* address = self.addressOfPlace;
    NSString* url = [NSString stringWithFormat: @"http://maps.google.com/maps?saddr=%f,%f&daddr=%@",
                     self.userCoords.latitude, self.userCoords.longitude,
                     [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
}
- (IBAction)ratingButtonPressed:(UIButton *)sender {
    NSNumber *stars = [NSNumber numberWithInt:[sender.titleLabel.text length]];
    
    PFObject *ratingObject = [PFObject objectWithClassName:@"Rating"];
    [ratingObject setObject:self.googleIdOfPlace forKey:@"google_id"];
    [ratingObject setObject:stars forKey:@"stars"];
    [ratingObject save];
}
@end
