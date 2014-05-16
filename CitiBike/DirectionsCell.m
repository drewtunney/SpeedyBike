//
//  CSDirectionsCell.m
//  cs-maps-level4
//
//  Created by Jon Friskics on 1/24/14.
//  Copyright (c) 2014 Code School. All rights reserved.
//

#import "DirectionsCell.h"

@implementation DirectionsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
      self.directionsWebView = [[UIWebView alloc] init];
        self.directionImage = [[UIImageView alloc]init];
      self.directionsWebView.scrollView.scrollEnabled = NO;
        [self.directionsWebView setContentMode:UIViewContentModeScaleToFill];
      [self addSubview:self.directionsWebView];
      
      self.distanceLabel = [[UILabel alloc] init];
      self.distanceLabel.font = [UIFont fontWithDescriptor:[UIFontDescriptor fontDescriptorWithFontAttributes:@{NSFontAttributeName: @"Arial", NSForegroundColorAttributeName: [UIColor colorWithWhite:0.5 alpha:1.0]}] size:15];
      self.distanceLabel.numberOfLines = 1;
      [self addSubview:self.distanceLabel];
        [self addSubview:self.directionImage];
    }
    return self;
}


- (void)layoutSubviews
{
  [super layoutSubviews];
  
  CGRect directionsWebViewFrame = self.directionsWebView.frame;
  directionsWebViewFrame.origin.x = 20;
  directionsWebViewFrame.origin.y = 20;
  directionsWebViewFrame.size.width = 250;
  directionsWebViewFrame.size.height = 49;
  self.directionsWebView.frame = directionsWebViewFrame;
  
  self.distanceLabel.frame = CGRectMake(30, CGRectGetMaxY(self.directionsWebView.frame), 280, 30);
    
    self.directionImage.frame = CGRectMake(270, 40, 30, 30);
}


@end
