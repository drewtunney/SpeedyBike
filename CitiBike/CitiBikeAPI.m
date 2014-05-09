//
//  CitiBikeAPI.m
//  CitiBike
//
//  Created by Dare Ryan on 5/9/14.
//  Copyright (c) 2014 drewtunney. All rights reserved.
//

#import "CitiBikeAPI.h"
#import "StationMarker.h"

@implementation CitiBikeAPI

//- (void)downloadStationData:(id)sender
//{
//    NSURL *url = [NSURL URLWithString:@"http://citibikenyc.com/stations/json"];
//    
//    NSURLSessionDataTask *task = [self.getStations dataTaskWithURL:url completionHandler:^ (NSData *data, NSURLResponse *response, NSError *error)
//                                  {
//                                      NSArray *stationsList = [NSJSONSerialization JSONObjectWithData:data
//                                                                                              options:0
//                                                                                                error:NULL];
//                                      NSArray *stations = [stationsList valueForKeyPath:@"stationBeanList"];
//                                      NSLog(@"Current Location = %@", mapView_.myLocation);
//                                      self.stations = stations;
//                                      [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
//                                          [self createMarkerObjectsWithJson:stationsList];
//                                      }];
//                                  }];
//    [task resume];
//}
//
//- (void)createMarkerObjectsWithJson:(NSArray *)markers
//{
//    
//    //    StationMarker *newMarker = [[StationMarker alloc] init];
//    for (StationMarker *obj in self.stations)
//    {
//        if ([[obj valueForKeyPath:@"availableBikes"]intValue] > 10) {
//            GMSMarker *marker = [[GMSMarker alloc] init];
//            marker.position = CLLocationCoordinate2DMake([[obj valueForKeyPath:@"latitude"]floatValue], [[obj valueForKeyPath:@"longitude"]floatValue]);
//            NSLog(@"latitude %f", [[obj valueForKeyPath:@"latitude"]floatValue]);
//            marker.title = [obj valueForKeyPath:@"stAddress1"];
//            marker.snippet = [[obj valueForKeyPath:@"availableBikes"] stringValue];
//            marker.icon = [GMSMarker markerImageWithColor:[UIColor blackColor]];
//            marker.map = mapView_;
//        }
//        else {
//            //            NSLog(@"No Bikes at %@ %@", [obj valueForKeyPath:@"availableBikes"],[obj valueForKeyPath:@"stAddress1"]);
//        }
//    }
//}


@end
