//
//  StationMarker.m
//  CitiBike
//
//  Created by Drew Tunney on 5/5/14.
//  Copyright (c) 2014 drewtunney. All rights reserved.
//

#import "StationMarker.h"

@implementation StationMarker

- (BOOL)isEqual:(id)object {
    StationMarker *otherMarker = (StationMarker *)object;
    
    if ([otherMarker isKindOfClass:[StationMarker class]]) {
        
        if(self.objectID == otherMarker.objectID) {
            return YES;
        }
        
    }
    
    return NO;
}

- (NSUInteger)hash {
    return [self.objectID hash];
}

@end
