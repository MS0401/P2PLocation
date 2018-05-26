//
//  MKMapView+Mocking.m
//  Library
//
//  Created by Bas van Kuijck on 12/02/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

#import "MKMapView+Mocking.h"
#import <objc/runtime.h>

@interface _MKMapViewShared: NSObject {

}
@property (nonatomic, strong) MKUserLocation *userLocation;
@end

@implementation _MKMapViewShared
@synthesize userLocation;

+ (instancetype)sharedInstance {
    static _MKMapViewShared *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[_MKMapViewShared alloc] init];
    });
    return sharedInstance;
}
@end

@implementation MKMapView (Mocking)
- (void)simulateLocation:(CLLocationCoordinate2D)coordinate {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];

        SEL originalSelector = @selector(userLocation);
        SEL swizzledSelector = @selector(mock_userLocation);

        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

        BOOL didAddMethod = class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));

        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });

    self.showsUserLocation = NO;
    Class mkUserLocationClass = NSClassFromString(@"MKUserLocation");
    MKUserLocation *mkUserLocation = [[mkUserLocationClass alloc] init];
    [mkUserLocation setCoordinate:coordinate];
    [[_MKMapViewShared sharedInstance] setUserLocation:mkUserLocation];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [mkUserLocation performSelector:NSSelectorFromString(@"setLocation:") withObject:location];
#pragma clang diagnostic pop
    [self addAnnotation:mkUserLocation];
    [self.delegate mapView:self didUpdateUserLocation:mkUserLocation];
}

- (MKUserLocation *)mock_userLocation {
    MKUserLocation *ul = [[_MKMapViewShared sharedInstance] userLocation];
    if (ul == nil) {
        return [self mock_userLocation];
    }
    return ul;
}
@end
