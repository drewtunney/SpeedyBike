//
//  GoogleMapsAPI.m
//  CitiBike
//
//  Created by Dare Ryan on 5/10/14.
//  Copyright (c) 2014 drewtunney. All rights reserved.
//

#import "GoogleMapsAPI.h"
#import "CitiBikeAPI.h"


@implementation GoogleMapsAPI

+(void)displayDirectionsfromOriginLatitude:(CGFloat)originLat andOriginLongitude:(CGFloat)originLong toDestinationLatitude:(CGFloat)destinationLat andDestinationLongitude:(CGFloat)destinationLong onMap:(GMSMapView *)map
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [map clear];
    });
    NSString *directionsURL = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=false&key=%@&avoid=ferries&mode=bicycling", originLat, originLong,destinationLat,destinationLong,Web_Browser_Key];
    NSURL *url = [NSURL URLWithString:directionsURL];
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *JSONResponseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            GMSPath *path = [GMSPath pathFromEncodedPath:JSONResponseDict[@"routes"][0][@"overview_polyline"][@"points"]];
            GMSPolyline *directionsLine;
            directionsLine = [GMSPolyline polylineWithPath:path];
            directionsLine.strokeWidth = 7;
            directionsLine.strokeColor = [UIColor greenColor];
            directionsLine.map = map;
            
            CLLocationCoordinate2D originPosition = CLLocationCoordinate2DMake(originLat, originLong);
            GMSMarker *originMarker = [GMSMarker markerWithPosition:originPosition];
            originMarker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
            originMarker.map = map;
            
            CLLocationCoordinate2D destinationPosition = CLLocationCoordinate2DMake(destinationLat, destinationLong);
            GMSMarker *destinationMarker = [GMSMarker markerWithPosition:destinationPosition];
            //destinationMarker.icon = [GMSMarker markerImageWithColor:[UIColor blackColor]];
            if (destinationMarker.position.latitude == destinationLat && destinationMarker.position.longitude == destinationLong) {
                destinationMarker.icon = [GMSMarker markerImageWithColor:[UIColor redColor]];
            }
            else{
                destinationMarker.icon = [GMSMarker markerImageWithColor:[UIColor blackColor]];
            }
            destinationMarker.map = map;
        });
        if (error) {
            NSLog(@"%@", error);
        }
    }]resume];
}

+(void)getAddressForLocationReferenceID:(NSString *)ID withCompletion:(void (^)(NSString *))completion
{
    NSString*urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?reference=%@&sensor=true&key=%@", ID, Web_Browser_Key];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *JSONResponseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        NSString *fullAddress;
        
        if ([JSONResponseDict[@"result"][@"address_components"][0][@"long_name"] isEqualToString:@"New York"]) {
            fullAddress = [JSONResponseDict[@"result"][@"name"] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        }
        else{
            NSMutableArray *addressArray = [[NSMutableArray alloc]init];
            for (NSDictionary *components in JSONResponseDict[@"result"][@"address_components"]) {
                [addressArray addObject:components[@"long_name"]];
            }
            fullAddress = [addressArray componentsJoinedByString:@"+"];
            fullAddress = [fullAddress stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        }
        if (error) {
            NSLog(@"%@", error);
        }
        completion(fullAddress);
    }]resume];
}

+(void)getCoordinatesForLocationForDestination:(NSString *)address withCompletion:(void (^)(NSDictionary *))completion
{
    NSString*urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true&key=%@", address, Web_Browser_Key];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSDictionary *JSONResponseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSNumber *directionsDestinationLatitude = [NSNumber numberWithFloat:[JSONResponseDict[@"results"][0][@"geometry"][@"location"][@"lat"]floatValue]];
        NSNumber *directionsDestinationLongitude = [NSNumber numberWithFloat:[JSONResponseDict[@"results"][0][@"geometry"][@"location"][@"lng"]floatValue]];
        
        NSDictionary *coordinates = @{@"lat":directionsDestinationLatitude, @"lng":directionsDestinationLongitude};
        
        if (error) {
            NSLog(@"%@", error);
        }
        completion(coordinates);
    }]resume];
}

+(void)updateListWithSuggestedPlacesForName:(NSString *)textInput forLatitude:(CGFloat)latitude andLongitude:(CGFloat)longitude withCompletion:(void (^)(NSMutableArray *))completion
{
    NSMutableArray *responseDictArray = [[NSMutableArray alloc]init];
    NSString *searchString = [textInput stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&location=%f,%f&radius=17000&sensor=true&key=%@", searchString, latitude, longitude, Web_Browser_Key];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *JSONResponseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        for (NSDictionary *location in JSONResponseDict[@"predictions"]) {
            [responseDictArray addObject:location];
        }
        
        if (error) {
            NSLog(@"%@", error);
        }
        completion(responseDictArray);
    }]resume];
}
@end
