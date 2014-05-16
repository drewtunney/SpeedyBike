//
//  CSDirectionsCell.h
//  cs-maps-level4
//
//  Created by Jon Friskics on 1/24/14.
//  Copyright (c) 2014 Code School. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DirectionsCell : UITableViewCell

@property (strong, nonatomic) UIWebView *directionsWebView;
@property (strong, nonatomic) UILabel *distanceLabel;
@property (strong, nonatomic) UIImageView *directionImage;

@end
