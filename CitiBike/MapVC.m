//
//  MapVC.m
//  CitiBike
//
//  Created by Drew Tunney on 5/2/14.
//  Copyright (c) 2014 drewtunney. All rights reserved.
//

#import "MapVC.h"
#import <GoogleMaps/GoogleMaps.h>
#import "StationMarker.h"

@interface MapVC () <GMSMapViewDelegate>

@property(strong, nonatomic) NSURLSession *getStations;
@property(strong, nonatomic) NSSet *markers;


@end

@implementation MapVC {
    GMSMapView *mapView_;
}


- (void)viewDidLoad {
    
      NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.getStations = [NSURLSession sessionWithConfiguration:config];

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:37.7833
                                                            longitude:-122.4167
                                                                 zoom:12];
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.myLocationEnabled = YES;
    mapView_.settings.myLocationButton = YES;
    self.view = mapView_;
    mapView_.delegate = self;

    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(40.7127, -74.0059);
    marker.title = @"New York";
    marker.snippet = @"New York";
    marker.icon = [GMSMarker markerImageWithColor:[UIColor blackColor]];
    marker.map = mapView_;
    
    [self downloadStationData:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Implement here to check if already KVO is implemented.

    [self.view addObserver:self forKeyPath:@"myLocation" options:NSKeyValueObservingOptionNew context: nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"myLocation"] && [object isKindOfClass:[GMSMapView class]])
    {
        [mapView_ animateToCameraPosition:[GMSCameraPosition cameraWithLatitude:mapView_.myLocation.coordinate.latitude
                                                                                 longitude:mapView_.myLocation.coordinate.longitude
                                                                                      zoom:15]];
    }
}

- (void)downloadStationData:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"http://citibikenyc.com/stations/json"];
    
    NSURLSessionDataTask *task = [self.getStations dataTaskWithURL:url completionHandler:^ (NSData *data, NSURLResponse *response, NSError *error)
    {
        NSArray *stationsList = [NSJSONSerialization JSONObjectWithData:data
                                                                    options:0
                                                                       error:NULL];
        NSArray *stations = [stationsList valueForKeyPath:@"stationBeanList"];
        NSLog(@"Current Location = %@", mapView_.myLocation);
        self.stations = stations;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            [self createMarkerObjectsWithJson:stationsList];
        }];
    }];
    [task resume];
}

- (void)createMarkerObjectsWithJson:(NSArray *)markers
{

    StationMarker *newMarker = [[StationMarker alloc] init];
    newMarker.title = [self.stations valueForKeyPath:@"availableBikes"];
    NSLog(@"title = %@", self.stations);
}

#pragma mark - GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView_
didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    NSLog(@"You tapped at %f,%f", coordinate.latitude, coordinate.longitude);
}


@end
