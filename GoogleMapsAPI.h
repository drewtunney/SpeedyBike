//
//  GoogleMapsAPI.h
//  CitiBike
//
//  Created by Dare Ryan on 5/10/14.
//  Copyright (c) 2014 drewtunney. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "Constants.h"

@interface GoogleMapsAPI : NSObject

+(void)displayDirectionsfromOriginLatitude:(CGFloat)originLat andOriginLongitude:(CGFloat)originLong toDestinationLatitude:(CGFloat)destinationLat andDestinationLongitude:(CGFloat)destinationLong onMap:(GMSMapView *)map;

+(void)getAddressForLocationReferenceID:(NSString *)ID withCompletion:(void (^)(NSString *))completion;

+(void)getCoordinatesForLocationForDestination:(NSString *)address withCompletion:(void (^)(NSDictionary *))completion;

+(void)updateListWithSuggestedPlacesForName:(NSString *)textInput forLatitude:(CGFloat)latitude andLongitude:(CGFloat)longitude withCompletion:(void (^)(NSMutableArray *))completion;

@end
