//
//  MapVC.m
//  CitiBike
//
//  Created by Drew Tunney on 5/2/14.
//  Copyright (c) 2014 drewtunney. All rights reserved.
//

#import "MapVC.h"
#import <GoogleMaps/GoogleMaps.h>

@interface MapVC ()

@end

@implementation MapVC {
    GMSMapView *mapView_;
}

- (void)viewDidLoad {
    NSLog(@"Current identifier: %@", [[NSBundle mainBundle] bundleIdentifier]);
    
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                            longitude:151.20
                                                                 zoom:6];
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.myLocationEnabled = YES;
    self.view = mapView_;
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(-33.86, 151.20);
    marker.title = @"Sydney";
    marker.snippet = @"Australia";
    marker.map = mapView_;
}


@end
