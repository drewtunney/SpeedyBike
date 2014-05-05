//
//  MapVC.m
//  CitiBike
//
//  Created by Drew Tunney on 5/2/14.
//  Copyright (c) 2014 drewtunney. All rights reserved.
//

#import "MapVC.h"
#import <GoogleMaps/GoogleMaps.h>

@interface MapVC () <GMSMapViewDelegate>

@property(strong, nonatomic) NSURLSession *getStations;
@property(strong, nonatomic) NSSet *markers;

@end

@implementation MapVC {
    // TODO: make this a property
    GMSMapView *mapView_;
}


- (void)viewDidLoad {
    
      NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.getStations = [NSURLSession sessionWithConfiguration:config];

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:40.7127
                                                            longitude:-74.0059
                                                                 zoom:12];
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.myLocationEnabled = YES;
    self.view = mapView_;
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(40.7127, -74.0059);
    marker.title = @"New York";
    marker.snippet = @"New York";
    marker.map = mapView_;
    
    [self downloadStationData:nil];
    
}

- (void)downloadStationData:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"http://citibikenyc.com/stations/json"];
    
    NSURLSessionDataTask *task = [self.getStations dataTaskWithURL:url completionHandler:^ (NSData *data, NSURLResponse *response, NSError *error)
    {
        NSData *jsonResults = [NSData dataWithContentsOfURL:url];
        NSDictionary *stationsList = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                    options:0
                                                                       error:NULL];
        NSArray *stations = [stationsList valueForKeyPath:@"stationBeanList"];
        NSLog(@"station list = %@", stations);
        
    }];
    [task resume];
}

//-(IBAction)fetchStations
//{
////    [self.refreshControl beginRefreshing];
//    NSURL *url = [NSURL URLWithString:@"http://citibikenyc.com/stations/json"];
//    // create new queue
//    dispatch_queue_t fetchQ = dispatch_queue_create("station fetcher", NULL);
//    // switch to ephemeral fetch. this is in the background right now?
//    dispatch_async(fetchQ, ^{
//        NSData *jsonResults = [NSData dataWithContentsOfURL:url];
//        NSDictionary *stationsList = [NSJSONSerialization JSONObjectWithData:jsonResults
//                                                                     options:0
//                                                                       error:NULL];
//        NSArray *stations = [stationsList valueForKeyPath:@"stationBeanList"];
//        NSLog(@"station list = %@", stations);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            // since this is needed for the UI, it needs to be dispatched back to the main queue
////            [self.refreshControl endRefreshing];
//            self.stations = stations;
//        });
//    });
//}


@end
