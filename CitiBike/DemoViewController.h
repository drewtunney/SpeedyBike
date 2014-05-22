//
//  DemoViewController.h
//  CitiBike
//
//  Created by Dare Ryan on 5/22/14.
//  Copyright (c) 2014 drewtunney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageContentViewController.h"

@interface DemoViewController: UIViewController <UIPageViewControllerDataSource>

- (IBAction)startWalkthrough:(id)sender;

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;

@end
