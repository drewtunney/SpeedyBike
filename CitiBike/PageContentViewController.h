//
//  PageContentViewController.h
//  CitiBike
//
//  Created by Dare Ryan on 5/22/14.
//  Copyright (c) 2014 drewtunney. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageContentViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *imageFile;
@end
