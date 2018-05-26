//
//  MKMapView+Mocking.h
//  Library
//
//  Created by Bas van Kuijck on 12/02/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (Mocking)
- (void)simulateLocation:(CLLocationCoordinate2D)coordinate;
@end
