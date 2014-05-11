//
//  CitiBikeAPI.m
//  CitiBike
//
//  Created by Dare Ryan on 5/10/14.
//  Copyright (c) 2014 drewtunney. All rights reserved.
//

#import "CitiBikeAPI.h"

@implementation CitiBikeAPI


+ (void)downloadStationDataWithCompletion:(void (^)(NSArray *))completion
{
    NSURL *url = [NSURL URLWithString:@"http://citibikenyc.com/stations/json"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^ (NSData *data, NSURLResponse *response, NSError *error){
        NSArray *stationsList = [NSJSONSerialization JSONObjectWithData:data
                                                                options:0
                                                                  error:NULL];
        NSArray *stations = [stationsList valueForKeyPath:@"stationBeanList"];
        completion (stations);
    }];
    [task resume];
}

+(NSMutableArray *)findNearestStationsWithBikesforLatitude:(CGFloat)latitude andLongitude:(CGFloat)longitude inArrayOfStations:(NSArray *)allStations
{
    NSMutableArray *closestStations = [[NSMutableArray alloc]init];
    
    for (NSDictionary *station in allStations) {
        if ([station[@"availableBikes"] integerValue] > 1 && [station[@"statusValue"] isEqualToString:@"In Service"]) {
            CGFloat latitudeDifference = latitude - [station[@"latitude"] floatValue];
            CGFloat longitudeDifference = longitude - [station[@"longitude"] floatValue];
            CGFloat distanceFloat = latitudeDifference*latitudeDifference + longitudeDifference*longitudeDifference;
            NSNumber *distance = [NSNumber numberWithFloat:distanceFloat];
            NSMutableDictionary *availableStationDict = [NSMutableDictionary dictionaryWithDictionary:station];
            [availableStationDict setObject:distance forKey:@"distance"];
            [closestStations addObject:availableStationDict];
        }
    }
    
    NSSortDescriptor *distanceSort = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];
    [closestStations sortUsingDescriptors:@[distanceSort]];
   
    return closestStations;
}

+(void)findNearestStationsWithDocksforLatitude:(CGFloat)latitude andLongitude:(CGFloat)longitude inArrayOfStations:(NSArray *)allStations withCompletion:(void (^)(NSArray *))completion
{
    NSMutableArray *closestStations = [[NSMutableArray alloc]init];
    
    for (NSDictionary *station in allStations) {
        if ([station[@"availableDocks"] integerValue] > 1 && [station[@"statusValue"] isEqualToString:@"In Service"]) {
            CGFloat latitudeDifference = latitude - [station[@"latitude"] floatValue];
            CGFloat longitudeDifference = longitude - [station[@"longitude"] floatValue];
            CGFloat distanceFloat = latitudeDifference*latitudeDifference + longitudeDifference*longitudeDifference;
            NSNumber *distance = [NSNumber numberWithFloat:distanceFloat];
            NSMutableDictionary *availableStationDict = [NSMutableDictionary dictionaryWithDictionary:station];
            [availableStationDict setObject:distance forKey:@"distance"];
            [closestStations addObject:availableStationDict];
        }
    }
    
    NSSortDescriptor *distanceSort = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];
    [closestStations sortUsingDescriptors:@[distanceSort]];
    
    completion(closestStations);
}


@end