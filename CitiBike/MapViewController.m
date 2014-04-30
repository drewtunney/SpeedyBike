//
//  MapViewController.m
//  CitiBike
//
//  Created by Drew Tunney on 4/30/14.
//  Copyright (c) 2014 drewtunney. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>

@interface MapViewController () <MKMapViewDelegate>
// outlet for the map view
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

// how do stations get in here? should I import the method from StationInfo?
// not quite sure if I should import the file or rewrite the method in here

@end

@implementation MapViewController

- (void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    self.mapView.delegate = self;
//    [self updateMapViewAnnotations];
}

// here is probably where to put a setStations method

// also need a prepare for Segue Method (41:00)
// Photographers CDTVC
// so should we be saving this data into core data or just using it "in the window"?


@end
