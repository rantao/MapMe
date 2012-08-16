//
//  ResultAnnotation.h
//  MapMe
//
//  Created by Ran Tao on 8.15.12.
//  Copyright (c) 2012 Ran Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface ResultAnnotation : NSObject <MKAnnotation>
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString* title;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *google_id;
@end
