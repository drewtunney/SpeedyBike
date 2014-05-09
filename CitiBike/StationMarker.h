//
//  StationMarker.h
//  CitiBike
//
//  Created by Drew Tunney on 5/5/14.
//  Copyright (c) 2014 drewtunney. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>

@interface StationMarker : GMSMarker

@property (nonatomic, copy)NSString *objectID;
@property (strong, nonatomic) NSString *stationId;
@property (strong, nonatomic) NSString *location;

@end
