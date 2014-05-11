//
//  CitiBikeAPI.h
//  CitiBike
//
//  Created by Dare Ryan on 5/10/14.
//  Copyright (c) 2014 drewtunney. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CitiBikeAPI : NSObject

+ (void)downloadStationDataWithCompletion:(void (^)(NSArray *))completion;

+(NSMutableArray *)findNearestStationsWithBikesforLatitude:(CGFloat)latitude andLongitude:(CGFloat)longitude inArrayOfStations:(NSArray *)allStations;

+(void)findNearestStationsWithDocksforLatitude:(CGFloat)latitude andLongitude:(CGFloat)longitude inArrayOfStations:(NSArray *)allStations withCompletion:(void (^)(NSArray *))completion;

@end
